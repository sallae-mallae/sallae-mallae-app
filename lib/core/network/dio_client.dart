import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/network/auth_interceptor.dart';
import 'package:sallae_mallae_app/core/network/logging_interceptor.dart';
import 'package:sallae_mallae_app/core/network/network_interceptor.dart';

import 'api_constants.dart';

abstract final class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(NetworkInterceptor());
    dio.interceptors.add(LoggingInterceptor());

    return dio;
  }
}
