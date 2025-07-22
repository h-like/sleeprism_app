
// file: lib/widgets/chat_room_tile.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeprism_app/data/models/chat_room_model.dart';
import 'package:intl/intl.dart';

// 채팅방 목록의 개별 항목을 위한 위젯입니다.
class ChatRoomTile extends StatelessWidget {
  final ChatRoomModel chatRoom;

  const ChatRoomTile({super.key, required this.chatRoom});

  @override
  Widget build(BuildContext context) {
    // 1:1 채팅인 경우 상대방 프로필, 그룹 채팅인 경우 그룹 아이콘 표시
    Widget leadingIcon = chatRoom.type == ChatRoomType.SINGLE
        ? const Icon(Icons.person)
        : const Icon(Icons.group);

    return ListTile(
      leading: CircleAvatar(
        // TODO: 사용자 프로필 이미지 또는 그룹 채팅방 아이콘 표시
        child: leadingIcon,
      ),
      title: Text(
        chatRoom.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        chatRoom.lastMessage?.content ?? '아직 메시지가 없습니다.',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (chatRoom.lastMessage != null)
            Text(
              DateFormat('HH:mm').format(chatRoom.lastMessage!.sentAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(height: 4),
          // TODO: 실제 읽지 않은 메시지 개수 데이터 연동
          // 현재는 임시로 표시하지 않음
          // if (chatRoom.unreadCount > 0)
          //   Container(...)
        ],
      ),
      onTap: () {
        // TODO: 채팅방 클릭 시 해당 채팅방 상세 화면으로 이동
        // Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatRoomId: chatRoom.id)));
        // ▼▼▼ [핵심 수정] 채팅방 ID를 사용하여 채팅 화면으로 이동합니다. ▼▼▼
        context.go('/chat/rooms/${chatRoom.id}');
        print("Chat room tapped: ${chatRoom.id}");
      },
    );
  }
}