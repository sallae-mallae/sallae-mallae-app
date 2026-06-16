import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';

import '../models/analyze_request.dart';
import '../models/analyze_response.dart';

abstract interface class AnalyzeRemoteDatasource {
  Future<AnalyzeResponse> analyze({
    required AnalyzeRequest request,
    String? aiModel,
  });
}

class DioAnalyzeRemoteDatasource implements AnalyzeRemoteDatasource {
  const DioAnalyzeRemoteDatasource(this._dio);

  final Dio _dio;

  @override
  Future<AnalyzeResponse> analyze({
    required AnalyzeRequest request,
    String? aiModel,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/analyze',
        data: request.toJson(),
        queryParameters: {
          if (aiModel != null && aiModel.trim().isNotEmpty)
            'ai_model': aiModel.trim(),
        },
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
      throw AppException.fromDioException(error);
    }
  }
}
