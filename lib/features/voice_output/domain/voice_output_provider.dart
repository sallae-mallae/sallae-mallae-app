import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/tts_voice.dart';
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
  static const _voiceNameKey = 'tts_voice_name';
  static const _voiceLocaleKey = 'tts_voice_locale';

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

      await loadVoices();
    } catch (_) {
      state = state.copyWith(
        isInitializing: false,
        isInitialized: false,
        errorMessage: '음성 출력을 초기화할 수 없습니다.',
      );
    }
  }

  /// Loads the available Korean voices and applies the saved selection.
  Future<void> loadVoices() async {
    final voices = await _service.getKoreanVoices();

    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString(_voiceNameKey);
    final savedLocale = prefs.getString(_voiceLocaleKey);

    TtsVoice? selected;
    if (savedName != null && savedLocale != null) {
      for (final voice in voices) {
        if (voice.name == savedName && voice.locale == savedLocale) {
          selected = voice;
          break;
        }
      }
    }

    if (selected != null) {
      await _service.setVoice(selected);
    }

    state = state.copyWith(availableVoices: voices, selectedVoice: selected);
  }

  Future<void> selectVoice(TtsVoice voice) async {
    await _service.setVoice(voice);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_voiceNameKey, voice.name);
    await prefs.setString(_voiceLocaleKey, voice.locale);

    state = state.copyWith(selectedVoice: voice);
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
