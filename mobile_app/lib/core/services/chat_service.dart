import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/chat_models.dart';

class ChatService {
  ChatService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  Future<ChatThread?> ensureThread() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final result = await _client.rpc('ensure_chat_thread');
    return ChatThread.fromMap(Map<String, dynamic>.from(result as Map));
  }

  Future<List<ChatMessage>> fetchMessages(String threadId) async {
    final response = await _client
        .from('chat_messages')
        .select('*')
        .eq('thread_id', threadId)
        .order('created_at');

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
}
