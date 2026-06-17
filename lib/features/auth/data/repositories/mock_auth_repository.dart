import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Local/mock authentication.
///
/// No network call is made yet: signing in mints a local token so the app can
/// react to login state. Replace this with a network-backed implementation
/// once the real auth API is available.
class MockAuthRepository implements AuthRepository {
  const MockAuthRepository(this._tokenStorage);

  final TokenStorage _tokenStorage;

  static const _emailKey = 'auth_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<AuthSession> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return const AuthSession.guest();
    }

    final prefs = await _prefs;
    final email = prefs.getString(_emailKey) ?? '';
    return AuthSession(
      accessToken: token,
      email: email,
      displayName: _displayNameFrom(email),
    );
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final token = 'mock-${DateTime.now().microsecondsSinceEpoch}';
    await _tokenStorage.saveAccessToken(token);

    final prefs = await _prefs;
    await prefs.setString(_emailKey, email);

    return AuthSession(
      accessToken: token,
      email: email,
      displayName: _displayNameFrom(email),
    );
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
    final prefs = await _prefs;
    await prefs.remove(_emailKey);
  }

  String _displayNameFrom(String email) {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      return '회원';
    }
    final atIndex = trimmed.indexOf('@');
    return atIndex > 0 ? trimmed.substring(0, atIndex) : trimmed;
  }
}
