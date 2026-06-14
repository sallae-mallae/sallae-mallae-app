import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/permission_state.dart';
import 'permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return const PermissionService();
});

final permissionProvider =
    NotifierProvider<PermissionNotifier, PermissionState>(
      PermissionNotifier.new,
    );

class PermissionNotifier extends Notifier<PermissionState> {
  PermissionService get _service => ref.read(permissionServiceProvider);

  @override
  PermissionState build() {
    return const PermissionState.initial();
  }

  Future<void> checkRequiredPermissions() async {
    state = state.copyWith(isChecking: true, clearErrorMessage: true);

    try {
      final nextState = await _service.checkRequiredPermissions();
      state = nextState.copyWith(isChecking: false, clearErrorMessage: true);
    } catch (_) {
      state = state.copyWith(
        isChecking: false,
        errorMessage: '권한 상태를 확인할 수 없습니다.',
      );
    }
  }

  Future<void> requestRequiredPermissions() async {
    state = state.copyWith(isRequesting: true, clearErrorMessage: true);

    try {
      final nextState = await _service.requestRequiredPermissions();
      state = nextState.copyWith(isRequesting: false, clearErrorMessage: true);
    } catch (_) {
      state = state.copyWith(
        isRequesting: false,
        errorMessage: '권한을 요청할 수 없습니다.',
      );
    }
  }

  Future<void> requestPermission(AppPermissionType type) async {
    state = state.copyWith(isRequesting: true, clearErrorMessage: true);

    try {
      final status = await _service.requestPermission(type);
      state = state
          .updatePermission(type: type, status: status)
          .copyWith(isRequesting: false, clearErrorMessage: true);
    } catch (_) {
      state = state.copyWith(
        isRequesting: false,
        errorMessage: '권한을 요청할 수 없습니다.',
      );
    }
  }

  Future<bool> openSettings() {
    return _service.openSettings();
  }
}
