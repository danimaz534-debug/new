class ChatThread {
  ChatThread({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.aiModeActive,
    required this.awaitingAdminResponse,
  });

  final String id;
  final String userId;
  final DateTime? createdAt;
  final bool aiModeActive;
  final bool awaitingAdminResponse;

  factory ChatThread.fromMap(Map<String, dynamic> map) {
    return ChatThread(
      id: map['id'].toString(),
      userId: (map['user_id'] ?? '').toString(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
      aiModeActive: map['ai_mode_active'] == true,
      awaitingAdminResponse: map['awaiting_admin_response'] == true,
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderType,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String senderType;
  final String message;
  final DateTime? createdAt;

  bool get isUser => senderType == 'user';
  bool get isAI => senderType == 'ai';
  bool get isAdmin => senderType == 'sales' || senderType == 'admin';

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'].toString(),
      threadId: (map['thread_id'] ?? '').toString(),
      senderType: (map['sender_type'] ?? 'user').toString(),
      message: (map['message'] ?? '').toString(),
      createdAt: map['created_at'] == null
          ? null
          : DateTime.tryParse(map['created_at'].toString()),
    );
  }
}
