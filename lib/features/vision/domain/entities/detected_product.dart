import 'product_bounding_box.dart';

class DetectedProduct {
  const DetectedProduct({
    required this.boundingBox,
    required this.confidence,
    this.labels = const [],
    this.trackingId,
  });

  final ProductBoundingBox boundingBox;
  final double confidence;
  final List<String> labels;
  final int? trackingId;

  String? get primaryLabel => labels.isEmpty ? null : labels.first;

  bool get hasLabel => labels.isNotEmpty;

  bool get hasUsableConfidence => confidence >= 0.5;

  bool get hasHighConfidence => confidence >= 0.75;

  bool get isValid => boundingBox.isValid && confidence >= 0 && confidence <= 1;

  DetectedProduct copyWith({
    ProductBoundingBox? boundingBox,
    double? confidence,
    List<String>? labels,
    int? trackingId,
    bool clearTrackingId = false,
  }) {
    return DetectedProduct(
      boundingBox: boundingBox ?? this.boundingBox,
      confidence: confidence ?? this.confidence,
      labels: labels ?? this.labels,
      trackingId: clearTrackingId ? null : trackingId ?? this.trackingId,
    );
  }
}
