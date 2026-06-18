/// Response of `/auth/me`.
class UserInfo {
  const UserInfo({
    required this.id,
    required this.email,
    required this.nickname,
    required this.isActive,
  });

  final int id;
  final String email;
  final String nickname;
  final bool isActive;

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
