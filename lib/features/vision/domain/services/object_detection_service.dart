import 'dart:ui';

import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../entities/detected_product.dart';

abstract class ObjectDetectionService {
  Future<List<DetectedProduct>> detectProducts({
    required InputImage image,
    required Size imageSize,
  });

  Future<void> dispose();
}
