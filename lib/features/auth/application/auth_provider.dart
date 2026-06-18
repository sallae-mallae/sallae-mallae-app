import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/token_storage.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../domain/entities/auth_session.dart';
import '../domain/repositories/auth_repository.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const LocalTokenStorage();
});

/// Backing auth implementation. Swap [MockAuthRepository] for a network-backed
/// repository once the real auth API is available.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(ref.read(tokenStorageProvider));
});

/// App-wide login state. Watch this to react to sign-in / sign-out anywhere.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthSession>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthSession> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthSession> build() {
    return _repository.restoreSession();
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
}
