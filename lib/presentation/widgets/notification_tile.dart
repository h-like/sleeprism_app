// file: lib/widgets/notification_tile.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeprism_app/data/models/notification_model.dart';
import 'package:intl/intl.dart';

// 알림 목록의 개별 항목을 위한 위젯입니다.
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  // 알림 타입에 따라 아이콘을 반환하는 헬퍼 메서드
  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.COMMENT:
        return Icons.comment_outlined;
      case NotificationType.CHAT_MESSAGE:
        return Icons.chat_bubble_outline;
      case NotificationType.SALE_REQUEST:
        return Icons.shopping_cart_outlined;
      case NotificationType.POST_LIKE:
        return Icons.favorite_border;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _getIconForType(notification.type),
        color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
      ),
      title: Text(
        notification.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          color: notification.isRead ? Colors.grey[600] : Colors.black,
        ),
      ),
      subtitle: Text(
        DateFormat('yy.MM.dd HH:mm').format(notification.createdAt),
      ),
      tileColor: notification.isRead ? Colors.transparent : Colors.blue.withOpacity(0.05),
      onTap: () {
        // TODO: 알림 클릭 시 처리 로직 구현
        // 1. Provider를 통해 알림 읽음 처리 API 호출
        // 2. notification.redirectPath를 사용하여 해당 화면으로 이동 (e.g., GoRouter 사용)
        if (notification.redirectPath.isNotEmpty) {
          // GoRouter의 context.go() 메서드를 사용하여 간편하게 이동
          context.go(notification.redirectPath);
        } else {
          // 만약 redirectPath가 없는 경우에 대한 예외 처리
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이동할 경로가 지정되지 않은 알림입니다.')),
          );
        }
        // context.go('chat/room/${chatRoom.id}');
        print("Notification tapped: ${notification.redirectPath}");
      },
    );
  }
}
