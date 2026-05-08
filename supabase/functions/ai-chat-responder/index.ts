import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

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

  // AI mode is active — respond INSTANTLY, no timer
  if (thread.ai_mode_active) {
    return await generateAiReply(supabase, threadId, geminiKey);
  }

  // Check if admin already replied since last AI message
  if (thread.last_admin_message_at && thread.last_ai_message_at) {
    const lastAdmin = new Date(thread.last_admin_message_at);
    const lastAi = new Date(thread.last_ai_message_at);
    // Admin replied after last AI message — this is a new human-handled conversation
    // Schedule a fresh 10-min timer
  }

  // First message or admin never replied — schedule AI timeout
  return new Response(
    JSON.stringify({
      status: "scheduled",
      message: "AI timeout scheduled for 10 minutes",
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

  const { data: result, error: rpcErr } = await supabase.rpc("process_ai_timeout", {
    p_job_id: jobId,
  });

  if (rpcErr) {
    return jsonError(`process_ai_timeout failed: ${rpcErr.message}`, 500);
  }

  const rpcResult = result as { status: string; reason?: string; thread_id?: string } | null;

  if (rpcResult?.status === "ready" && rpcResult.thread_id) {
    return await generateAiReply(supabase, rpcResult.thread_id, geminiKey);
  }

  return new Response(
    JSON.stringify({ status: "skipped", reason: rpcResult?.reason ?? "Unknown" }),
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

async function fetchDatabaseContext(supabase: ReturnType<typeof createClient>): Promise<string> {
  const [productsRes, ordersRes, statsRes] = await Promise.all([
    supabase.from("products").select("id, name, category, brand, price, stock, is_best_seller, is_featured, is_hot_deal").limit(50),
    supabase.from("orders").select("id, status, total_amount, created_at").order("created_at", { ascending: false }).limit(20),
    supabase.from("products").select("stock", { count: "exact" }),
  ]);

  let context = "## VoltCart Database Context\n\n";

  // Product summary
  const products = productsRes.data ?? [];
  if (products.length > 0) {
    const totalProducts = products.length;
    const inStock = products.filter((p: any) => p.stock > 0).length;
    const outOfStock = products.filter((p: any) => p.stock === 0).length;
    const bestSellers = products.filter((p: any) => p.is_best_seller).map((p: any) => p.name);
    const featured = products.filter((p: any) => p.is_featured).map((p: any) => p.name);
    const hotDeals = products.filter((p: any) => p.is_hot_deal).map((p: any) => `${p.name} ($${p.price})`);
    const categories = [...new Set(products.map((p: any) => p.category))];
    const brands = [...new Set(products.map((p: any) => p.brand))];

    context += `### Product Inventory\n`;
    context += `- Total products: ${totalProducts}\n`;
    context += `- In stock: ${inStock}\n`;
    context += `- Out of stock: ${outOfStock}\n`;
    context += `- Categories: ${categories.join(", ")}\n`;
    context += `- Brands: ${brands.join(", ")}\n`;

    if (bestSellers.length > 0) context += `- Best sellers: ${bestSellers.join(", ")}\n`;
    if (featured.length > 0) context += `- Featured: ${featured.join(", ")}\n`;
    if (hotDeals.length > 0) context += `- Hot deals: ${hotDeals.join(", ")}\n`;

    // Detailed stock for common products
    context += `\n### Key Product Stock Levels\n`;
    const keyProducts = products.filter((p: any) => p.is_best_seller || p.is_featured || p.is_hot_deal).slice(0, 15);
    for (const p of keyProducts) {
      const stockStatus = p.stock > 10 ? "In Stock" : p.stock > 0 ? `Low Stock (${p.stock})` : "Out of Stock";
      context += `- ${p.name} (${p.brand}): $${p.price} — ${stockStatus}\n`;
    }
  }

  // Order summary
  const orders = ordersRes.data ?? [];
  if (orders.length > 0) {
    const preparing = orders.filter((o: any) => o.status === "Preparing").length;
    const shipped = orders.filter((o: any) => o.status === "Shipped").length;
    const onTheWay = orders.filter((o: any) => o.status === "On the way").length;
    const delivered = orders.filter((o: any) => o.status === "Delivered").length;
    const totalRevenue = orders.reduce((sum: number, o: any) => sum + Number(o.total_amount || 0), 0);

    context += `\n### Recent Orders\n`;
    context += `- Total recent orders: ${orders.length}\n`;
    context += `- Preparing: ${preparing}, Shipped: ${shipped}, On the way: ${onTheWay}, Delivered: ${delivered}\n`;
    context += `- Total revenue (recent): $${totalRevenue.toFixed(2)}\n`;
  }

  return context;
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
    ;

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
      JSON.stringify({ status: "skipped", reason: `Last message is from ${lastMessage.sender_type}, not user` }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  // Check if admin replied during AI generation
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

  // Fetch real database context
  const dbContext = await fetchDatabaseContext(supabase);

  const systemPrompt = `You are the AI support agent for VoltCart, a premium e-commerce platform specializing in high-end electronics and accessories.

${dbContext}

Current conversation with user:
${chatHistory}

Guidelines:
- Use the product inventory and stock information above to answer questions about product availability, pricing, and stock levels.
- If the user asks about order status, acknowledge and mention a human agent will verify details soon.
- If the user asks about specific products, use the stock data above to tell them exact availability.
- If the user asks about delivery, tell them the typical delivery timeline based on their location.
- Keep responses helpful but concise (under 100 words).
- Be specific — mention actual product names, prices, and stock levels from the data above.
- Provide a 1-sentence summary of the user's current need for internal logs.

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
          maxOutputTokens: 500,
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

  if (!aiText) throw new Error("Gemini returned empty content");

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

  await supabase.from("chat_threads").update({ ai_mode_active: true }).eq("id", threadId);

  console.log(`AI replied to thread ${threadId}`);
  console.log(`DB context sent: ${dbContext.length} chars`);

  return new Response(
    JSON.stringify({ status: "success", reply: parsed.reply, thread_id: threadId }),
    { headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}

function jsonError(message: string, status: number): Response {
  return new Response(
    JSON.stringify({ error: message }),
    { status, headers: { ...corsHeaders, "Content-Type": "application/json" } },
  );
}
