import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../features/analysis/presentation/widgets/analysis_loading_view.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/bottom_input_bar.dart';
import '../../../shared/widgets/segmented_input_mode.dart';
import '../../analysis/application/analysis_provider.dart';
import '../../analysis/application/analysis_state.dart';
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
  bool _isDrawerOpen = false;
  AppDrawerSection _section = AppDrawerSection.camera;

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

    final drawerWidth = _drawerWidth(context);

    return Scaffold(
      body: Stack(
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(color: AppColors.cardWhite),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppDrawer(
                width: drawerWidth,
                selectedSection: _section,
                onSectionSelected: _selectSection,
                onOpenSettings: _openSettings,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              _isDrawerOpen ? drawerWidth : 0,
              0,
              0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(_isDrawerOpen ? 32 : 0),
              ),
              boxShadow: _isDrawerOpen
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(-8, 0),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(_isDrawerOpen ? 32 : 0),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _section == AppDrawerSection.history
                    ? _HistorySectionView(
                        key: const ValueKey(AppDrawerSection.history),
                        onMenuPressed: _toggleDrawer,
                        onTapArea: _handleCameraAreaTap,
                      )
                    : _HomeCameraBody(
                        key: const ValueKey(AppDrawerSection.camera),
                        cameraState: cameraState,
                        controller: controller,
                        visionOverlayState: visionOverlayState,
                        analysisState: analysisState,
                        speechInputState: speechInputState,
                        questionController: _questionController,
                        selectedInputMode: _selectedInputMode,
                        onMenuPressed: _toggleDrawer,
                        onModeSelected: _handleInputModeSelected,
                        onToggleListening: () => ref
                            .read(speechInputProvider.notifier)
                            .toggleListening(),
                        onSubmit: _submitQuestion,
                        onTapCameraArea: _handleCameraAreaTap,
                        buildCameraLayer: _buildCameraLayer,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _drawerWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.68;
    return width.clamp(264.0, 316.0).toDouble();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  void _closeDrawer() {
    if (!_isDrawerOpen) {
      return;
    }

    setState(() {
      _isDrawerOpen = false;
    });
  }

  void _handleCameraAreaTap() {
    FocusScope.of(context).unfocus();
    _closeDrawer();
  }

  void _selectSection(AppDrawerSection section) {
    if (_section != section) {
      setState(() {
        _section = section;
      });
    }
    _closeDrawer();
  }

  void _openSettings() {
    _closeDrawer();
    context.go(RoutePaths.settings);
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
}

class _HistorySectionView extends StatelessWidget {
  const _HistorySectionView({
    required this.onMenuPressed,
    required this.onTapArea,
    super.key,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onTapArea;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapArea,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.screenBase,
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.only(top: AppSpacing.topBarHeight + 10),
                  child: Center(
                    child: Padding(
                      padding: AppSpacing.screen,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 56,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            '최근 판단',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            '분석 기록은 이후 단계에서 표시됩니다.',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppTopBar(onMenuPressed: onMenuPressed),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCameraBody extends StatelessWidget {
  const _HomeCameraBody({
    required this.cameraState,
    required this.controller,
    required this.visionOverlayState,
    required this.analysisState,
    required this.speechInputState,
    required this.questionController,
    required this.selectedInputMode,
    required this.onMenuPressed,
    required this.onModeSelected,
    required this.onToggleListening,
    required this.onSubmit,
    required this.buildCameraLayer,
    required this.onTapCameraArea,
    super.key,
  });

  final CameraState cameraState;
  final CameraController? controller;
  final VisionOverlayState visionOverlayState;
  final AnalysisState analysisState;
  final SpeechInputState speechInputState;
  final TextEditingController questionController;
  final InputMode selectedInputMode;
  final VoidCallback onMenuPressed;
  final ValueChanged<InputMode> onModeSelected;
  final VoidCallback onToggleListening;
  final VoidCallback onSubmit;
  final VoidCallback onTapCameraArea;
  final Widget Function(CameraState, CameraController?) buildCameraLayer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapWhenDrawerOpen,
      child: DecoratedBox(
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
                child: buildCameraLayer(cameraState, controller),
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
                child: AppTopBar(onMenuPressed: onMenuPressed),
              ),
              if (analysisState.isLoading)
                const Positioned.fill(child: AnalysisLoadingView()),
              Align(
                alignment: Alignment.bottomCenter,
                child: BottomInputBar(
                  controller: questionController,
                  speechState: speechInputState,
                  analysisState: analysisState,
                  selectedMode: selectedInputMode,
                  onModeSelected: onModeSelected,
                  onToggleListening: onToggleListening,
                  onSubmit: onSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
