import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";

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
    return new Response(
      JSON.stringify({ error: "GEMINI_API_KEY not configured" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  try {
    const now = new Date().toISOString();

    const { data: pendingJobs, error: fetchErr } = await supabase
      .from("scheduled_jobs")
      .select("*")
      .eq("status", "pending")
      .eq("job_type", "ai_timeout")
      .lte("scheduled_at", now)
      .order("scheduled_at", { ascending: true })
      .limit(10);

    if (fetchErr) throw fetchErr;

    if (!pendingJobs || pendingJobs.length === 0) {
      return new Response(
        JSON.stringify({ status: "ok", processed: 0, message: "No pending timeout jobs" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const results = [];

    for (const job of pendingJobs) {
      try {
        const { data: rpcResult, error: rpcErr } = await supabase.rpc(
          "process_ai_timeout",
          { p_job_id: job.id },
        );

        if (rpcErr) {
          await supabase.from("scheduled_jobs").update({
            status: "failed",
            error_message: rpcErr.message,
            attempts: job.attempts + 1,
          }).eq("id", job.id);
          results.push({ job_id: job.id, status: "failed", error: rpcErr.message });
          continue;
        }

        const result = rpcResult as { status: string; reason?: string; thread_id?: string } | null;

        if (result && result.status === "ready" && result.thread_id) {
          const aiResponse = await fetch(
            `${Deno.env.get("SUPABASE_URL")}/functions/v1/ai-chat-responder`,
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
              },
              body: JSON.stringify({
                action: "instant_ai_reply",
                thread_id: result.thread_id,
              }),
            },
          );

          const aiResult = await aiResponse.json();
          results.push({ job_id: job.id, status: "ai_triggered", result: aiResult });
        } else {
          const rpcStatus = (result && result.status === "skipped") ? "skipped" : "completed";
          const rpcReason = (result && result.reason) ? result.reason : "Unknown";
          results.push({ job_id: job.id, status: rpcStatus, reason: rpcReason });
        }
      } catch (jobErr) {
        await supabase.from("scheduled_jobs").update({
          status: "failed",
          error_message: jobErr instanceof Error ? jobErr.message : String(jobErr),
          attempts: job.attempts + 1,
        }).eq("id", job.id);
        results.push({
          job_id: job.id,
          status: "error",
          error: jobErr instanceof Error ? jobErr.message : String(jobErr),
        });
      }
    }

    return new Response(
      JSON.stringify({ status: "ok", processed: pendingJobs.length, results }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    console.error("Cron processor error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : String(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
