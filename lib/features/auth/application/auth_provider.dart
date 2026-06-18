import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_provider.dart';
import '../../../core/network/token_storage.dart';
import '../data/repositories/dio_auth_repository.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return SecureTokenStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return DioAuthRepository(
    ref.read(dioProvider),
    ref.read(tokenStorageProvider),
  );
});

/// App-wide login state. Watch this to react to sign-in / sign-out anywhere.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthSession>(
  AuthNotifier.new,
);

/// One-shot signal raised when an authenticated session expires (a 401 while
/// logged in). The UI consumes it to prompt the user to sign in again.
final sessionExpiredProvider = NotifierProvider<SessionExpiredNotifier, bool>(
  SessionExpiredNotifier.new,
);

class SessionExpiredNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void trigger() => state = true;

  void consume() => state = false;
}

class AuthNotifier extends AsyncNotifier<AuthSession> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthSession> build() {
    return _repository.restoreSession();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signUp(
        email: email,
        password: password,
        nickname: nickname,
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signIn(email: email, password: password),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncData(AuthSession.guest());
  }

  /// Called when a request returns 401. The token is already cleared by the
  /// interceptor; reset to a guest session and, if the user had been signed in,
  /// raise the session-expired signal so the UI can prompt a re-login.
  void handleUnauthorized() {
    final wasAuthenticated = state.asData?.value.isAuthenticated ?? false;
    state = const AsyncData(AuthSession.guest());
    if (wasAuthenticated) {
      ref.read(sessionExpiredProvider.notifier).trigger();
    }
  }
}
