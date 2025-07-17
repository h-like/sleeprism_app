// lib/data/models/user_model.dart

// 백엔드와 동일한 Enum 정의
enum UserRole { USER, ADMIN }
enum UserStatus { ACTIVE, DORMANT, SUSPENDED, DELETED }
enum SocialProvider { NONE, GOOGLE, NAVER, KAKAO }

class User {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final SocialProvider socialProvider;
  final String createdAt;
  final String? updatedAt;
  final bool isDeleted;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.socialProvider,
    required this.createdAt,
    this.updatedAt,
    required this.isDeleted,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // String 값을 Enum으로 변환하는 헬퍼 함수
    T _enumFromString<T>(List<T> values, String value) {
      return values.firstWhere((v) => v.toString().split('.').last == value, orElse: () => values[0]);
    }

    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '알 수 없음',
      profileImageUrl: json['profileImageUrl'],
      role: _enumFromString(UserRole.values, json['role'] ?? 'USER'),
      status: _enumFromString(UserStatus.values, json['status'] ?? 'ACTIVE'),
      socialProvider: _enumFromString(SocialProvider.values, json['socialProvider'] ?? 'NONE'),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
      isDeleted: json['deleted'] ?? false,
    );
  }
}
