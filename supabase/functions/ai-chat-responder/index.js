import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
);

serve(async () => {
  try {
    const cutoff = new Date(Date.now() - 5 * 60 * 1000).toISOString();

    const { data: staleThreads, error } = await supabase
      .from('chat_threads')
      .select('id, user_id, last_sales_reply_at')
      .or(`last_sales_reply_at.is.null,last_sales_reply_at.lt.${cutoff}`);

    if (error) throw error;

    if (!staleThreads?.length) {
      return json({ message: 'No threads require AI follow-up.' });
    }

    for (const thread of staleThreads) {
      await supabase.from('chat_messages').insert({
        thread_id: thread.id,
        sender_type: 'ai',
        message: 'We will contact you shortly',
      });

      await supabase.from('notifications').insert({
        user_id: thread.user_id,
        title: 'Support update',
        body: 'We will contact you shortly',
        type: 'support',
      });
    }

    return json({ message: 'AI fallback messages sent.', count: staleThreads.length });
  } catch (error) {
    return json({ error: error.message }, 500);
  }
});

function json(payload, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
