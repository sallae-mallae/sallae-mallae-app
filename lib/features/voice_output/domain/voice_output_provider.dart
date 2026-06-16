import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/voice_output_state.dart';
import 'voice_output_service.dart';

final voiceOutputServiceProvider = Provider<VoiceOutputService>((ref) {
  return VoiceOutputService();
});

final voiceOutputProvider =
    NotifierProvider<VoiceOutputNotifier, VoiceOutputState>(
      VoiceOutputNotifier.new,
    );

class VoiceOutputNotifier extends Notifier<VoiceOutputState> {
  VoiceOutputService get _service => ref.read(voiceOutputServiceProvider);

  @override
  VoiceOutputState build() {
    ref.onDispose(() {
      unawaited(_service.stop());
    });

    return const VoiceOutputState.initial();
  }

  Future<void> initialize() async {
    if (state.isInitialized || state.isInitializing) {
      return;
    }

    state = state.copyWith(isInitializing: true, clearErrorMessage: true);

    try {
      await _service.initialize(
        onStart: _handleStart,
        onComplete: _handleStop,
        onCancel: _handleStop,
        onError: _handleError,
      );

      state = state.copyWith(
        isInitializing: false,
        isInitialized: true,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        errorMessage: '음성 출력을 초기화할 수 없습니다.',
      );
    }
  }

  Future<void> speakAiResponse(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      return;
    }

    if (!state.isInitialized) {
      await initialize();
    }

    if (!state.canSpeak) {
      state = state.copyWith(errorMessage: '음성 출력을 사용할 수 없습니다.');
      return;
    }

    state = state.copyWith(
      lastSpokenText: trimmedText,
      clearErrorMessage: true,
    );

    try {
      await _service.speak(trimmedText);
    } catch (_) {
      state = state.copyWith(
        isSpeaking: false,
        errorMessage: '응답을 음성으로 재생할 수 없습니다.',
      );
    }
  }

  Future<void> stop() async {
    await _service.stop();
    state = state.copyWith(isSpeaking: false);
  }

  void _handleStart() {
    state = state.copyWith(isSpeaking: true, clearErrorMessage: true);
  }

  void _handleStop() {
    state = state.copyWith(isSpeaking: false);
  }

  void _handleError(dynamic _) {
    state = state.copyWith(
      isSpeaking: false,
      errorMessage: '응답을 음성으로 재생할 수 없습니다.',
    );
  }
}
