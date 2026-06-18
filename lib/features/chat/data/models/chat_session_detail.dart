import 'chat_message_dto.dart';

/// A single chat session with its full message list
/// (`GET /api/v1/chat/sessions/{id}`).
class ChatSessionDetail {
  const ChatSessionDetail({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.messages,
  });

  final int id;
  final String title;
  final int? userId;
  final DateTime? createdAt;
  final List<ChatMessageDto> messages;

  factory ChatSessionDetail.fromJson(Map<String, dynamic> json) {
    return ChatSessionDetail(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      userId: json['user_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      messages:
          (json['messages'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ChatMessageDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}
