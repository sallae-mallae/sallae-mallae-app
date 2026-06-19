import 'dart:ui';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../../domain/entities/detected_product.dart';
import '../../domain/entities/product_bounding_box.dart';
import '../../domain/services/object_detection_service.dart';

class MlKitObjectDetectionService implements ObjectDetectionService {
  MlKitObjectDetectionService({ObjectDetector? detector})
    : _detector =
          detector ??
          ObjectDetector(
            options: ObjectDetectorOptions(
              // We sample ~1 frame/sec rather than a live video stream, so
              // single-image mode runs full detection on every sampled frame
              // (stream mode trades per-frame accuracy for tracking we don't
              // use) — this captures objects far more reliably.
              mode: DetectionMode.single,
              classifyObjects: true,
              multipleObjects: true,
            ),
          );

  final ObjectDetector _detector;

  @override
  Future<List<DetectedProduct>> detectProducts({
    required InputImage image,
    required Size imageSize,
  }) async {
    final objects = await _detector.processImage(image);

    return objects
        .map((object) => _mapDetectedObject(object, imageSize))
        .where((product) => product.isValid)
        .toList(growable: false);
  }

  @override
  Future<void> dispose() {
    return _detector.close();
  }

  DetectedProduct _mapDetectedObject(DetectedObject object, Size imageSize) {
    final labels = object.labels
        .map((label) => label.text)
        .toList(growable: false);

    final confidence = object.labels.isEmpty
        ? 1.0
        : object.labels
              .map((label) => label.confidence)
              .reduce(
                (highest, current) => current > highest ? current : highest,
              );

    return DetectedProduct(
      boundingBox: ProductBoundingBox.fromLTRB(
        left: object.boundingBox.left,
        top: object.boundingBox.top,
        right: object.boundingBox.right,
        bottom: object.boundingBox.bottom,
        imageWidth: imageSize.width,
        imageHeight: imageSize.height,
      ),
      confidence: confidence,
      labels: labels,
      trackingId: object.trackingId,
    );
  }
}
