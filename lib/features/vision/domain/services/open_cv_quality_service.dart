import 'package:camera/camera.dart';

import '../entities/frame_quality.dart';

abstract class OpenCvQualityService {
  Future<FrameQuality> inspectFrame(CameraImage image);

  Future<void> dispose();
}
