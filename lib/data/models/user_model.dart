// lib/data/models/user_model.dart

// 백엔드와 동일한 Enum 정의
// enum UserRole { USER, ADMIN }
// enum UserStatus { ACTIVE, DORMANT, SUSPENDED, DELETED }
// enum SocialProvider { NONE, GOOGLE, NAVER, KAKAO }
//
// class User {
//   final int id;
//   final String email;
//   final String nickname;
//   final String? profileImageUrl;
//   final UserRole role;
//   final UserStatus status;
//   final SocialProvider socialProvider;
//   final String createdAt;
//   final String? updatedAt;
//   final bool isDeleted;
//
//   User({
//     required this.id,
//     required this.email,
//     required this.nickname,
//     this.profileImageUrl,
//     required this.role,
//     required this.status,
//     required this.socialProvider,
//     required this.createdAt,
//     this.updatedAt,
//     required this.isDeleted,
//   });
//
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     // String 값을 Enum으로 변환하는 헬퍼 함수
//     T _enumFromString<T>(List<T> values, String value) {
//       return values.firstWhere((v) => v.toString().split('.').last == value, orElse: () => values[0]);
//     }
//
//     return User(
//       id: json['id'] ?? 0,
//       email: json['email'] ?? '',
//       nickname: json['nickname'] ?? '알 수 없음',
//       profileImageUrl: json['profileImageUrl'],
//       role: _enumFromString(UserRole.values, json['role'] ?? 'USER'),
//       status: _enumFromString(UserStatus.values, json['status'] ?? 'ACTIVE'),
//       socialProvider: _enumFromString(SocialProvider.values, json['socialProvider'] ?? 'NONE'),
//       createdAt: json['createdAt'] ?? '',
//       updatedAt: json['updatedAt'],
//       isDeleted: json['deleted'] ?? false,
//     );
//   }
// }


class User {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
  });

  // 백엔드의 UserResponseDTO와 1:1로 매칭되는 fromJson 팩토리 생성자
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // 백엔드에서 id, email, nickname은 항상 값이 있다고 가정하고,
      // 만약 null이 올 경우를 대비하여 에러 대신 기본값을 사용하도록 처리합니다.
      id: json['id'] ?? 0,
      email: json['email'] ?? '이메일 정보 없음',
      nickname: json['nickname'] ?? '닉네임 정보 없음',
      profileImageUrl: json['profileImageUrl'], // profileImageUrl은 null일 수 있습니다.
    );
  }
}