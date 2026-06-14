import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> disposeCamera() async {
    await _manager.dispose();

    _lastProcessedAt = null;
    _isProcessingFrame = false;
    state = const CameraState.initial();
  }

  void _handleCameraImage(CameraImage _) {
    final now = DateTime.now();

    final shouldProcess = _samplingPolicy.shouldProcess(
      now: now,
      lastProcessedAt: _lastProcessedAt,
      isProcessing: _isProcessingFrame,
    );

    if (!shouldProcess) {
      return;
    }

    _isProcessingFrame = true;
    _lastProcessedAt = now;
    _isProcessingFrame = false;
  }
}
