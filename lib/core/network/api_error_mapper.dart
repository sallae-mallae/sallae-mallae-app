import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';

class ApiErrorMapper {
  const ApiErrorMapper();

  AppException mapDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;

    if (exception.type == DioExceptionType.badResponse && statusCode == 422) {
      return AppException(
        type: AppExceptionType.validation,
        message: _validationMessage(exception.response?.data),
        statusCode: 422,
      );
    }

    return AppException.fromDioException(exception);
  }

  String _validationMessage(Object? data) {
    final details = _extractValidationDetails(data);

    if (details.isEmpty) {
      return '분석 요청 정보가 올바르지 않습니다.';
    }

    return '분석 요청을 확인해주세요. ${details.join(' ')}';
  }

  List<String> _extractValidationDetails(Object? data) {
    if (data is! Map<String, dynamic>) {
      return const [];
    }

    final detail = data['detail'];

    if (detail is List) {
      return detail
          .map(_formatValidationItem)
          .whereType<String>()
          .toList(growable: false);
    }

    if (detail is String && detail.trim().isNotEmpty) {
      return [detail.trim()];
    }

    return const [];
  }

  String? _formatValidationItem(Object? item) {
    if (item is String) {
      return item.trim().isEmpty ? null : item.trim();
    }

    if (item is! Map<String, dynamic>) {
      return null;
    }

    final message = item['msg'] as String?;
    final location = item['loc'];
    final field = location is List && location.isNotEmpty
        ? location.last.toString()
        : null;

    if (message == null || message.trim().isEmpty) {
      return field == null ? null : '$field 값을 확인해주세요.';
    }

    if (field == null || field == 'body') {
      return message.trim();
    }

    return '$field: ${message.trim()}';
  }
}
