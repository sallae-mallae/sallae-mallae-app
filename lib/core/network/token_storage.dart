import 'package:shared_preferences/shared_preferences.dart';

/// Contract for persisting the access token used to authorize requests.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> clear();
}

/// Scaffold implementation backed by [SharedPreferences].
///
/// NOTE: this stores the token in plain preferences and is only meant as a
/// scaffold. Swap it for a secure storage implementation (e.g.
/// flutter_secure_storage) before persisting real access tokens.
class LocalTokenStorage implements TokenStorage {
  const LocalTokenStorage();

  static const _accessTokenKey = 'auth_access_token';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> readAccessToken() async {
    final prefs = await _prefs;
    return prefs.getString(_accessTokenKey);
  }

  @override
  Future<void> saveAccessToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_accessTokenKey, token);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_accessTokenKey);
  }
}
