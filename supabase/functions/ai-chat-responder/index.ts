import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

const AI_TIMEOUT_MINUTES = 10;
const GEMINI_MODEL = "gemini-2.5-flash";

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
  if (!GEMINI_API_KEY) {
    return jsonError("GEMINI_API_KEY not configured", 500);
  }

  let payload: Record<string, unknown>;
  try {
    payload = (await req.json()) as Record<string, unknown>;
  } catch {
    return jsonError("Invalid JSON payload", 400);
  }

  const action = (payload.action as string) ?? "handle_user_message";

  try {
    switch (action) {
      case "handle_user_message":
        return await handleUserMessage(supabase, payload, GEMINI_API_KEY);
      case "process_timeout":
        return await processTimeout(supabase, payload, GEMINI_API_KEY);
      case "instant_ai_reply":
        return await instantAiReply(supabase, payload, GEMINI_API_KEY);
      default:
        return jsonError(`Unknown action: ${action}`, 400);
    }
  } catch (err) {
    console.error("Critical error:", err);
    return jsonError(err instanceof Error ? err.message : String(err), 500);
  }
});

async function handleUserMessage(
  supabase: ReturnType<typeof createClient>,
  payload: Record<string, unknown>,
  geminiKey: string,
) {
  const threadId = payload.thread_id as string | undefined;
  if (!threadId) return jsonError("thread_id is required", 400);

  const { data: thread, error: threadErr } = await supabase
    .from("chat_threads")
    .select("*")
    .eq("id", threadId)
    .single();

  if (threadErr || !thread) {
    return jsonError("Thread not found", 404);
  }

  if (thread.ai_mode_active && !thread.last_admin_message_at) {
    return await generateAiReply(supabase, threadId, geminiKey);
  }

  if (thread.ai_mode_active && thread.last_admin_message_at) {
    const lastAdmin = new Date(thread.last_admin_message_at);
    const lastAi = thread.last_ai_message_at
      ? new Date(thread.last_ai_message_at)
      : new Date(0);
    if (lastAdmin > lastAi) {
      return await generateAiReply(supabase, threadId, geminiKey);
    }
  }

  return new Response(
    JSON.stringify({
      status: "scheduled",
      message: `AI timeout scheduled for ${AI_TIMEOUT_MINUTES} minutes`,
      thread_id: threadId,
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

async function processTimeout(
  supabase: ReturnType<typeof createClient>,
  payload: Record<string, unknown>,
  geminiKey: string,
) {
  const jobId = payload.job_id as string | undefined;
  if (!jobId) return jsonError("job_id is required", 400);

  const { data: job, error: jobErr } = await supabase
    .from("scheduled_jobs")
    .select("*")
    .eq("id", jobId)
    .eq("status", "pending")
    .single();

  if (jobErr || !job) {
    return new Response(
      JSON.stringify({ status: "skipped", reason: "Job not found or already processed" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const { data: result, error: rpcErr } = await supabase.rpc("process_ai_timeout", {
    p_job_id: jobId,
  });

  if (rpcErr) {
    await supabase.from("scheduled_jobs").update({
      status: "failed",
      error_message: rpcErr.message,
      attempts: job.attempts + 1,
    }).eq("id", jobId);
    return jsonError(`process_ai_timeout failed: ${rpcErr.message}`, 500);
  }

  const rpcResult = result as { status: string; reason?: string; thread_id?: string } | null;

  if (rpcResult?.status === "ready" && rpcResult.thread_id) {
    const aiResult = await generateAiReply(supabase, rpcResult.thread_id, geminiKey);
    return aiResult;
  }

  return new Response(
    JSON.stringify({
      status: "skipped",
      reason: rpcResult?.reason ?? "Unknown",
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

async function instantAiReply(
  supabase: ReturnType<typeof createClient>,
  payload: Record<string, unknown>,
  geminiKey: string,
) {
  const threadId = payload.thread_id as string | undefined;
  if (!threadId) return jsonError("thread_id is required", 400);

  return await generateAiReply(supabase, threadId, geminiKey);
}

async function generateAiReply(
  supabase: ReturnType<typeof createClient>,
  threadId: string,
  geminiKey: string,
): Promise<Response> {
  const { data: messages, error: fetchErr } = await supabase
    .from("chat_messages")
    .select("*")
    .eq("thread_id", threadId)
    .order("created_at", { ascending: true })
    .limit(30);

  if (fetchErr) throw fetchErr;
  if (!messages || messages.length === 0) {
    return new Response(
      JSON.stringify({ status: "skipped", reason: "No messages in thread" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const lastMessage = messages[messages.length - 1];
  if (lastMessage.sender_type !== "user") {
    return new Response(
      JSON.stringify({
        status: "skipped",
        reason: `Last message is from ${lastMessage.sender_type}, not user`,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const { data: thread } = await supabase
    .from("chat_threads")
    .select("ai_mode_active")
    .eq("id", threadId)
    .single();

  const { count: recentAdminCount } = await supabase
    .from("chat_messages")
    .select("*", { count: "exact", head: true })
    .eq("thread_id", threadId)
    .in("sender_type", ["sales", "admin"])
    .gt("created_at", lastMessage.created_at);

  if (recentAdminCount && recentAdminCount > 0) {
    return new Response(
      JSON.stringify({ status: "skipped", reason: "Admin replied while AI was generating" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  const chatHistory = messages
    .map((m) => `${m.sender_type.toUpperCase()}: ${m.message}`)
    .join("\n");

  const systemPrompt = `You are the AI support agent for VoltCart, a premium e-commerce platform specializing in high-end electronics and accessories.

Current conversation:
${chatHistory}

Guidelines:
- If the user asks about order status, acknowledge and mention a human agent will verify soon.
- If the user asks about products (MacBook, PS5, Sony Alpha, etc.), provide helpful technical info.
- If the user says hello, greet warmly in a professional brand voice.
- Keep responses concise (under 80 words).
- Provide a 1-sentence summary of the user's need for internal logs.

Respond ONLY in this JSON format:
{"reply": "Your message to the user", "summary": "1-sentence summary for admin"}`;

  const geminiResponse = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${geminiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: systemPrompt }] }],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 300,
          responseMimeType: "application/json",
        },
      }),
    },
  );

  if (!geminiResponse.ok) {
    const errText = await geminiResponse.text();
    throw new Error(`Gemini API error ${geminiResponse.status}: ${errText}`);
  }

  const geminiData = await geminiResponse.json();
  const aiText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;

  if (!aiText) {
    throw new Error("Gemini returned empty content");
  }

  let parsed: { reply: string; summary: string };
  try {
    parsed = JSON.parse(aiText);
  } catch {
    parsed = { reply: aiText, summary: "User reached out to support." };
  }

  const { error: insertErr } = await supabase.from("chat_messages").insert({
    thread_id: threadId,
    sender_type: "ai",
    message: parsed.reply,
  });

  if (insertErr) throw insertErr;

  const userId = messages.find((m) => m.sender_type === "user")?.sender_id;
  if (userId) {
    await supabase.from("chat_summaries").upsert(
      {
        thread_id: threadId,
        user_id: userId,
        issue_description: parsed.summary,
        updated_at: new Date().toISOString(),
      },
      { onConflict: "thread_id" },
    );
  }

  await supabase
    .from("chat_threads")
    .update({ ai_mode_active: true })
    .eq("id", threadId);

  console.log(`AI replied to thread ${threadId}`);

  return new Response(
    JSON.stringify({
      status: "success",
      reply: parsed.reply,
      thread_id: threadId,
    }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

function jsonError(message: string, status: number): Response {
  return new Response(
    JSON.stringify({ error: message }),
    {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );
}
