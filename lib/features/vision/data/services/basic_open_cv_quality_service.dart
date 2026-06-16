import 'package:camera/camera.dart';

import '../../domain/entities/frame_quality.dart';
import '../../domain/services/open_cv_quality_service.dart';

class BasicOpenCvQualityService implements OpenCvQualityService {
  const BasicOpenCvQualityService();

  @override
  Future<FrameQuality> inspectFrame(CameraImage image) async {
    final brightnessScore = _estimateBrightnessScore(image);
    final blurScore = _estimateBlurScore(image);
    final focusScore = blurScore;
    final isReadable = _isReadable(
      brightnessScore: brightnessScore,
      blurScore: blurScore,
      width: image.width,
      height: image.height,
    );

    return FrameQuality(
      brightnessScore: brightnessScore,
      blurScore: blurScore,
      focusScore: focusScore,
      shakeStatus: ShakeStatus.unknown,
      isReadable: isReadable,
    );
  }

  @override
  Future<void> dispose() async {}

  double _estimateBrightnessScore(CameraImage image) {
    if (image.planes.isEmpty || image.planes.first.bytes.isEmpty) {
      return 0;
    }

    final luminanceBytes = image.planes.first.bytes;
    var total = 0;
    final step = luminanceBytes.length < 4096
        ? 1
        : luminanceBytes.length ~/ 4096;

    for (var index = 0; index < luminanceBytes.length; index += step) {
      total += luminanceBytes[index];
    }

    final sampleCount = (luminanceBytes.length / step).ceil();

    return (total / sampleCount / 255).clamp(0, 1).toDouble();
  }

  double _estimateBlurScore(CameraImage image) {
    if (image.planes.isEmpty || image.planes.first.bytes.length < 3) {
      return 0;
    }

    final luminanceBytes = image.planes.first.bytes;
    var edgeTotal = 0;
    var samples = 0;
    final step = luminanceBytes.length < 4096
        ? 2
        : luminanceBytes.length ~/ 4096;

    for (var index = step; index < luminanceBytes.length; index += step) {
      edgeTotal += (luminanceBytes[index] - luminanceBytes[index - step]).abs();
      samples++;
    }

    if (samples == 0) {
      return 0;
    }

    return (edgeTotal / samples / 32).clamp(0, 1).toDouble();
  }

  bool _isReadable({
    required double brightnessScore,
    required double blurScore,
    required int width,
    required int height,
  }) {
    final hasEnoughPixelsForTargetCrop = width >= 768 && height >= 768;

    return hasEnoughPixelsForTargetCrop &&
        brightnessScore >= 0.45 &&
        blurScore >= 0.45;
  }
}
