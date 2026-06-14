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
    await dispose();

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
  ) async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      throw StateError('Camera controller is not initialized.');
    }

    if (controller.value.isStreamingImages) {
      return;
    }

    await controller.startImageStream(onAvailable);
  }

  Future<void> stopImageStream() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (!controller.value.isStreamingImages) {
      return;
    }

    await controller.stopImageStream();
  }

  Future<XFile?> takePicture() async {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return null;
    }

    if (controller.value.isTakingPicture) {
      return null;
    }

    return controller.takePicture();
  }

  Future<void> dispose() async {
    final controller = _controller;

    if (controller == null) {
      return;
    }

    if (controller.value.isInitialized && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }

    await controller.dispose();
    _controller = null;
  }
}
