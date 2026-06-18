import 'package:dio/dio.dart';
import 'package:sallae_mallae_app/core/errors/app_exception.dart';
import 'package:sallae_mallae_app/core/network/api_error_mapper.dart';
import 'package:sallae_mallae_app/core/network/token_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/token_response.dart';
import '../models/user_info.dart';

/// Auth backed by the real API (`/auth/register`, `/auth/login`, `/auth/me`).
class DioAuthRepository implements AuthRepository {
  DioAuthRepository(
    this._dio,
    this._tokenStorage, {
    this.errorMapper = const ApiErrorMapper(),
  });

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final ApiErrorMapper errorMapper;

  @override
  Future<AuthSession> restoreSession() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return const AuthSession.guest();
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/v1/auth/me');
      final data = response.data;
      if (data == null) {
        return const AuthSession.guest();
      }

      final user = UserInfo.fromJson(data);
      return AuthSession(
        accessToken: token,
        userId: user.id,
        email: user.email,
        nickname: user.nickname,
      );
    } on DioException {
      // Stored token is invalid/expired — drop it and start as a guest.
      await _tokenStorage.clear();
      return const AuthSession.guest();
    }
  }

  @override
  Future<AuthSession> signUp({
    required String email,
    required String password,
    required String nickname,
  }) {
    return _authenticate('/api/v1/auth/register', {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) {
    return _authenticate('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
  }

  @override
  Future<void> signOut() async {
    await _tokenStorage.clear();
  }

  Future<AuthSession> _authenticate(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) {
        throw const AppException(
          type: AppExceptionType.unknown,
          message: '로그인 응답을 읽을 수 없습니다.',
        );
      }

      final token = TokenResponse.fromJson(data);
      await _tokenStorage.saveAccessToken(token.accessToken);

      return AuthSession(
        accessToken: token.accessToken,
        userId: token.userId,
        email: token.email,
        nickname: token.nickname,
      );
    } on DioException catch (error) {
      throw errorMapper.mapDioException(error);
    }
  }
}
