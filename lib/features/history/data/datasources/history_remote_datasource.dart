import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';
import 'package:sallae_mallae_app/core/network/api_error_mapper.dart';

import '../models/server_history_item.dart';

/// Reads and deletes server-side history (`/history`).
class HistoryRemoteDatasource {
  const HistoryRemoteDatasource(
    this._dio, {
    this.errorMapper = const ApiErrorMapper(),
  });

  final Dio _dio;
  final ApiErrorMapper errorMapper;

  Future<ServerHistoryPage> list({
    int skip = 0,
    int limit = 20,
    String? verdict,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/history',
        queryParameters: {
          'skip': skip,
          'limit': limit,
          if (verdict != null && verdict.isNotEmpty) 'verdict': verdict,
        },
      );

      final data = response.data ?? const {};
      final items = (data['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ServerHistoryItem.fromJson)
          .toList();

      return ServerHistoryPage(
        items: items,
        total: data['total'] as int? ?? items.length,
      );
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }

  Future<ServerHistoryItem> detail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/history/$id',
      );
      final data = response.data;
      if (data == null) {
        throw const AppException(
          type: AppExceptionType.unknown,
          message: '기록을 불러올 수 없습니다.',
        );
      }
      return ServerHistoryItem.fromJson(data);
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete<dynamic>('/api/v1/history/$id');
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }
}
