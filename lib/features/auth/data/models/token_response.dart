/// Response of `/auth/register` and `/auth/login`.
class TokenResponse {
  const TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.email,
    required this.nickname,
  });

  final String accessToken;
  final String tokenType;
  final int userId;
  final String email;
  final String nickname;

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      userId: json['user_id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
    );
  }
}
