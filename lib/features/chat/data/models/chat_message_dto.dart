/// A single stored chat message returned by the chat endpoints.
class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final int id;

  /// "user" for the asker, otherwise the assistant/AI reply.
  final String role;
  final String content;
  final DateTime? createdAt;

  bool get isUser => role.toLowerCase() == 'user';

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      id: json['id'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }
}
