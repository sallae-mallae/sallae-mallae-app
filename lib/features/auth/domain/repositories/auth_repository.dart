import '../entities/auth_session.dart';

/// Contract for authentication.
///
/// The current implementation is a local/mock scaffold. Once the real auth API
/// is available, a network-backed implementation can fulfil the same contract
/// (sign-in, token refresh and server history sync) without changing callers.
abstract interface class AuthRepository {
  /// Restores a previously persisted session, or a guest session if none.
  Future<AuthSession> restoreSession();

  Future<AuthSession> signIn({required String email, required String password});

  Future<void> signOut();
}
