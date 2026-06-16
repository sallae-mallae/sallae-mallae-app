import '../../data/models/analyze_response.dart';
import 'buy_decision.dart';

class AnalysisResult {
  const AnalysisResult({
    required this.decision,
    required this.verdict,
    required this.verdictLabel,
    required this.reason,
    required this.caution,
    required this.recommendation,
    required this.caption,
    required this.ragUsed,
    required this.historyId,
  });

  final BuyDecision decision;
  final String verdict;
  final String verdictLabel;
  final String reason;
  final String caution;
  final String recommendation;
  final String caption;
  final bool ragUsed;
  final int historyId;

  factory AnalysisResult.fromResponse(AnalyzeResponse response) {
    return AnalysisResult(
      decision: response.decision,
      verdict: response.verdict,
      verdictLabel: response.verdictLabel,
      reason: response.reason,
      caution: response.caution,
      recommendation: response.recommendation,
      caption: response.caption,
      ragUsed: response.ragUsed,
      historyId: response.historyId,
    );
  }
}
