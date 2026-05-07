# AI Auto-Reply Chat System — Architecture Documentation

## System Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter Mobile │     │  React Admin     │     │  Supabase       │
│  App (User)     │     │  Dashboard       │     │  Backend        │
└────────┬────────┘     └────────┬─────────┘     └────────┬────────┘
         │                       │                        │
         │  Supabase Realtime    │  Supabase Realtime     │
         │  + REST API           │  + REST API            │
         │                       │                        │
         ▼                       ▼                        ▼
┌──────────────────────────────────────────────────────────────────┐
│                        Supabase Database                         │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │chat_threads  │  │chat_messages │  │scheduled_jobs         │  │
│  │              │  │              │  │                       │  │
│  │ai_mode_active│  │sender_type:  │  │job_type: 'ai_timeout' │  │
│  │awaiting_     │  │ user/sales/  │  │status: pending/       │  │
│  │ admin_resp   │  │ admin/ai     │  │  processing/completed │  │
│  │last_user_    │  │              │  │scheduled_at           │  │
│  │ message_at   │  │              │  │                       │  │
│  │last_admin_   │  │              │  │                       │  │
│  │ message_at   │  │              │  │                       │  │
│  │last_ai_      │  │              │  │                       │  │
│  │ message_at   │  │              │  │                       │  │
│  └──────────────┘  └──────────────┘  └───────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │                    Database Triggers                      │    │
│  │                                                          │    │
│  │  tr_handle_user_message (AFTER INSERT on chat_messages)  │    │
│  │    → Updates last_user_message_at                        │    │
│  │    → Sets awaiting_admin_response = true                 │    │
│  │    → Creates scheduled_jobs entry (10 min delay)         │    │
│  │    → Skips if pending job already exists (dedup)         │    │
│  │                                                          │    │
│  │  tr_handle_admin_reply (AFTER INSERT on chat_messages)   │    │
│  │    → Sets ai_mode_active = false                         │    │
│  │    → Sets awaiting_admin_response = false                │    │
│  │    → Cancels pending scheduled_jobs                      │    │
│  │    → Updates last_admin_message_at                       │    │
│  │                                                          │    │
│  │  tr_handle_ai_message (AFTER INSERT on chat_messages)    │    │
│  │    → Updates last_ai_message_at                          │    │
│  └──────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
         │                       │                        │
         ▼                       ▼                        ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Supabase Edge Functions                        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │  ai-chat-responder                                      │     │
│  │                                                         │     │
│  │  Actions:                                               │     │
│  │    handle_user_message → Schedule or instant AI reply   │     │
│  │    process_timeout     → Process a timed-out job        │     │
│  │    instant_ai_reply    → Generate AI reply immediately  │     │
│  │                                                         │     │
│  │  Duplicate Prevention:                                  │     │
│  │    - Checks last message sender before generating       │     │
│  │    - Verifies no admin reply during AI generation       │     │
│  │    - Uses scheduled_jobs table for single pending job   │     │
│  └─────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐     │
│  │  ai-timeout-processor (runs every 1 minute via cron)    │     │
│  │                                                         │     │
│  │  1. Fetches pending scheduled_jobs where scheduled_at   │     │
│  │     <= now                                              │     │
│  │  2. Calls process_ai_timeout() RPC for each job         │     │
│  │  3. If thread still needs AI, calls ai-chat-responder   │     │
│  │  4. Handles errors with retry tracking                  │     │
│  └─────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────────┐
│                    Google AI Studio (Gemini)                      │
│                                                                  │
│  Model: gemini-2.0-flash                                         │
│  API: generativelanguage.googleapis.com                          │
│  Response Format: JSON { reply, summary }                        │
└──────────────────────────────────────────────────────────────────┘
```

## Conversation State Machine

```
                    ┌──────────────┐
                    │  IDLE/HUMAN  │
                    │  MODE        │
                    └──────┬───────┘
                           │
                    User sends message
                           │
                           ▼
                    ┌──────────────┐
                    │  AWAITING    │◄──────────────────────┐
                    │  ADMIN       │                        │
                    │  RESPONSE    │                        │
                    └──────┬───────┘                        │
                           │                                │
              ┌────────────┼────────────┐                   │
              │            │            │                   │
     Admin replies   10 min timeout   User sends           │
     (< 10 min)      reached          another msg           │
              │            │            │                   │
              ▼            ▼            │                   │
     ┌──────────────┐ ┌──────────┐    │                   │
     │  HANDLED     │ │ AI MODE  │    │                   │
     │  (back to    │ │ ACTIVE   │────┘                   │
     │   idle)      │ └────┬─────┘                        │
     └──────────────┘      │                               │
                           │                               │
                    ┌──────┼──────┐                        │
                    │      │      │                        │
             Admin    │  User    User sends                │
             replies  │  sends   another msg               │
             (any     │  msg     (AI mode                  │
              time)   │          stays)                    │
                    │      │      │                        │
                    ▼      ▼      ▼                        │
             ┌──────────────┐ ┌──────────────┐             │
             │  HANDLED     │ │ AI RESPONDS  │─────────────┘
             │  (AI mode    │ │ INSTANTLY    │
             │   disabled)  │ │ (no timer)   │
             └──────────────┘ └──────────────┘
