import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';
import 'package:sallae_mallae_app/core/network/api_error_mapper.dart';

import '../models/analyze_request.dart';
import '../models/analyze_response.dart';

abstract interface class AnalyzeRemoteDatasource {
  Future<AnalyzeResponse> analyze({required AnalyzeRequest request});
}

class DioAnalyzeRemoteDatasource implements AnalyzeRemoteDatasource {
  const DioAnalyzeRemoteDatasource(
    this._dio, {
    this.errorMapper = const ApiErrorMapper(),
  });

  final Dio _dio;
  final ApiErrorMapper errorMapper;

  @override
  Future<AnalyzeResponse> analyze({required AnalyzeRequest request}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/chat/analyze',
        data: request.toJson(),
      );

      final data = response.data;

      if (data == null) {
        throw const AppException(
          type: AppExceptionType.unknown,
          message: '분석 응답을 읽을 수 없습니다.',
        );
      }

      return AnalyzeResponse.fromJson(data);
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }
}
