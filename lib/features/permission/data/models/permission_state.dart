enum AppPermissionType { camera, microphone, speechRecognition }

enum AppPermissionStatus {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

class PermissionItemState {
  const PermissionItemState({required this.type, required this.status});

  const PermissionItemState.initial(this.type)
    : status = AppPermissionStatus.unknown;

  final AppPermissionType type;
  final AppPermissionStatus status;

  bool get isGranted => status == AppPermissionStatus.granted;

  bool get canRequest =>
      status == AppPermissionStatus.unknown ||
      status == AppPermissionStatus.denied;

  bool get needsAppSettings =>
      status == AppPermissionStatus.permanentlyDenied ||
      status == AppPermissionStatus.restricted ||
      status == AppPermissionStatus.limited;

  PermissionItemState copyWith({AppPermissionStatus? status}) {
    return PermissionItemState(type: type, status: status ?? this.status);
  }
}

class PermissionState {
  const PermissionState({
    required this.camera,
    required this.microphone,
    required this.speechRecognition,
    required this.isChecking,
    required this.isRequesting,
    this.errorMessage,
  });

  const PermissionState.initial()
    : camera = const PermissionItemState.initial(AppPermissionType.camera),
      microphone = const PermissionItemState.initial(
        AppPermissionType.microphone,
      ),
      speechRecognition = const PermissionItemState.initial(
        AppPermissionType.speechRecognition,
      ),
      isChecking = false,
      isRequesting = false,
      errorMessage = null;

  final PermissionItemState camera;
  final PermissionItemState microphone;
  final PermissionItemState speechRecognition;
  final bool isChecking;
  final bool isRequesting;
  final String? errorMessage;

  bool get allGranted =>
      camera.isGranted && microphone.isGranted && speechRecognition.isGranted;

  bool get hasBlockedPermission =>
      camera.needsAppSettings ||
      microphone.needsAppSettings ||
      speechRecognition.needsAppSettings;

  bool get canRequestAny =>
      camera.canRequest ||
      microphone.canRequest ||
      speechRecognition.canRequest;

  PermissionState copyWith({
    PermissionItemState? camera,
    PermissionItemState? microphone,
    PermissionItemState? speechRecognition,
    bool? isChecking,
    bool? isRequesting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PermissionState(
      camera: camera ?? this.camera,
      microphone: microphone ?? this.microphone,
      speechRecognition: speechRecognition ?? this.speechRecognition,
      isChecking: isChecking ?? this.isChecking,
      isRequesting: isRequesting ?? this.isRequesting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  PermissionState updatePermission({
    required AppPermissionType type,
    required AppPermissionStatus status,
  }) {
    final itemState = PermissionItemState(type: type, status: status);

    return switch (type) {
      AppPermissionType.camera => copyWith(camera: itemState),
      AppPermissionType.microphone => copyWith(microphone: itemState),
      AppPermissionType.speechRecognition => copyWith(
        speechRecognition: itemState,
      ),
    };
  }
}
