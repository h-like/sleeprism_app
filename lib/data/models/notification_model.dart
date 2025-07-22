
// 백엔드의 NotificationType Enum에 대응하는 Dart Enum
enum NotificationType {
  COMMENT,
  REPLY_COMMENT,
  SALE_REQUEST,
  SALE_ACCEPTED,
  SALE_REJECTED,
  POST_PURCHASED,
  POST_LIKE,
  CHAT_MESSAGE,
  MESSAGE,
  UNKNOWN, // 예외 처리를 위한 기본값
}

class NotificationModel {
  final int id;
  final int userId;
  final NotificationType type;
  final String message;
  final String targetEntityType;
  final int targetEntityId;
  final bool isRead;
  final String redirectPath;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.targetEntityType,
    required this.targetEntityId,
    required this.isRead,
    required this.redirectPath,
    required this.createdAt,
  });

  // JSON 데이터를 NotificationModel 객체로 변환하는 factory 생성자
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      type: NotificationType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => NotificationType.UNKNOWN,
      ),
      message: json['message'] ?? '메시지 없음',
      targetEntityType: json['targetEntityType'] ?? '',
      targetEntityId: json['targetEntityId'] ?? 0,
      //  json['isRead']가 null일 경우 기본값으로 false를 사용합니다.
      isRead: json['isRead'] ?? false,
      redirectPath: json['redirectPath'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}