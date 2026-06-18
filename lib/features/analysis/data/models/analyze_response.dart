import '../../../chat/data/models/chat_message_dto.dart';
import '../../domain/entities/buy_decision.dart';

/// Response of `POST /api/v1/chat/analyze`.
class AnalyzeResponse {
  const AnalyzeResponse({
    required this.sessionId,
    required this.verdict,
    required this.verdictLabel,
    required this.productInfo,
    required this.reason,
    required this.pros,
    required this.cons,
    required this.caution,
    required this.recommendation,
    required this.proMode,
    required this.imageReused,
    required this.messages,
  });

  final int sessionId;
  final String verdict;
  final String verdictLabel;
  final String productInfo;
  final String reason;
  final String pros;
  final String cons;
  final String caution;
  final String recommendation;
  final bool proMode;
  final bool imageReused;
  final List<ChatMessageDto> messages;

  BuyDecision get decision => BuyDecisionMapper.fromVerdict(verdict);

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      sessionId: json['session_id'] as int? ?? 0,
      verdict: json['verdict'] as String? ?? '',
      verdictLabel: json['verdict_label'] as String? ?? '',
      productInfo: json['product_info'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      pros: json['pros'] as String? ?? '',
      cons: json['cons'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      proMode: json['pro_mode'] as bool? ?? false,
      imageReused: json['image_reused'] as bool? ?? false,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(ChatMessageDto.fromJson)
              .toList(growable: false) ??
          const [],
    );
  }
}
