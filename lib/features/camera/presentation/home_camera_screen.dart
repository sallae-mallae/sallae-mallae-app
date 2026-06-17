import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
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
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildCameraLayer(cameraState, controller)),
            if (cameraState.canShowPreview && controller != null)
              Positioned.fill(
                child: CameraVisionOverlay(state: visionOverlayState),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _QuestionInputPanel(
                controller: _questionController,
                speechState: speechInputState,
                analysisState: analysisState,
                onToggleListening: () =>
                    ref.read(speechInputProvider.notifier).toggleListening(),
                onSubmit: _submitQuestion,
              ),
            ),
          ],
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
      return ColoredBox(
        color: Colors.black,
        child: Center(child: CameraPreview(controller)),
      );
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

class _QuestionInputPanel extends StatelessWidget {
  const _QuestionInputPanel({
    required this.controller,
    required this.speechState,
    required this.analysisState,
    required this.onToggleListening,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final SpeechInputState speechState;
  final AnalysisState analysisState;
  final VoidCallback onToggleListening;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F1B1D2A),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이거 살까 말까?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                hintText: '질문을 말하거나 직접 입력하세요.',
                suffixIcon: SizedBox(
                  width: 96,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: speechState.isListening
                            ? '음성 듣기 중지'
                            : '음성 듣기 시작',
                        onPressed: speechState.isInitializing
                            ? null
                            : onToggleListening,
                        icon: Icon(
                          speechState.isListening
                              ? Icons.stop_circle
                              : Icons.mic,
                          color: speechState.isListening
                              ? AppColors.pass
                              : AppColors.blue,
                        ),
                      ),
                      IconButton(
                        tooltip: '질문 보내기',
                        onPressed: analysisState.isLoading ? null : onSubmit,
                        icon: analysisState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                color: AppColors.primary,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _QuestionStatusText(
              speechState: speechState,
              analysisState: analysisState,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionStatusText extends StatelessWidget {
  const _QuestionStatusText({
    required this.speechState,
    required this.analysisState,
  });

  final SpeechInputState speechState;
  final AnalysisState analysisState;

  @override
  Widget build(BuildContext context) {
    final message = _statusMessage;
    final color =
        speechState.errorMessage != null ||
            analysisState.status == AnalysisStatus.failure
        ? AppColors.pass
        : AppColors.textSecondary;

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  String get _statusMessage {
    if (analysisState.status == AnalysisStatus.loading) {
      return '이미지를 분석하고 있습니다.';
    }

    if (analysisState.status == AnalysisStatus.failure &&
        analysisState.errorMessage != null) {
      return analysisState.errorMessage!;
    }

    if (analysisState.status == AnalysisStatus.success) {
      return '분석 결과를 준비했습니다.';
    }

    if (speechState.errorMessage != null) {
      return speechState.errorMessage!;
    }

    if (speechState.isInitializing) {
      return '음성 입력을 준비하고 있습니다.';
    }

    if (!speechState.isAvailable) {
      return '음성 입력을 사용할 수 없으면 텍스트로 입력할 수 있습니다.';
    }

    if (speechState.isListening) {
      return '듣고 있습니다. 질문을 말해주세요.';
    }

    if (speechState.lastRecognizedWords.isNotEmpty &&
        speechState.isFinalResult) {
      return '음성 인식 결과가 질문에 반영되었습니다.';
    }

    return '마이크 버튼으로 말하거나 텍스트로 입력할 수 있습니다.';
  }
}
