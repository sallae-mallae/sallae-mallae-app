import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../speech_input/data/models/speech_input_state.dart';
import '../../speech_input/domain/speech_input_provider.dart';
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
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(ref.read(cameraProvider.notifier).disposeCamera());
      unawaited(ref.read(speechInputProvider.notifier).cancelListening());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(cameraProvider.notifier).initializeCamera());
      unawaited(ref.read(speechInputProvider.notifier).initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(ref.read(cameraProvider.notifier).disposeCamera());
    unawaited(ref.read(speechInputProvider.notifier).cancelListening());
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
    final speechInputState = ref.watch(speechInputProvider);
    final controller = ref.read(cameraProvider.notifier).controller;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildCameraLayer(cameraState, controller)),
            Align(
              alignment: Alignment.bottomCenter,
              child: _QuestionInputPanel(
                controller: _questionController,
                state: speechInputState,
                onToggleListening: () =>
                    ref.read(speechInputProvider.notifier).toggleListening(),
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
    required this.state,
    required this.onToggleListening,
  });

  final TextEditingController controller;
  final SpeechInputState state;
  final VoidCallback onToggleListening;

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
              decoration: InputDecoration(
                hintText: '질문을 말하거나 직접 입력하세요.',
                suffixIcon: IconButton(
                  tooltip: state.isListening ? '음성 듣기 중지' : '음성 듣기 시작',
                  onPressed: state.isInitializing ? null : onToggleListening,
                  icon: Icon(
                    state.isListening ? Icons.stop_circle : Icons.mic,
                    color: state.isListening ? AppColors.pass : AppColors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SpeechInputStatusText(state: state),
          ],
        ),
      ),
    );
  }
}

class _SpeechInputStatusText extends StatelessWidget {
  const _SpeechInputStatusText({required this.state});

  final SpeechInputState state;

  @override
  Widget build(BuildContext context) {
    final message = _statusMessage;
    final color = state.errorMessage != null
        ? AppColors.pass
        : AppColors.textSecondary;

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }

  String get _statusMessage {
    if (state.errorMessage != null) {
      return state.errorMessage!;
    }

    if (state.isInitializing) {
      return '음성 입력을 준비하고 있습니다.';
    }

    if (!state.isAvailable) {
      return '음성 입력을 사용할 수 없으면 텍스트로 입력할 수 있습니다.';
    }

    if (state.isListening) {
      return '듣고 있습니다. 질문을 말해주세요.';
    }

    if (state.lastRecognizedWords.isNotEmpty && state.isFinalResult) {
      return '음성 인식 결과가 질문에 반영되었습니다.';
    }

    return '마이크 버튼으로 말하거나 텍스트로 입력할 수 있습니다.';
  }
}
