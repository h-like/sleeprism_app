
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/presentation/providers/chat_room_list_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_room_tile.dart';

// 사용자가 참여하고 있는 채팅방 목록을 표시하는 화면입니다.
class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatRoomListProvider>(context, listen: false).fetchChatRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatRoomListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(child: Text('에러 발생: ${provider.errorMessage}'));
        }

        if (provider.chatRooms.isEmpty) {
          return const Center(child: Text('참여중인 채팅방이 없습니다.'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchChatRooms(),
          child: ListView.separated(
            itemCount: provider.chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = provider.chatRooms[index];
              return ChatRoomTile(chatRoom: chatRoom);
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          ),
        );
      },
    );
  }
}