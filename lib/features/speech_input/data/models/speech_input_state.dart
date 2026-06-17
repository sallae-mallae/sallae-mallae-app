class SpeechInputState {
  const SpeechInputState({
    required this.isInitializing,
    required this.isInitialized,
    required this.isAvailable,
    required this.isListening,
    required this.questionText,
    required this.lastRecognizedWords,
    required this.isFinalResult,
    required this.autoSubmitTriggered,
    this.errorMessage,
  });

  const SpeechInputState.initial()
    : isInitializing = false,
      isInitialized = false,
      isAvailable = false,
      isListening = false,
      questionText = '',
      lastRecognizedWords = '',
      isFinalResult = false,
      autoSubmitTriggered = false,
      errorMessage = null;

  final bool isInitializing;
  final bool isInitialized;
  final bool isAvailable;
  final bool isListening;
  final String questionText;
  final String lastRecognizedWords;
  final bool isFinalResult;

  /// Set when a purchase-intent keyword (e.g. "살까", "살래말래") is heard while
  /// listening, signalling the UI to capture and analyze immediately.
  final bool autoSubmitTriggered;
  final String? errorMessage;

  bool get canStartListening =>
      isInitialized && isAvailable && !isInitializing && !isListening;

  bool get canStopListening => isListening;

  bool get canSubmitQuestion => questionText.trim().isNotEmpty;

  SpeechInputState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    bool? isAvailable,
    bool? isListening,
    String? questionText,
    String? lastRecognizedWords,
    bool? isFinalResult,
    bool? autoSubmitTriggered,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SpeechInputState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      isAvailable: isAvailable ?? this.isAvailable,
      isListening: isListening ?? this.isListening,
      questionText: questionText ?? this.questionText,
      lastRecognizedWords: lastRecognizedWords ?? this.lastRecognizedWords,
      isFinalResult: isFinalResult ?? this.isFinalResult,
      autoSubmitTriggered: autoSubmitTriggered ?? this.autoSubmitTriggered,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
