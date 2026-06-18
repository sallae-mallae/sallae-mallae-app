/// One entry of `GET /api/v1/chat/sessions` (a chat session without messages).
class ChatSessionSummary {
  const ChatSessionSummary({
    required this.id,
    required this.title,
    required this.userId,
    required this.messageCount,
    required this.createdAt,
  });

  final int id;
  final String title;
  final int? userId;
  final int messageCount;
  final DateTime? createdAt;

  factory ChatSessionSummary.fromJson(Map<String, dynamic> json) {
    return ChatSessionSummary(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      userId: json['user_id'] as int?,
      messageCount: json['message_count'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}

/// Paged response of `GET /api/v1/chat/sessions`.
class ChatSessionList {
  const ChatSessionList({required this.items, required this.total});

  final List<ChatSessionSummary> items;
  final int total;

  factory ChatSessionList.fromJson(Map<String, dynamic> json) {
    return ChatSessionList(
      items:
          (json['items'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ChatSessionSummary.fromJson)
              .toList(growable: false) ??
          const [],
      total: json['total'] as int? ?? 0,
    );
  }
}
