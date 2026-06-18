/// A single stored chat message returned by the chat endpoints.
class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.data,
  });

  final int id;

  /// "user" for the asker, otherwise the assistant/AI reply.
  final String role;
  final String content;
  final DateTime? createdAt;

  /// Structured verdict fields for an assistant message (null for user
  /// messages or older records without it).
  final ChatMessageData? data;

  bool get isUser => role.toLowerCase() == 'user';

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return ChatMessageDto(
      id: json['id'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      data: rawData is Map<String, dynamic>
          ? ChatMessageData.fromJson(rawData)
          : null,
    );
  }
}

/// The structured verdict carried on an assistant message's `data` field.
class ChatMessageData {
  const ChatMessageData({
    required this.verdict,
    required this.verdictLabel,
    required this.productInfo,
    required this.reason,
    required this.pros,
    required this.cons,
    required this.caution,
    required this.recommendation,
    required this.imageBase64,
  });

  final String verdict;
  final String verdictLabel;
  final String productInfo;
  final String reason;
  final String pros;
  final String cons;
  final String caution;
  final String recommendation;

  /// Base64 of the photo this verdict was based on (may be empty).
  final String imageBase64;

  factory ChatMessageData.fromJson(Map<String, dynamic> json) {
    return ChatMessageData(
      verdict: json['verdict'] as String? ?? '',
      verdictLabel: json['verdict_label'] as String? ?? '',
      productInfo: json['product_info'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      pros: json['pros'] as String? ?? '',
      cons: json['cons'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      imageBase64: json['image_base64'] as String? ?? '',
    );
  }
}
