import 'tts_voice.dart';

class VoiceOutputState {
  const VoiceOutputState({
    required this.isInitializing,
    required this.isInitialized,
    required this.isSpeaking,
    required this.lastSpokenText,
    required this.availableVoices,
    this.selectedVoice,
    this.errorMessage,
  });

  const VoiceOutputState.initial()
    : isInitializing = false,
      isInitialized = false,
      isSpeaking = false,
      lastSpokenText = '',
      availableVoices = const [],
      selectedVoice = null,
      errorMessage = null;

  final bool isInitializing;
  final bool isInitialized;
  final bool isSpeaking;
  final String lastSpokenText;
  final List<TtsVoice> availableVoices;
  final TtsVoice? selectedVoice;
  final String? errorMessage;

  bool get canSpeak => isInitialized && !isInitializing;

  VoiceOutputState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    bool? isSpeaking,
    String? lastSpokenText,
    List<TtsVoice>? availableVoices,
    TtsVoice? selectedVoice,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return VoiceOutputState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      availableVoices: availableVoices ?? this.availableVoices,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
