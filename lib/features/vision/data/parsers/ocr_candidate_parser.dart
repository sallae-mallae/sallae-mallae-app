import '../../domain/entities/ocr_candidate.dart';

class OcrCandidateParser {
  const OcrCandidateParser();

  List<OcrCandidate> parse(List<OcrCandidate> candidates) {
    return candidates
        .map(_parseCandidate)
        .where((candidate) => candidate.isValid)
        .toList(growable: false);
  }

  OcrCandidate _parseCandidate(OcrCandidate candidate) {
    final normalizedText = _normalize(candidate.rawText);
    final type = _detectType(normalizedText);
    final confidence = _adjustConfidence(candidate.confidence, type);

    return candidate.copyWith(
      normalizedText: normalizedText,
      type: type,
      confidence: confidence,
    );
  }

  OcrCandidateType _detectType(String text) {
    if (_isDiscountRate(text)) {
      return OcrCandidateType.discountRate;
    }

    if (_isPrice(text)) {
      return OcrCandidateType.price;
    }

    if (_isLikelyBrand(text)) {
      return OcrCandidateType.brand;
    }

    if (_isLikelyProductName(text)) {
      return OcrCandidateType.productName;
    }

    return OcrCandidateType.unknown;
  }

  String _normalize(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _isDiscountRate(String text) {
    return RegExp(r'(^|[^0-9])\d{1,2}\s?%').hasMatch(text);
  }

  bool _isPrice(String text) {
    final hasCurrency = RegExp(
      r'(원|₩|KRW)',
      caseSensitive: false,
    ).hasMatch(text);
    final hasPriceLikeNumber = RegExp(
      r'\d{1,3}(,\d{3})+|\d{4,}',
    ).hasMatch(text);

    return hasCurrency || hasPriceLikeNumber;
  }

  bool _isLikelyBrand(String text) {
    final compactText = text.replaceAll(' ', '');

    return compactText.length >= 2 &&
        compactText.length <= 16 &&
        !RegExp(r'\d').hasMatch(compactText);
  }

  bool _isLikelyProductName(String text) {
    return text.length >= 3 && RegExp(r'[가-힣A-Za-z]').hasMatch(text);
  }

  double _adjustConfidence(double confidence, OcrCandidateType type) {
    final adjustedConfidence = switch (type) {
      OcrCandidateType.price => confidence + 0.1,
      OcrCandidateType.discountRate => confidence + 0.1,
      OcrCandidateType.brand => confidence,
      OcrCandidateType.productName => confidence,
      OcrCandidateType.unknown => confidence - 0.15,
    };

    return adjustedConfidence.clamp(0, 1).toDouble();
  }
}
