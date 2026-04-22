import { useEffect, useMemo, useRef, useState } from "react";
import {
  fetchChatThreads,
  fetchMessages,
  sendSalesMessage,
  subscribeToTables,
} from "../lib/commerce";
import { PageHeader, SectionCard } from "../components/ui/SectionCard";
import useUiStore from "../store/useUiStore";

function statusCopy(thread, latestMessage, now) {
  if (!thread) {
    return {
      label: "No thread selected",
      tone: "neutral",
      helper: "Choose a conversation from the list.",
    };
  }

  if (latestMessage?.sender_type === "user") {
    if (!thread.last_sales_reply_at) {
      return {
        label: "Awaiting first sales reply",
        tone: "warning",
        helper:
          'AI fallback sends "We will contact you shortly" after 5 minutes.',
      };
    }

    const minutes = Math.max(
      0,
      Math.round((now - new Date(thread.last_sales_reply_at).getTime()) / 60000),
    );

    if (minutes >= 5) {
      return {
        label: "Fallback window reached",
        tone: "danger",
        helper: "Check whether the edge function already replied.",
      };
    }

    return {
      label: "Waiting for sales",
      tone: "warning",
      helper: `Fallback triggers in about ${5 - minutes} minute(s).`,
    };
  }

  return {
    label: "Handled",
    tone: "success",
    helper: "Latest response came from sales or AI.",
  };
}

export default function ChatPage() {
  const [threads, setThreads] = useState([]);
  const [activeThread, setActiveThread] = useState("");
  const [messages, setMessages] = useState([]);
  const [draft, setDraft] = useState("");
  const [threadSearch, setThreadSearch] = useState("");
  const [now, setNow] = useState(() => Date.now());
  const streamRef = useRef(null);
  const { pushToast } = useUiStore();

  // Disable send when no thread selected
  const isSendDisabled = !activeThread || draft.trim() === "";

  useEffect(() => {
    const loadThreads = async () => {
      const nextThreads = await fetchChatThreads();
      setThreads(nextThreads);
      setActiveThread((current) => current || nextThreads[0]?.id || "");
    };
    loadThreads().catch(console.error);
    return subscribeToTables("chat-threads-live", ["chat_threads"], loadThreads);
  }, []);

  useEffect(() => {
    if (!activeThread) return undefined;
    const loadMessages = () =>
      fetchMessages(activeThread).then(setMessages).catch(console.error);
    loadMessages();
    return subscribeToTables(
      `chat-messages-${activeThread}`,
      ["chat_messages"],
      loadMessages,
    );
  }, [activeThread]);

  useEffect(() => {
    const interval = setInterval(() => setNow(Date.now()), 60000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!streamRef.current) return;
    streamRef.current.scrollTop = streamRef.current.scrollHeight;
  }, [messages]);

  const filteredThreads = useMemo(() => {
    const query = threadSearch.trim().toLowerCase();
    if (!query) return threads;
    return threads.filter((thread) =>
      [thread.profiles?.full_name, thread.profiles?.email]
        .join(" ")
        .toLowerCase()
        .includes(query),
    );
  }, [threadSearch, threads]);

  const activeConversation = useMemo(
    () => threads.find((item) => item.id === activeThread) ?? null,
    [activeThread, threads],
  );

  const latestMessage = messages.length ? messages[messages.length - 1] : null;
  const status = statusCopy(activeConversation, latestMessage, now);

  const submit = async (event) => {
    event.preventDefault();
    if (!draft.trim() || !activeThread) return;
    try {
      await sendSalesMessage(activeThread, draft.trim());
      setDraft("");
    } catch (error) {
      pushToast({ tone: "danger", message: error.message });
    }
  };

  // Handle Ctrl+Enter or Cmd+Enter to send
  const handleKeyDown = (event) => {
    if (event.key === 'Enter' && (event.ctrlKey || event.metaKey)) {
      event.preventDefault();
      submit(event);
    }
  };

  return (
    <div className="page-grid">
      <PageHeader
        eyebrow="Sales support"
        title="Chat"
        subtitle="Realtime wholesale conversations with Supabase fallback automation after 5 minutes."
      />
      <SectionCard
        title="Conversations"
        subtitle={status.helper}
      >
        <div className="chat-toolbar">
          <label className="search-bar">
            <input
              value={threadSearch}
              onChange={(event) => setThreadSearch(event.target.value)}
              placeholder="Search conversations..."
            />
          </label>
          {/* Status pill removed */}
        </div>
        <div className="chat-layout enhanced">
          <div className="thread-column enhanced">
            {filteredThreads.map((thread) => {
              const isActive = thread.id === activeThread;
              const waiting =
                messages.length > 0 &&
                activeThread === thread.id &&
                latestMessage?.sender_type === "user";

              return (
                <button
                  key={thread.id}
                  type="button"
                  className={`thread-card${isActive ? " active" : ""}`}
                  onClick={() => setActiveThread(thread.id)}
                >
                  <div className="thread-topline">
                    <strong>{thread.profiles?.full_name ?? "Wholesale user"}</strong>
                    {waiting && <span className="thread-badge">Waiting</span>}
                  </div>
                  <span>{thread.profiles?.email ?? "No email"}</span>
                  <div className="thread-meta">
                    <small>{new Date(thread.created_at).toLocaleString()}</small>
                    <small>
                      {thread.assigned_sales_id ? "Assigned" : "Unassigned"}
                    </small>
                  </div>
                </button>
              );
            })}
            {filteredThreads.length === 0 && (
              <div className="thread-empty">
                <p className="muted-copy">No matching conversations.</p>
              </div>
            )}
          </div>
          <div className="chat-column enhanced">
            <div className="chat-column-head">
              <div>
                <strong>
                  {activeConversation?.profiles?.full_name ?? "Select a thread"}
                </strong>
                <span>{activeConversation?.profiles?.email ?? "No email"}</span>
              </div>
              <div className="chat-head-meta">
                {/* Status pill removed */}
                {activeConversation && (
                  <small>
                    Opened {new Date(activeConversation.created_at).toLocaleString()}
                  </small>
                )}
              </div>
            </div>

            <div className="chat-stream enhanced" ref={streamRef}>
              {messages.length === 0 ? (
                <div className="chat-empty-state">
                  <strong>No messages yet</strong>
                  <p>Send the first sales reply when the customer reaches out.</p>
                </div>
              ) : (
                messages.map((message) => (
                  <article
                    key={message.id}
                    className={`chat-bubble ${message.sender_type}`}
                  >
                    <strong>
                      {message.sender?.full_name ??
                        message.sender?.email ??
                        message.sender_type}
                    </strong>
                    <p>{message.message}</p>
                    <small>{new Date(message.created_at).toLocaleTimeString()}</small>
                  </article>
                ))
              )}
            </div>

            {/* Status note removed */}

            <form className="chat-composer enhanced" onSubmit={submit}>
              <input
                value={draft}
                onChange={(event) => setDraft(event.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Reply to the customer... (Ctrl/Cmd+Enter to send)"
                disabled={!activeThread}
              />
              <button 
                className="primary-button" 
                type="submit"
                disabled={!activeThread}
              >
                Send
              </button>
            </form>
          </div>
        </div>
      </SectionCard>
    </div>
  );
}
