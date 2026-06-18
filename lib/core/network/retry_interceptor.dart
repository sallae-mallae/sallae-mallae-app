import 'package:dio/dio.dart';

/// Retries requests that fail to reach the server (connection errors/timeouts).
///
/// Only connection-level failures are retried — a request that connected and
/// then timed out while waiting for the response (e.g. the long analyze call)
/// is not retried, to avoid triggering duplicate server-side work.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio, {this.maxRetries = 2});

  final Dio _dio;
  final int maxRetries;

  static const _retryCountKey = 'retry_count';

  bool _isRetriable(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout;
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (!_isRetriable(err) || attempt >= maxRetries) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions..extra[_retryCountKey] = attempt + 1;
    await Future<void>.delayed(Duration(milliseconds: 300 * (attempt + 1)));

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
