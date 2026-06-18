import '../../analysis/domain/entities/analysis_result.dart';
import '../../analysis/domain/entities/buy_decision.dart';
import '../data/models/chat_message_dto.dart';

/// Builds an [AnalysisResult] from a message's structured `data` field.
AnalysisResult analysisResultFromMessageData(ChatMessageData data) {
  return AnalysisResult(
    decision: BuyDecisionMapper.fromVerdict(data.verdict),
    verdict: data.verdict,
    verdictLabel: data.verdictLabel,
    productInfo: data.productInfo,
    reason: data.reason,
    pros: data.pros,
    cons: data.cons,
    caution: data.caution,
    recommendation: data.recommendation,
  );
}

/// Rebuilds a structured [AnalysisResult] from a stored assistant message.
///
/// The chat API stores the verdict as a single text blob formatted with emoji
/// section markers (👍 장점, 👎 단점, ⚠ 주의, 💡 추천). This parses those back so a
/// loaded conversation shows the same short bubble + "자세히" detail as a live
/// one. It is best-effort: any section that is missing simply stays empty.
AnalysisResult analysisResultFromContent(String content) {
  final text = content.trim();

  const prosMark = '👍';
  const consMark = '👎';
  const cautionMark = '⚠';
  const recMark = '💡';

  final markerIndexes = <int>[];
  for (final mark in [prosMark, consMark, cautionMark, recMark]) {
    final i = text.indexOf(mark);
    if (i >= 0) markerIndexes.add(i);
  }
  markerIndexes.sort();

  String section(String mark) {
    final start = text.indexOf(mark);
    if (start < 0) {
      return '';
    }
    var end = text.length;
    for (final i in markerIndexes) {
      if (i > start && i < end) {
        end = i;
      }
    }
    var body = text.substring(start + mark.length, end);
    // Drop a leading variation selector / whitespace, then an optional
    // "좋은 점:" style label.
    body = body.replaceFirst(RegExp(r'^[\s️]+'), '');
    body = body.replaceFirst(RegExp(r'^[가-힣\s]{0,8}[:：]\s*'), '');
    return body.trim();
  }

  final introEnd = markerIndexes.isEmpty ? text.length : markerIndexes.first;
  final intro = text.substring(0, introEnd).trim();

  String verdictLabel;
  String reason;
  final bang = intro.indexOf('!');
  if (bang > 0 && bang <= 8) {
    verdictLabel = intro.substring(0, bang).trim();
    reason = intro.substring(bang + 1).trim();
  } else {
    final match = RegExp(
      r'^(살래요|말래요|고민해요|글쎄요|[^\s!.,]{1,6})',
    ).firstMatch(intro);
    verdictLabel = match?.group(0) ?? '';
    reason = verdictLabel.isEmpty
        ? intro
        : intro.substring(verdictLabel.length).trim();
  }

  final BuyDecision decision;
  if (verdictLabel.contains('살래') || intro.startsWith('살래')) {
    decision = BuyDecision.buy;
  } else if (verdictLabel.contains('말래') || intro.startsWith('말래')) {
    decision = BuyDecision.avoid;
  } else if (verdictLabel.contains('고민')) {
    decision = BuyDecision.hold;
  } else {
    decision = BuyDecision.unknown;
  }

  return AnalysisResult(
    decision: decision,
    verdict: '',
    verdictLabel: verdictLabel,
    productInfo: '',
    reason: reason,
    pros: section(prosMark),
    cons: section(consMark),
    caution: section(cautionMark),
    recommendation: section(recMark),
  );
}
