import 'package:dio/dio.dart';

enum AppExceptionType {
  network,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  cancelled,
  unknown,
}

class AppException implements Exception {
  const AppException({
    required this.type,
    required this.message,
    this.statusCode,
  });

  final AppExceptionType type;
  final String message;
  final int? statusCode;

  factory AppException.fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppException(
          type: AppExceptionType.timeout,
          message: '요청 시간이 초과되었습니다.',
        );

      case DioExceptionType.badResponse:
        return AppException.fromStatusCode(statusCode);

      case DioExceptionType.cancel:
        return const AppException(
          type: AppExceptionType.cancelled,
          message: '요청이 취소되었습니다.',
        );

      case DioExceptionType.connectionError:
        return const AppException(
          type: AppExceptionType.network,
          message: '네트워크 연결을 확인해주세요.',
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppException(
          type: AppExceptionType.unknown,
          message: exception.message ?? '알 수 없는 오류가 발생했습니다.',
        );
    }
  }

  factory AppException.fromStatusCode(int? statusCode) {
    if (statusCode == null) {
      return const AppException(
        type: AppExceptionType.unknown,
        message: '알 수 없는 오류가 발생했습니다.',
      );
    }

    if (statusCode >= 500) {
      return AppException(
        type: AppExceptionType.server,
        message: '서버 오류가 발생했습니다.',
        statusCode: statusCode,
      );
    }

    return switch (statusCode) {
      400 => const AppException(
        type: AppExceptionType.badRequest,
        message: '잘못된 요청입니다.',
        statusCode: 400,
      ),
      401 => const AppException(
        type: AppExceptionType.unauthorized,
        message: '인증이 필요합니다.',
        statusCode: 401,
      ),
      403 => const AppException(
        type: AppExceptionType.forbidden,
        message: '접근 권한이 없습니다.',
        statusCode: 403,
      ),
      404 => const AppException(
        type: AppExceptionType.notFound,
        message: '요청한 정보를 찾을 수 없습니다.',
        statusCode: 404,
      ),
      422 => const AppException(
        type: AppExceptionType.validation,
        message: '분석 요청 정보가 올바르지 않습니다.',
        statusCode: 422,
      ),
      _ => AppException(
        type: AppExceptionType.unknown,
        message: '알 수 없는 오류가 발생했습니다.',
        statusCode: statusCode,
      ),
    };
  }

  @override
  String toString() {
    return 'AppException(type: $type, message: $message, statusCode: $statusCode)';
  }
}
