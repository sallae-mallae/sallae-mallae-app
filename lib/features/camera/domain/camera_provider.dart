import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../vision/domain/vision_provider.dart';
import '../data/models/camera_state.dart';
import '../data/policies/frame_sampling_policy.dart';
import 'camera_controller_manager.dart';

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);

class CameraNotifier extends Notifier<CameraState> {
  final CameraControllerManager _manager = CameraControllerManager();
  final FrameSamplingPolicy _samplingPolicy = const FrameSamplingPolicy();

  DateTime? _lastProcessedAt;
  bool _isProcessingFrame = false;

  CameraController? get controller => _manager.controller;

  @override
  CameraState build() {
    ref.onDispose(() {
      unawaited(_manager.dispose());
      unawaited(ref.read(visionProvider.notifier).disposeVision());
    });

    return const CameraState.initial();
  }

  Future<void> initializeCamera() async {
    state = state.copyWith(
      isInitializing: true,
      isInitialized: false,
      isStreaming: false,
      clearErrorMessage: true,
    );

    try {
      await _manager.initialize();

      state = state.copyWith(
        isInitializing: false,
        isInitialized: true,
        clearErrorMessage: true,
      );

      await startImageStream();
    } catch (error) {
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        isStreaming: false,
        errorMessage: '카메라를 초기화할 수 없습니다.',
      );
    }
  }

  Future<void> startImageStream() async {
    if (!state.canStartStreaming) {
      return;
    }

    await _manager.startImageStream(_handleCameraImage);

    state = state.copyWith(isStreaming: true);
  }

  Future<void> stopImageStream() async {
    if (!state.canStopStreaming) {
      return;
    }

    await _manager.stopImageStream();

    state = state.copyWith(isStreaming: false);
  }

  Future<XFile?> takePicture() async {
    if (!state.canTakePicture) {
      return null;
    }

    state = state.copyWith(isTakingPicture: true);

    try {
      return await _manager.takePicture();
    } finally {
      state = state.copyWith(isTakingPicture: false);
    }
  }

  Future<XFile?> captureRepresentativeImage() async {
    final wasStreaming = state.isStreaming;

    if (wasStreaming) {
      await stopImageStream();
    }

    try {
      return await takePicture();
    } finally {
      if (wasStreaming && state.isInitialized) {
        await startImageStream();
      }
    }
  }

  Future<void> disposeCamera() async {
    await _manager.dispose();
    await ref.read(visionProvider.notifier).disposeVision();

    _lastProcessedAt = null;
    _isProcessingFrame = false;
    state = const CameraState.initial();
  }

  void _handleCameraImage(CameraImage image) {
    final now = DateTime.now();
    final visionNotifier = ref.read(visionProvider.notifier);

    final shouldProcess = _samplingPolicy.shouldProcess(
      now: now,
      lastProcessedAt: _lastProcessedAt,
      isProcessing: _isProcessingFrame || visionNotifier.isProcessing,
    );

    if (!shouldProcess) {
      return;
    }

    final camera = _manager.controller?.description;

    if (camera == null) {
      return;
    }

    _isProcessingFrame = true;
    _lastProcessedAt = now;
    unawaited(
      visionNotifier
          .analyzeCameraImage(image: image, camera: camera)
          .whenComplete(() => _isProcessingFrame = false),
    );
  }
}
