
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';

// 서버로부터 받은 알림 목록을 표시하는 화면입니다.
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 첫 프레임에서 데이터를 가져오도록 합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer 위젯을 사용하여 Provider의 상태 변화를 감지하고 UI를 다시 그립니다.
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('에러 발생: ${provider.errorMessage}'));
        }

        if (provider.notifications.isEmpty) {
          return const Center(child: Text('표시할 알림이 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchNotifications(),
          child: ListView.separated(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return NotificationTile(notification: notification);
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        );
      },
    );
  }
}