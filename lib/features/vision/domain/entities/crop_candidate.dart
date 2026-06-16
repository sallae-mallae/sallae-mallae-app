import 'product_bounding_box.dart';

class CropCandidate {
  const CropCandidate({
    required this.sourceBox,
    required this.cropBox,
    required this.score,
    required this.priority,
  });

  final ProductBoundingBox sourceBox;
  final ProductBoundingBox cropBox;
  final double score;
  final int priority;

  bool get isValid => sourceBox.isValid && cropBox.isValid && score >= 0;

  bool get isPrimary => priority == 0;

  CropCandidate copyWith({
    ProductBoundingBox? sourceBox,
    ProductBoundingBox? cropBox,
    double? score,
    int? priority,
  }) {
    return CropCandidate(
      sourceBox: sourceBox ?? this.sourceBox,
      cropBox: cropBox ?? this.cropBox,
      score: score ?? this.score,
      priority: priority ?? this.priority,
    );
  }
}
