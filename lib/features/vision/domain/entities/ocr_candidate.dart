import 'product_bounding_box.dart';

enum OcrCandidateType { productName, price, discountRate, brand, unknown }

class OcrCandidate {
  const OcrCandidate({
    required this.rawText,
    required this.normalizedText,
    required this.type,
    required this.confidence,
    this.boundingBox,
  });

  final String rawText;
  final String normalizedText;
  final OcrCandidateType type;
  final double confidence;
  final ProductBoundingBox? boundingBox;

  bool get hasText => normalizedText.trim().isNotEmpty;

  bool get isPrice => type == OcrCandidateType.price;

  bool get isDiscountRate => type == OcrCandidateType.discountRate;

  bool get isProductName => type == OcrCandidateType.productName;

  bool get isBrand => type == OcrCandidateType.brand;

  bool get hasUsableConfidence => confidence >= 0.5;

  bool get isValid =>
      hasText &&
      confidence >= 0 &&
      confidence <= 1 &&
      (boundingBox == null || boundingBox!.isValid);

  OcrCandidate copyWith({
    String? rawText,
    String? normalizedText,
    OcrCandidateType? type,
    double? confidence,
    ProductBoundingBox? boundingBox,
    bool clearBoundingBox = false,
  }) {
    return OcrCandidate(
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      type: type ?? this.type,
      confidence: confidence ?? this.confidence,
      boundingBox: clearBoundingBox ? null : boundingBox ?? this.boundingBox,
    );
  }
}
