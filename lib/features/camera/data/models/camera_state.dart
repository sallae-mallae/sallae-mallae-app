class CameraState {
  const CameraState({
    required this.isInitializing,
    required this.isInitialized,
    required this.isStreaming,
    required this.isTakingPicture,
    this.errorMessage,
  });

  const CameraState.initial()
    : isInitializing = false,
      isInitialized = false,
      isStreaming = false,
      isTakingPicture = false,
      errorMessage = null;

  final bool isInitializing;
  final bool isInitialized;
  final bool isStreaming;
  final bool isTakingPicture;
  final String? errorMessage;

  bool get canShowPreview => isInitialized && errorMessage == null;

  bool get canStartStreaming =>
      isInitialized && !isInitializing && !isStreaming && errorMessage == null;

  bool get canStopStreaming => isInitialized && isStreaming;

  bool get canTakePicture =>
      isInitialized &&
      !isInitializing &&
      !isTakingPicture &&
      errorMessage == null;

  CameraState copyWith({
    bool? isInitializing,
    bool? isInitialized,
    bool? isStreaming,
    bool? isTakingPicture,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return CameraState(
      isInitializing: isInitializing ?? this.isInitializing,
      isInitialized: isInitialized ?? this.isInitialized,
      isStreaming: isStreaming ?? this.isStreaming,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
