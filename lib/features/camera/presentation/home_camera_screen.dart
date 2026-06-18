import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../features/analysis/domain/entities/analysis_result.dart';
import '../../../features/analysis/presentation/widgets/analysis_chat_view.dart';
import '../../../features/analysis/presentation/widgets/analysis_result_view.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_top_bar.dart';
import '../../../shared/widgets/bottom_input_bar.dart';
import '../../../shared/widgets/segmented_input_mode.dart';
import '../../analysis/application/analysis_provider.dart';
import '../../analysis/application/analysis_state.dart';
import '../../auth/application/auth_provider.dart';
import '../../history/application/history_provider.dart';
import '../../history/application/server_history_provider.dart';
import '../../history/domain/entities/history_item.dart';
import '../../history/presentation/widgets/history_section.dart';
import '../../settings/application/app_settings_provider.dart';
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
  late final CameraNotifier _cameraNotifier;
  late final SpeechInputNotifier _speechNotifier;
  late final VoiceOutputNotifier _voiceNotifier;
  InputMode _selectedInputMode = InputMode.text;
  bool _isDrawerOpen = false;
  AppDrawerSection _section = AppDrawerSection.camera;
  final List<ChatMessage> _messages = <ChatMessage>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _questionController = TextEditingController();
    _questionController.addListener(_handleQuestionTextChanged);
    _cameraNotifier = ref.read(cameraProvider.notifier);
    _speechNotifier = ref.read(speechInputProvider.notifier);
    _voiceNotifier = ref.read(voiceOutputProvider.notifier);

    Future.microtask(() {
      _cameraNotifier.initializeCamera();
      _speechNotifier.initialize();
      _voiceNotifier.initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(_cameraNotifier.disposeCamera());
      unawaited(_speechNotifier.cancelListening());
      unawaited(_voiceNotifier.stop());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_cameraNotifier.initializeCamera());
      unawaited(_speechNotifier.initialize());
      unawaited(_voiceNotifier.initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_cameraNotifier.disposeCamera());
    unawaited(_speechNotifier.cancelListening());
    unawaited(_voiceNotifier.stop());
    _questionController.removeListener(_handleQuestionTextChanged);
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SpeechInputState>(speechInputProvider, (previous, next) {
      if (_questionController.text != next.questionText) {
        _questionController.value = TextEditingValue(
          text: next.questionText,
          selection: TextSelection.collapsed(offset: next.questionText.length),
        );
      }

      final wasTriggered = previous?.autoSubmitTriggered ?? false;
      if (next.autoSubmitTriggered && !wasTriggered) {
        ref.read(speechInputProvider.notifier).consumeAutoSubmit();
        if (ref.read(appSettingsProvider).voiceAutoSend) {
          unawaited(_submitQuestion());
        }
      }
    });

    ref.listen<AnalysisState>(analysisProvider, (previous, next) {
      if (next.status == previous?.status) {
        return;
      }

      if (next.status == AnalysisStatus.success && next.result != null) {
        _onAnalysisSuccess(next.result!);
      } else if (next.status == AnalysisStatus.failure) {
        _onAnalysisFailure(next.errorMessage);
      }
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
      resizeToAvoidBottomInset: false,
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
                onOpenProfile: _openProfile,
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
                        messages: List<ChatMessage>.of(_messages),
                        onShowDetail: _showResultDetail,
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
    context.push(RoutePaths.settings);
  }

  void _openProfile() {
    _closeDrawer();
    context.push(RoutePaths.myPage);
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

    setState(() => _messages.add(ChatMessage.user(question)));
    _questionController.clear();
    ref.read(speechInputProvider.notifier).updateQuestionText('');

    await ref.read(speechInputProvider.notifier).cancelListening();

    final imageFile = await ref
        .read(cameraProvider.notifier)
        .captureRepresentativeImage();

    if (imageFile == null) {
      analysisNotifier.failWithMessage('분석할 이미지를 촬영할 수 없습니다.');
      return;
    }

    final visionContext = ref.read(visionProvider);
    final settings = ref.read(appSettingsProvider);

    await analysisNotifier.analyzeProduct(
      imageFile: imageFile,
      question: question,
      visionContext: visionContext,
      saveImage: settings.photoServerSave,
      aiModel: settings.aiModel.isEmpty ? null : settings.aiModel,
    );

    final analysisResult = ref.read(analysisProvider);
    if (analysisResult.status == AnalysisStatus.success &&
        analysisResult.result != null) {
      final isAuthenticated =
          ref.read(authProvider).valueOrNull?.isAuthenticated ?? false;

      if (isAuthenticated) {
        // The server already saved this analysis; refresh the server list.
        ref.invalidate(serverHistoryProvider);
      } else {
        await ref
            .read(historyProvider.notifier)
            .add(
              HistoryItem.fromResult(
                result: analysisResult.result!,
                question: question,
                imagePath: imageFile.path,
                visionContext: visionContext,
              ),
            );
      }
    }
  }

  /// Reads the verdict and recommendation aloud once an analysis succeeds.
  void _speakResult(AnalysisResult result) {
    final segments = [
      result.verdictLabel.trim(),
      result.recommendation.trim(),
    ].where((segment) => segment.isNotEmpty).toList();

    if (segments.isEmpty) {
      return;
    }

    unawaited(_voiceNotifier.speakAiResponse(segments.join('. ')));
  }

  void _onAnalysisSuccess(AnalysisResult result) {
    _speakResult(result);

    final summary = result.verdictLabel.trim().isEmpty
        ? '판단을 마쳤어요.'
        : result.verdictLabel.trim();
    setState(() => _messages.add(ChatMessage.ai(summary, result: result)));
  }

  void _onAnalysisFailure(String? message) {
    final text = (message == null || message.isEmpty)
        ? '분석 결과를 가져오지 못했어요. 잠시 후 다시 시도해주세요.'
        : message;
    setState(() => _messages.add(ChatMessage.ai(text)));
  }

  void _showResultDetail(AnalysisResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: 0.88,
        child: ClipRRect(
          borderRadius: AppRadius.sheet,
          child: AnalysisResultView(
            result: result,
            onClose: () => Navigator.of(sheetContext).pop(),
            topPadding: AppSpacing.lg,
            closeLabel: '닫기',
          ),
        ),
      ),
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
                  padding: const EdgeInsets.only(
                    top: AppSpacing.topBarHeight + 10,
                  ),
                  child: const HistorySection(),
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
    required this.messages,
    required this.onShowDetail,
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
  final List<ChatMessage> messages;
  final ValueChanged<AnalysisResult> onShowDetail;
  final Widget Function(CameraState, CameraController?) buildCameraLayer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCameraArea,
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
              if (messages.isNotEmpty || analysisState.isLoading)
                Positioned(
                  top: AppSpacing.topBarHeight,
                  left: 0,
                  right: 0,
                  bottom: AppSpacing.figmaInputPanelHeight,
                  child: AnalysisChatView(
                    messages: messages,
                    isThinking: analysisState.isLoading,
                    onShowDetail: onShowDetail,
                  ),
                ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppTopBar(onMenuPressed: onMenuPressed),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.viewInsetsOf(context).bottom,
                  ),
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
