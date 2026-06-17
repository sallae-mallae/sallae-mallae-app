/// Represents the current authentication state of the app.
///
/// While the real auth API is not wired up yet, a session is created locally
/// once the user "signs in" so the rest of the app can react to login state.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.email,
    required this.displayName,
  });

  const AuthSession.guest() : accessToken = null, email = '', displayName = '';

  final String? accessToken;
  final String email;
  final String displayName;

  bool get isAuthenticated =>
      accessToken != null && accessToken!.trim().isNotEmpty;
}
