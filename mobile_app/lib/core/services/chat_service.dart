import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/chat_models.dart';

class ChatService {
  ChatService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<ChatThread?> ensureThread() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final result = await _client.rpc('ensure_chat_thread');
      return ChatThread.fromMap(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      try {
        final existing = await _client
            .from('chat_threads')
            .select('*')
            .eq('user_id', user.id)
            .maybeSingle();

        if (existing != null) {
          return ChatThread.fromMap(Map<String, dynamic>.from(existing as Map));
        }

        final response = await _client
            .from('chat_threads')
            .insert({
              'user_id': user.id,
            })
            .select()
            .single();

        return ChatThread.fromMap(Map<String, dynamic>.from(response as Map));
      } catch (fallbackError) {
        debugPrint('Error ensuring chat thread: $fallbackError');
        return null;
      }
    }
  }

  Future<ChatThread?> fetchThread(String threadId) async {
    try {
      final response = await _client
          .from('chat_threads')
          .select('*')
          .eq('id', threadId)
          .single();
      return ChatThread.fromMap(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('Error fetching thread: $e');
      return null;
    }
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final response = await _client
        .from('chat_messages')
        .select('*')
        .eq('thread_id', threadId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => ChatMessage.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> sendMessage({
    required String threadId,
    required String message,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Create an account to chat with sales.');
    }

    await _client.from('chat_messages').insert({
      'thread_id': threadId,
      'sender_id': user.id,
      'sender_type': 'user',
      'message': message.trim(),
    });
  }

  Future<void> triggerAiResponse(String threadId) async {
    try {
      await _client.functions.invoke('ai-chat-responder', body: {
        'action': 'instant_ai_reply',
        'thread_id': threadId,
      });
    } catch (e) {
      debugPrint('Error triggering AI response: $e');
    }
  }
}
