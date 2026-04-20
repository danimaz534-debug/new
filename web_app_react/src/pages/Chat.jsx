import { useEffect, useMemo, useState } from 'react';
import { fetchChatThreads, fetchMessages, sendSalesMessage, subscribeToTables } from '../lib/commerce';
import { PageHeader, SectionCard } from '../components/ui/SectionCard';
import useUiStore from '../store/useUiStore';

export default function ChatPage() {
  const [threads, setThreads] = useState([]);
  const [activeThread, setActiveThread] = useState('');
  const [messages, setMessages] = useState([]);
  const [draft, setDraft] = useState('');
  const [now, setNow] = useState(() => Date.now());
  const { pushToast } = useUiStore();

  useEffect(() => {
    const loadThreads = async () => {
      const nextThreads = await fetchChatThreads();
      setThreads(nextThreads);
      setActiveThread((current) => current || nextThreads[0]?.id || '');
    };
    loadThreads().catch(console.error);
    return subscribeToTables('chat-threads-live', ['chat_threads'], loadThreads);
  }, []);

  useEffect(() => {
    if (!activeThread) return undefined;
    const loadMessages = () => fetchMessages(activeThread).then(setMessages).catch(console.error);
    loadMessages();
    return subscribeToTables(`chat-messages-${activeThread}`, ['chat_messages'], loadMessages);
  }, [activeThread]);

  useEffect(() => {
    const interval = setInterval(() => setNow(Date.now()), 60000);
    return () => clearInterval(interval);
  }, []);

  const staleWarning = useMemo(() => {
    const thread = threads.find((item) => item.id === activeThread);
    if (!thread?.last_sales_reply_at) {
      return 'If sales stays silent for 5 minutes, the Supabase AI fallback sends: "We will contact you shortly".';
    }
    const minutes = Math.round((now - new Date(thread.last_sales_reply_at).getTime()) / 60000);
    return minutes >= 5
      ? 'Fallback window passed. Check whether the edge function has replied.'
      : `Fallback triggers in about ${5 - minutes} minute(s) if there is no sales reply.`;
  }, [activeThread, threads, now]);

  const submit = async (event) => {
    event.preventDefault();
    if (!draft.trim() || !activeThread) return;
    try {
      await sendSalesMessage(activeThread, draft.trim());
      setDraft('');
    } catch (error) {
      pushToast({ tone: 'danger', message: error.message });
    }
  };

  return (
    <div className="page-grid">
      <PageHeader eyebrow="Sales support" title="Chat" subtitle="Realtime wholesale conversations with fallback automation after 5 minutes." />
      <SectionCard title="Conversations" subtitle={staleWarning}>
        <div className="chat-layout">
          <div className="thread-column">
            {threads.map((thread) => (
              <button
                key={thread.id}
                type="button"
                className={`thread-card${thread.id === activeThread ? ' active' : ''}`}
                onClick={() => setActiveThread(thread.id)}
              >
                <strong>{thread.profiles?.full_name ?? 'Wholesale user'}</strong>
                <span>{thread.profiles?.email ?? 'No email'}</span>
                <small>{new Date(thread.created_at).toLocaleString()}</small>
              </button>
            ))}
          </div>
          <div className="chat-column">
            <div className="chat-stream">
              {messages.map((message) => (
                <article key={message.id} className={`chat-bubble ${message.sender_type}`}>
                  <strong>{message.sender?.full_name ?? message.sender?.email ?? message.sender_type}</strong>
                  <p>{message.message}</p>
                  <small>{new Date(message.created_at).toLocaleTimeString()}</small>
                </article>
              ))}
              {messages.length > 0 && messages[messages.length - 1].sender_type === 'user' && (
                <div className="typing-indicator">
                  <span>Customer is typing...</span>
                </div>
              )}
            </div>
            <form className="chat-composer" onSubmit={submit}>
              <input value={draft} onChange={(event) => setDraft(event.target.value)} placeholder="Reply to the customer..." />
              <button className="primary-button" type="submit">Send</button>
            </form>
          </div>
        </div>
      </SectionCard>
    </div>
  );
}
