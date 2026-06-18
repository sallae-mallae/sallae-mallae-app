import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/models/speech_input_state.dart';
import 'speech_input_service.dart';

final speechInputServiceProvider = Provider<SpeechInputService>((ref) {
  return SpeechInputService();
});

final speechInputProvider =
    NotifierProvider<SpeechInputNotifier, SpeechInputState>(
      SpeechInputNotifier.new,
    );

class SpeechInputNotifier extends Notifier<SpeechInputState> {
  /// Purchase-intent phrases that trigger an immediate capture and analysis
  /// while the user is still speaking. Matched after whitespace is removed.
  static const _autoCaptureKeywords = <String>[
    '살래말래',
    '살래',
    '살까',
    '말래',
    '말까',
    '어때',
    '살만',
    '괜찮을까',
    '필요할까',
    '사도돼',
  ];

  SpeechInputService get _service => ref.read(speechInputServiceProvider);

  @override
  SpeechInputState build() {
    ref.onDispose(() {
      unawaited(_service.cancelListening());
    });

    return const SpeechInputState.initial();
  }

  void updateQuestionText(String value) {
    state = state.copyWith(questionText: value, clearErrorMessage: true);
  }

  Future<void> initialize() async {
    if (state.isInitialized || state.isInitializing) {
      return;
    }

    state = state.copyWith(isInitializing: true, clearErrorMessage: true);

    try {
      final isAvailable = await _service.initialize(
        onStatus: _handleStatus,
        onError: _handleError,
      );

      state = state.copyWith(
        isInitializing: false,
        isInitialized: true,
        isAvailable: isAvailable,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        isAvailable: false,
        errorMessage: '음성 입력을 초기화할 수 없습니다.',
      );
    }
  }

  Future<void> startListening() async {
    if (!state.isInitialized) {
      await initialize();
    }

    if (!state.canStartListening) {
      state = state.copyWith(
        errorMessage: '음성 입력을 사용할 수 없습니다. 텍스트로 질문을 입력해주세요.',
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      lastRecognizedWords: '',
      isFinalResult: false,
      autoSubmitTriggered: false,
      clearErrorMessage: true,
    );

    try {
      await _service.startListening(onResult: _handleResult);
    } catch (_) {
      state = state.copyWith(
        isListening: false,
        errorMessage: '음성 듣기를 시작할 수 없습니다.',
      );
    }
  }

  Future<void> stopListening() async {
    if (!state.canStopListening) {
      return;
    }

    await _service.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> toggleListening() {
    if (state.isListening) {
      return stopListening();
    }

    return startListening();
  }

  Future<void> cancelListening() async {
    await _service.cancelListening();
    state = state.copyWith(isListening: false);
  }

  /// Resets the auto-submit flag after the UI has consumed it, so a single
  /// keyword does not trigger repeated analyses.
  void consumeAutoSubmit() {
    if (!state.autoSubmitTriggered) {
      return;
    }

    state = state.copyWith(autoSubmitTriggered: false);
  }

  bool _hasAutoCaptureKeyword(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    return _autoCaptureKeywords.any(normalized.contains);
  }

  void _handleResult(SpeechRecognitionResult result) {
    final recognizedWords = result.recognizedWords.trim();

    if (recognizedWords.isEmpty) {
      return;
    }

    final triggered =
        state.autoSubmitTriggered || _hasAutoCaptureKeyword(recognizedWords);

    state = state.copyWith(
      questionText: recognizedWords,
      lastRecognizedWords: recognizedWords,
      isFinalResult: result.finalResult,
      autoSubmitTriggered: triggered,
      clearErrorMessage: true,
    );
  }

  void _handleStatus(String status) {
    final isListening = status == SpeechToText.listeningStatus;
    final isDone =
        status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus;

    if (isListening) {
      state = state.copyWith(isListening: true);
      return;
    }

    if (isDone) {
      state = state.copyWith(isListening: false);
    }
  }

  void _handleError(SpeechRecognitionError error) {
    state = state.copyWith(
      isListening: false,
      errorMessage: '음성을 인식하지 못했습니다. 텍스트로 입력해주세요.',
    );
  }
}
