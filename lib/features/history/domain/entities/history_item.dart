import '../../../analysis/domain/entities/analysis_result.dart';
import '../../../analysis/domain/entities/buy_decision.dart';
import '../../../vision/domain/entities/vision_context.dart';

/// A single saved analysis result kept in the local history.
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.question,
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
    required this.imagePath,
    required this.ocrCandidates,
    required this.qualityScore,
    required this.historyId,
    required this.createdAt,
  });

  final String id;
  final String question;
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
  final String? imagePath;
  final List<String> ocrCandidates;
  final double qualityScore;
  final int historyId;
  final DateTime createdAt;

  BuyDecision get decision => BuyDecisionMapper.fromVerdict(verdict);

  /// Builds a history entry from a successful analysis together with the
  /// question, captured image path and the vision context behind it.
  factory HistoryItem.fromResult({
    required AnalysisResult result,
    required String question,
    required String? imagePath,
    required VisionContext visionContext,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    final ocrCandidates = visionContext.ocrCandidates
        .where((candidate) => candidate.hasText)
        .map((candidate) => candidate.normalizedText)
        .toList();

    return HistoryItem(
      id: timestamp.microsecondsSinceEpoch.toString(),
      question: question,
      verdict: result.verdict,
      verdictLabel: result.verdictLabel,
      productInfo: result.productInfo,
      reason: result.reason,
      pros: result.pros,
      cons: result.cons,
      caution: result.caution,
      recommendation: result.recommendation,
      caption: result.caption,
      ragUsed: result.ragUsed,
      imagePath: imagePath,
      ocrCandidates: ocrCandidates,
      qualityScore: _qualityScoreOf(visionContext),
      historyId: result.historyId,
      createdAt: timestamp,
    );
  }

  static double _qualityScoreOf(VisionContext context) {
    final quality = context.frameQuality;
    final scores = [
      quality.brightnessScore,
      quality.blurScore,
      quality.focusScore,
    ];
    final sum = scores.fold<double>(0, (total, score) => total + score);
    return sum / scores.length;
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
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
      imagePath: json['image_path'] as String?,
      ocrCandidates:
          (json['ocr_candidates'] as List<dynamic>?)
              ?.map((value) => value as String)
              .toList() ??
          const [],
      qualityScore: (json['quality_score'] as num?)?.toDouble() ?? 0,
      historyId: json['history_id'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
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
      'image_path': imagePath,
      'ocr_candidates': ocrCandidates,
      'quality_score': qualityScore,
      'history_id': historyId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
