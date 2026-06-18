import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';
import 'package:sallae_mallae_app/core/network/api_error_mapper.dart';

import '../models/chat_session_detail.dart';
import '../models/chat_session_summary.dart';

/// Talks to the chat session endpoints (list / single / delete).
class ChatRemoteDatasource {
  const ChatRemoteDatasource(
    this._dio, {
    this.errorMapper = const ApiErrorMapper(),
  });

  final Dio _dio;
  final ApiErrorMapper errorMapper;

  /// `GET /api/v1/chat/sessions`
  Future<ChatSessionList> listSessions({
    int? userId,
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/chat/sessions',
        queryParameters: {
          if (userId != null) 'user_id': userId,
          'skip': skip,
          'limit': limit,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const AppException(
          type: AppExceptionType.unknown,
          message: '대화 목록을 읽을 수 없습니다.',
        );
      }

      return ChatSessionList.fromJson(data);
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }

  /// `GET /api/v1/chat/sessions/{id}`
  Future<ChatSessionDetail> getSession(int sessionId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/chat/sessions/$sessionId',
      );

      final data = response.data;
      if (data == null) {
        throw const AppException(
          type: AppExceptionType.unknown,
          message: '대화를 읽을 수 없습니다.',
        );
      }

      return ChatSessionDetail.fromJson(data);
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }

  /// `DELETE /api/v1/chat/sessions/{id}`
  Future<void> deleteSession(int sessionId) async {
    try {
      await _dio.delete<dynamic>('/api/v1/chat/sessions/$sessionId');
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }
}
