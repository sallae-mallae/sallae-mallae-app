import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../features/analysis/presentation/widgets/analysis_loading_view.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/bottom_input_bar.dart';
import '../../../shared/widgets/segmented_input_mode.dart';
import '../../analysis/application/analysis_provider.dart';
import '../../speech_input/data/models/speech_input_state.dart';
import '../../speech_input/domain/speech_input_provider.dart';
import '../../vision/domain/vision_provider.dart';
import '../../vision/presentation/models/vision_overlay_state.dart';
import '../../vision/presentation/widgets/camera_vision_overlay.dart';
import '../../voice_output/domain/voice_output_provider.dart';
import '../data/models/camera_state.dart';
import '../domain/camera_provider.dart';

class HomeCameraScreen extends ConsumerStatefulWidget {
  const HomeCameraScreen({super.key});

  @override
  ConsumerState<HomeCameraScreen> createState() => _HomeCameraScreenState();
}

class _HomeCameraScreenState extends ConsumerState<HomeCameraScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _questionController;
  InputMode _selectedInputMode = InputMode.text;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _questionController = TextEditingController();
    _questionController.addListener(_handleQuestionTextChanged);

    Future.microtask(() {
      ref.read(cameraProvider.notifier).initializeCamera();
      ref.read(speechInputProvider.notifier).initialize();
      ref.read(voiceOutputProvider.notifier).initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(ref.read(cameraProvider.notifier).disposeCamera());
      unawaited(ref.read(speechInputProvider.notifier).cancelListening());
      unawaited(ref.read(voiceOutputProvider.notifier).stop());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(cameraProvider.notifier).initializeCamera());
      unawaited(ref.read(speechInputProvider.notifier).initialize());
      unawaited(ref.read(voiceOutputProvider.notifier).initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(ref.read(cameraProvider.notifier).disposeCamera());
    unawaited(ref.read(speechInputProvider.notifier).cancelListening());
    unawaited(ref.read(voiceOutputProvider.notifier).stop());
    _questionController.removeListener(_handleQuestionTextChanged);
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SpeechInputState>(speechInputProvider, (previous, next) {
      if (_questionController.text == next.questionText) {
        return;
      }

      _questionController.value = TextEditingValue(
        text: next.questionText,
        selection: TextSelection.collapsed(offset: next.questionText.length),
      );
    });

    final cameraState = ref.watch(cameraProvider);
    final analysisState = ref.watch(analysisProvider);
    final visionOverlayState = VisionOverlayState.fromContext(
      ref.watch(visionProvider),
    );
    final speechInputState = ref.watch(speechInputProvider);
    final controller = ref.read(cameraProvider.notifier).controller;

    return Scaffold(
      drawer: const AppDrawer(),
      drawerScrimColor: Colors.black.withValues(alpha: 0.62),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: AppSpacing.figmaInputPanelHeight,
                child: _buildCameraLayer(cameraState, controller),
              ),
              if (cameraState.canShowPreview && controller != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.figmaInputPanelHeight,
                  child: CameraVisionOverlay(state: visionOverlayState),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Builder(
                  builder: (context) {
                    return AppTopBar(
                      onMenuPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                ),
              ),
              if (analysisState.isLoading)
                const Positioned.fill(child: AnalysisLoadingView()),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomInputBar(
                  controller: _questionController,
                  speechState: speechInputState,
                  analysisState: analysisState,
                  selectedMode: _selectedInputMode,
                  onModeSelected: _handleInputModeSelected,
                  onToggleListening: () =>
                      ref.read(speechInputProvider.notifier).toggleListening(),
                  onSubmit: _submitQuestion,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleQuestionTextChanged() {
    final text = _questionController.text;
    final currentText = ref.read(speechInputProvider).questionText;

    if (text == currentText) {
      return;
    }

    ref.read(speechInputProvider.notifier).updateQuestionText(text);
  }

  void _handleInputModeSelected(InputMode mode) {
    if (_selectedInputMode == mode) {
      if (mode == InputMode.voice) {
        ref.read(speechInputProvider.notifier).toggleListening();
      }
      return;
    }

    setState(() {
      _selectedInputMode = mode;
    });

    final speechNotifier = ref.read(speechInputProvider.notifier);
    final speechState = ref.read(speechInputProvider);

    if (mode == InputMode.voice) {
      if (!speechState.isListening) {
        speechNotifier.toggleListening();
      }
      return;
    }

    if (speechState.isListening) {
      speechNotifier.toggleListening();
    }
  }

  Future<void> _submitQuestion() async {
    if (ref.read(analysisProvider).isLoading) {
      return;
    }

    final question = _questionController.text.trim();
    final analysisNotifier = ref.read(analysisProvider.notifier);

    if (question.isEmpty) {
      analysisNotifier.failWithMessage('질문을 입력해주세요.');
      return;
    }

    await ref.read(speechInputProvider.notifier).cancelListening();

    final imageFile = await ref
        .read(cameraProvider.notifier)
        .captureRepresentativeImage();

    if (imageFile == null) {
      analysisNotifier.failWithMessage('분석할 이미지를 촬영할 수 없습니다.');
      return;
    }

    await analysisNotifier.analyzeProduct(
      imageFile: imageFile,
      question: question,
      visionContext: ref.read(visionProvider),
    );
  }

  Widget _buildCameraLayer(
    CameraState cameraState,
    CameraController? controller,
  ) {
    if (cameraState.isInitializing) {
      return const _CameraStatusView(message: '카메라를 준비하고 있습니다.');
    }

    if (cameraState.errorMessage != null) {
      return _CameraStatusView(message: cameraState.errorMessage!);
    }

    if (cameraState.canShowPreview && controller != null) {
      return _CameraPreviewFill(controller: controller);
    }

    return const _CameraStatusView(message: '카메라를 준비하고 있습니다.');
  }
}

class _CameraPreviewFill extends StatelessWidget {
  const _CameraPreviewFill({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;

    if (previewSize == null) {
      return const ColoredBox(color: Colors.black);
    }

    return ColoredBox(
      color: Colors.black,
      child: ClipRect(
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(controller),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraStatusView extends StatelessWidget {
  const _CameraStatusView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
