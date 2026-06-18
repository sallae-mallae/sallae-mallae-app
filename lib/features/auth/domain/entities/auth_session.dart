/// Represents the current authentication state of the app.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.nickname,
  });

  const AuthSession.guest()
    : accessToken = null,
      userId = null,
      email = '',
      nickname = '';

  final String? accessToken;
  final int? userId;
  final String email;
  final String nickname;

  /// Name shown in the UI; falls back to the email local part, then a generic
  /// label, when the nickname is empty.
  String get displayName {
    if (nickname.trim().isNotEmpty) {
      return nickname.trim();
    }
    final atIndex = email.indexOf('@');
    if (atIndex > 0) {
      return email.substring(0, atIndex);
    }
    return '회원';
  }

  bool get isAuthenticated =>
      accessToken != null && accessToken!.trim().isNotEmpty;
}
