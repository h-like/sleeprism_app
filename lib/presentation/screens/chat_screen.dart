import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 1:1 채팅을 위한 상세 화면입니다. (임시 Placeholder)
class ChatScreen extends StatelessWidget {
  final int chatRoomId;
  const ChatScreen({super.key, required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방 ID: $chatRoomId'),
      ),
      body: Center(
        child: Text('여기에 채팅 내용이 표시됩니다.'),
      ),
    );
  }
}
