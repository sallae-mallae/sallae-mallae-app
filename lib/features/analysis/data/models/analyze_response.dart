import '../../domain/entities/buy_decision.dart';

class AnalyzeResponse {
  const AnalyzeResponse({
    required this.verdict,
    required this.verdictLabel,
    required this.productInfo,
    required this.reason,
    required this.pros,
    required this.cons,
    required this.caution,
    required this.recommendation,
    required this.caption,
    required this.ragUsed,
    required this.historyId,
  });

  final String verdict;
  final String verdictLabel;
  final String productInfo;
  final String reason;
  final String pros;
  final String cons;
  final String caution;
  final String recommendation;
  final String caption;
  final bool ragUsed;
  final int historyId;

  BuyDecision get decision => BuyDecisionMapper.fromVerdict(verdict);

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      verdict: json['verdict'] as String? ?? '',
      verdictLabel: json['verdict_label'] as String? ?? '',
      productInfo: json['product_info'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      pros: json['pros'] as String? ?? '',
      cons: json['cons'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
      ragUsed: json['rag_used'] as bool? ?? false,
      historyId: json['history_id'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'verdict': verdict,
      'verdict_label': verdictLabel,
      'product_info': productInfo,
      'reason': reason,
      'pros': pros,
      'cons': cons,
      'caution': caution,
      'recommendation': recommendation,
      'caption': caption,
      'rag_used': ragUsed,
      'history_id': historyId,
    };
  }
}
