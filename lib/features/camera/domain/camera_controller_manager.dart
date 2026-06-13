import 'package:camera/camera.dart';

class CameraControllerManager {
  CameraController? _controller;

  CameraController? get controller => _controller;

  bool get hasController => _controller != null;

  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<List<CameraDescription>> getAvailableCameras() async {
    return availableCameras();
  }

  CameraDescription? selectBackCamera(List<CameraDescription> cameras) {
    if (cameras.isEmpty) {
      return null;
    }

    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  Future<void> initialize() async {
    final cameras = await getAvailableCameras();
    final selectedCamera = selectBackCamera(cameras);

    if (selectedCamera == null) {
      throw StateError('No available cameras.');
    }

    final controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await controller.initialize();

    _controller = controller;
  }

  Future<void> startImageStream(
    void Function(CameraImage image) onAvailable,
  ) async {}

  Future<void> stopImageStream() async {}

  Future<XFile?> takePicture() async {
    return null;
  }

  Future<void> dispose() async {}
}