```

## Key Design Decisions

### 1. Database-Driven Timers (Not Frontend)
- Timers survive app refresh, server restart, and device changes
- `scheduled_jobs` table stores pending AI timeout jobs
- `pg_cron` (or external cron) processes jobs every minute
- Each job has `scheduled_at` timestamp for precise 10-minute delay

### 2. Duplicate Prevention
- **Multiple user messages**: Only ONE `scheduled_jobs` entry per thread (trigger checks for existing pending job)
- **Admin reply during AI generation**: Final check in `generateAiReply()` queries for admin messages after the triggering user message
- **Concurrent processing**: `SELECT ... FOR UPDATE` in `process_ai_timeout()` prevents double-processing

### 3. AI Mode State Tracking
- `ai_mode_active` on `chat_threads` tracks whether AI has taken over
- Set to `true` when AI responds due to timeout
- Set to `false` when admin sends any message
- Used by Flutter to show "AI typing..." indicator
- Used by React to show "AI MODE" banner and badge

### 4. Instant AI Response Flow
When `ai_mode_active = true` and admin hasn't replied since last AI message:
1. User sends message
2. Flutter's `sendChatMessage()` triggers `chatService.triggerAiResponse()` after sending
3. Edge function receives `action: "handle_user_message"`
4. Detects AI mode is active → calls `generateAiReply()` immediately
5. No timer, no delay — instant response

### 5. Security
- All AI API keys stored in Supabase environment variables (never client-side)
- Edge functions use service role key for database operations
- RLS policies prevent direct client access to `scheduled_jobs`
- Sender types validated at database level (CHECK constraint)
- Admin/sales role verified in edge functions before privileged operations

## Deployment Checklist

### 1. Database
```bash
# Run in Supabase SQL Editor:
# 1. supabase_schema/002_ai_chat_migration.sql
# 2. supabase_schema/003_pg_cron_setup.sql (if using pg_cron)
```

### 2. Edge Functions
```bash
# Deploy from project root:
supabase functions deploy ai-chat-responder
supabase functions deploy ai-timeout-processor

# Set secrets:
supabase secrets set GEMINI_API_KEY=your-key-here
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 3. Cron Job (if not using pg_cron)
Use an external service to POST to:
```
https://<project-ref>.supabase.co/functions/v1/ai-timeout-processor
```
every minute with empty JSON body `{}`.

### 4. Flutter
- Models, service, provider, and UI already updated
- Run `flutter pub get` and rebuild

### 5. React
- Chat.jsx and chat.js already updated
- Run `npm run build` and redeploy

## File Structure

```
final project dani/
├── supabase_schema/
│   ├── 002_ai_chat_migration.sql          # DB schema + triggers + RLS
│   └── 003_pg_cron_setup.sql              # Cron job configuration
├── supabase/functions/
│   ├── ai-chat-responder/
│   │   └── index.ts                        # Main AI handler (Gemini)
│   ├── ai-timeout-processor/
│   │   └── index.ts                        # Cron-based timeout processor
│   └── _shared/
│       └── cors.ts                         # Shared CORS headers
├── mobile_app/lib/
│   ├── models/
│   │   └── chat_models.dart                # ChatThread + ChatMessage (updated)
│   ├── core/
│   │   ├── services/
│   │   │   └── chat_service.dart           # Chat API service (updated)
│   │   └── providers/
│   │       └── app_state_provider.dart     # State management (updated)
│   └── screens/chat/
│       └── user_chat_screen.dart           # Chat UI (updated)
└── web_app_react/src/
    ├── pages/
    │   └── Chat.jsx                        # Admin chat UI (updated)
    └── lib/api/
        └── chat.js                         # Admin chat API (updated)
```

## Scalability Considerations

1. **Indexed queries**: All timestamp and foreign key columns are indexed
2. **Batch processing**: `ai-timeout-processor` processes up to 10 jobs per run
3. **Retry logic**: Failed jobs retry up to 3 times with tracking
4. **Message limits**: Thread queries limited to 100 messages, 30 for AI context
5. **Connection pooling**: Supabase handles connection pooling automatically
6. **Realtime efficiency**: Channels filter by thread_id to minimize payload
