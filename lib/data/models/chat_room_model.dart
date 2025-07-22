enum ChatRoomType {
  SINGLE,
  GROUP,
}

class ChatRoomModel {
  final int id;
  final String name;
  final ChatRoomType type;
  final int? creatorId;
  final String? creatorNickname;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LastMessage? lastMessage;
  // final int unreadCount; // TODO: 읽지 않은 메시지 개수 필드 추가

  ChatRoomModel({
    required this.id,
    required this.name,
    required this.type,
    this.creatorId,
    this.creatorNickname,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    // required this.unreadCount,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '채팅방',
      type: ChatRoomType.values.firstWhere(
            (e) => e.toString().split('.').last == json['type'],
        orElse: () => ChatRoomType.SINGLE,
      ),
      creatorId: json['creatorId'],
      creatorNickname: json['creatorNickname'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastMessage: json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null,
    );
  }
}

class LastMessage {
  final String content;
  final DateTime sentAt;

  LastMessage({
    required this.content,
    required this.sentAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    // 백엔드 ChatMessageResponseDTO 필드명에 맞춤
    return LastMessage(
      content: json['content'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }
}