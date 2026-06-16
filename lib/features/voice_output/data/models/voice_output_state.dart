class VoiceOutputState {
  const VoiceOutputState({
    required this.isInitializing,
    required this.isInitialized,
    required this.isSpeaking,
    required this.lastSpokenText,
    this.errorMessage,
  });

  const VoiceOutputState.initial()
    : isInitializing = false,
      isInitialized = false,
      isSpeaking = false,
      lastSpokenText = '',
      errorMessage = null;

  final bool isInitializing;
  final bool isInitialized;
  final bool isSpeaking;
  final String lastSpokenText;
  final String? errorMessage;

  bool get canSpeak => isInitialized && !isInitializing;

  VoiceOutputState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    bool? isSpeaking,
    String? lastSpokenText,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return VoiceOutputState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      lastSpokenText: lastSpokenText ?? this.lastSpokenText,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
