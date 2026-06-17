import '../../../vision/domain/entities/frame_quality.dart';
import '../../../vision/domain/entities/ocr_candidate.dart';
import '../../../vision/domain/entities/vision_context.dart';
import '../models/context_input.dart';

class VisionContextInputMapper {
  const VisionContextInputMapper();

  ContextInput map(VisionContext context, {String? purpose}) {
    final category = _pickCategory(context);
    final price = _pickPrice(context.ocrCandidates);
    final condition = _mapCondition(context.frameQuality);

    return ContextInput(
      category: category,
      price: price,
      purpose: _blankToNull(purpose),
      condition: condition,
      criteria: _buildCriteria(context, category: category, price: price),
    );
  }

  String? _pickCategory(VisionContext context) {
    final detectedProducts =
        context.detectedProducts
            .where((product) => product.hasUsableConfidence && product.hasLabel)
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));
    final detectedLabel = detectedProducts
        .map((product) => product.primaryLabel)
        .whereType<String>()
        .map(_blankToNull)
        .whereType<String>()
        .firstOrNull;

    if (detectedLabel != null) {
      return detectedLabel;
    }

    final productName = _bestTextCandidate(
      context.ocrCandidates,
      OcrCandidateType.productName,
    );

    if (productName != null) {
      return productName;
    }

    return _bestTextCandidate(context.ocrCandidates, OcrCandidateType.brand);
  }

  String? _pickPrice(List<OcrCandidate> candidates) {
    return _bestTextCandidate(candidates, OcrCandidateType.price);
  }

  String? _bestTextCandidate(
    List<OcrCandidate> candidates,
    OcrCandidateType type,
  ) {
    final typedCandidates =
        candidates
            .where((candidate) => candidate.type == type && candidate.hasText)
            .toList()
          ..sort((a, b) => b.confidence.compareTo(a.confidence));

    if (typedCandidates.isEmpty) {
      return null;
    }

    return _blankToNull(typedCandidates.first.normalizedText);
  }

  ProductConditionInput? _mapCondition(FrameQuality quality) {
    if (quality.canSuggestCapture) {
      return ProductConditionInput.good;
    }

    if (quality.canAnalyzeText || quality.isStable) {
      return ProductConditionInput.normal;
    }

    if (quality.shakeStatus == ShakeStatus.unknown &&
        quality.brightnessScore == 0 &&
        quality.blurScore == 0 &&
        quality.focusScore == 0) {
      return null;
    }

    return ProductConditionInput.poor;
  }

  List<String> _buildCriteria(
    VisionContext context, {
    required String? category,
    required String? price,
  }) {
    final criteria = <String>{
      if (price != null) '가격',
      if (category != null) '상품 종류',
      if (context.frameQuality.canSuggestCapture) '상태',
      if (context.detectedProducts.isNotEmpty) '상품 영역',
      if (context.ocrCandidates.any((candidate) => candidate.isBrand)) '브랜드',
    };

    return criteria.toList(growable: false);
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();

    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
