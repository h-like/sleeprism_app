import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/presentation/providers/auth_provider.dart';
import 'package:sleeprism_app/presentation/providers/chat_detail_provider.dart';
import 'package:sleeprism_app/presentation/providers/chat_provider.dart';
import 'package:sleeprism_app/presentation/widgets/message_bubble.dart';
import 'package:sleeprism_app/presentation/widgets/message_composer.dart';

/// 1:1 채팅을 위한 상세 화면입니다. (임시 Placeholder)
class ChatScreen extends StatefulWidget {
  final int chatRoomId;
  const ChatScreen({super.key, required this.chatRoomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 빌드된 후, ChatProvider를 통해 WebSocket에 연결합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatDetailProvider>(context, listen: false).connectAndListen(widget.chatRoomId);
    });
  }

  @override
  void dispose() {
    // 화면이 사라질 때, WebSocket 연결을 해제합니다.
    Provider.of<ChatDetailProvider>(context, listen: false).disposeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 ${widget.chatRoomId}'),
        // TODO: 상대방 닉네임 등을 표시
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatDetailProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!chatProvider.isConnected && chatProvider.messages.isEmpty) {
                  return const Center(child: Text('채팅 서버에 연결할 수 없습니다.'));
                }
                return ListView.builder(
                  reverse: true, // 최신 메시지가 하단에 오도록 설정
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    final isMe = message.senderId == currentUserId;
                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          MessageComposer(chatRoomId: widget.chatRoomId),
        ],
      ),
    );
  }
}