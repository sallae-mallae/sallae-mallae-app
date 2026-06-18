import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs each API request/response (method, URL, status, body) and how long it
/// took. Bodies are truncated so large payloads (e.g. base64 images) stay
/// readable. Disabled in release builds.
class LoggingInterceptor extends Interceptor {
  static const _startKey = 'request_start_ms';
  static const _maxBodyChars = 1000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kReleaseMode) {
      handler.next(options);
      return;
    }

    options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
    developer.log(
      '→ ${options.method} ${options.uri}\n'
      'body: ${_summarize(options.data)}',
      name: 'API',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kReleaseMode) {
      handler.next(response);
      return;
    }

    final options = response.requestOptions;
    developer.log(
      '← ${response.statusCode} ${options.method} ${options.uri} '
      '(${_elapsedMs(options)}ms)\n'
      'body: ${_summarize(response.data)}',
      name: 'API',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kReleaseMode) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    developer.log(
      '✕ ${err.response?.statusCode ?? '-'} ${options.method} ${options.uri} '
      '(${_elapsedMs(options)}ms)\n'
      'error: ${err.message}\n'
      'body: ${_summarize(err.response?.data)}',
      name: 'API',
    );
    handler.next(err);
  }

  int _elapsedMs(RequestOptions options) {
    final start = options.extra[_startKey];
    if (start is int) {
      return DateTime.now().millisecondsSinceEpoch - start;
    }
    return -1;
  }

  String _summarize(Object? data) {
    if (data == null) {
      return 'null';
    }

    final text = data.toString();
    if (text.length > _maxBodyChars) {
      return '${text.substring(0, _maxBodyChars)}… (${text.length} chars)';
    }
    return text;
  }
}
