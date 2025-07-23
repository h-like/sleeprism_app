// 백엔드의 ChatMessageResponseDTO에 대응하는 모델

enum MessageType { TEXT, IMAGE, ENTER, LEAVE, UNKNOWN }

class ChatMessage {
  final int id;
  final int chatRoomId;
  final int senderId;
  final String senderNickname;
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final MessageType messageType;

  ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderNickname,
    required this.content,
    required this.sentAt,
    required this.isRead,
    required this.messageType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      chatRoomId: json['chatRoomId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      senderNickname: json['senderNickname'] ?? '알 수 없음',
      content: json['content'] ?? '',
      sentAt: DateTime.parse(json['sentAt']),
      isRead: json['read'] ?? false, // 백엔드 DTO 필드명이 'isRead'가 아닌 'read'일 수 있음
      messageType: MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == json['messageType'],
        orElse: () => MessageType.UNKNOWN,
      ),
    );
  }
}