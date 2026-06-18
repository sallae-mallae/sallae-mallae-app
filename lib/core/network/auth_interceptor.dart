import 'package:dio/dio.dart';

import 'token_storage.dart';

/// Attaches the access token to outgoing requests and exposes a hook for
/// unauthorized (401) responses.
///
/// The refresh-token flow is intentionally left as a hook: the real token
/// refresh API is wired up once authentication is finalized.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({TokenStorage? tokenStorage, this.onUnauthorized})
    : _tokenStorage = tokenStorage ?? const LocalTokenStorage();

  final TokenStorage _tokenStorage;

  /// Called when a request fails with 401. A future implementation can use this
  /// to trigger a token refresh or force sign-out.
  final Future<void> Function()? onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized?.call();
    }

    handler.next(err);
  }
}
