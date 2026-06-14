import 'package:permission_handler/permission_handler.dart';

import '../data/models/permission_state.dart';

class PermissionService {
  const PermissionService();

  Future<PermissionState> checkRequiredPermissions() async {
    var state = const PermissionState.initial();

    for (final type in AppPermissionType.values) {
      final status = await checkPermission(type);
      state = state.updatePermission(type: type, status: status);
    }

    return state;
  }

  Future<PermissionState> requestRequiredPermissions() async {
    var state = const PermissionState.initial();

    for (final type in AppPermissionType.values) {
      final status = await requestPermission(type);
      state = state.updatePermission(type: type, status: status);
    }

    return state;
  }

  Future<AppPermissionStatus> checkPermission(AppPermissionType type) async {
    final status = await _platformPermission(type).status;

    return _mapPermissionStatus(status);
  }

  Future<AppPermissionStatus> requestPermission(AppPermissionType type) async {
    final status = await _platformPermission(type).request();

    return _mapPermissionStatus(status);
  }

  Future<bool> openSettings() {
    return openAppSettings();
  }

  Permission _platformPermission(AppPermissionType type) {
    return switch (type) {
      AppPermissionType.camera => Permission.camera,
      AppPermissionType.microphone => Permission.microphone,
      AppPermissionType.speechRecognition => Permission.speech,
    };
  }

  AppPermissionStatus _mapPermissionStatus(PermissionStatus status) {
    return switch (status) {
      PermissionStatus.granted => AppPermissionStatus.granted,
      PermissionStatus.denied => AppPermissionStatus.denied,
      PermissionStatus.permanentlyDenied =>
        AppPermissionStatus.permanentlyDenied,
      PermissionStatus.restricted => AppPermissionStatus.restricted,
      PermissionStatus.limited => AppPermissionStatus.limited,
      PermissionStatus.provisional => AppPermissionStatus.granted,
    };
  }
}
