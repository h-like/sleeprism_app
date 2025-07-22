
import 'package:flutter/material.dart';
import 'notification_list_screen.dart';
import 'chat_room_list_screen.dart';

/// 알림과 채팅 목록 탭을 관리하는 메인 화면입니다.
class NotificationHubScreen extends StatelessWidget {
  const NotificationHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController를 사용하여 탭 상태를 관리합니다.
    return DefaultTabController(
      length: 2, // 탭의 개수 (알림, 채팅)
      child: Scaffold(
        appBar: AppBar(
          title: const Text('알림 및 채팅'),
          // AppBar 하단에 TabBar를 추가합니다.
          bottom: const TabBar(
            tabs: [
              Tab(text: '알림'),
              Tab(text: '채팅'),
            ],
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        // TabBarView를 사용하여 각 탭에 해당하는 화면을 보여줍니다.
        body: const TabBarView(
          children: [
            NotificationListScreen(), // '알림' 탭에 표시될 화면
            ChatRoomListScreen(),   // '채팅' 탭에 표시될 화면
          ],
        ),
      ),
    );
  }
}