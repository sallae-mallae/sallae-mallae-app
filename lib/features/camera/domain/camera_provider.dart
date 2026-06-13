import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/camera_state.dart';
import 'camera_controller_manager.dart';

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);

class CameraNotifier extends Notifier<CameraState> {
  final CameraControllerManager _manager = CameraControllerManager();

  CameraController? get controller => _manager.controller;

  @override
  CameraState build() {
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
}
