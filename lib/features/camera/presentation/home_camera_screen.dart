import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../data/models/camera_state.dart';
import '../domain/camera_provider.dart';

class HomeCameraScreen extends ConsumerStatefulWidget {
  const HomeCameraScreen({super.key});

  @override
  ConsumerState<HomeCameraScreen> createState() => _HomeCameraScreenState();
}

class _HomeCameraScreenState extends ConsumerState<HomeCameraScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(cameraProvider.notifier).initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final controller = ref.read(cameraProvider.notifier).controller;

    return Scaffold(body: SafeArea(child: _buildBody(cameraState, controller)));
  }

  Widget _buildBody(CameraState cameraState, CameraController? controller) {
    if (cameraState.isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cameraState.errorMessage != null) {
      return Center(
        child: Text(
          cameraState.errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (cameraState.canShowPreview && controller != null) {
      return CameraPreview(controller);
    }

    return const Center(
      child: Text(
        '카메라를 준비하고 있습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
