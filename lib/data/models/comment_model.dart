// lib/data/models/comment_model.dart

class Comment {
  final int id;
  final String content;
  final String authorNickname;
  final String? authorProfileImageUrl;
  final String createdAt;
  final bool isDeleted;
  final String? attachmentUrl;
  final String? attachmentType;
  final List<Comment> children; // 대댓글 목록

  Comment({
    required this.id,
    required this.content,
    required this.authorNickname,
    this.authorProfileImageUrl,
    this.attachmentUrl,
    this.attachmentType,
    required this.createdAt,
    required this.isDeleted,
    required this.children,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    var childrenFromJson = json['children'] as List? ?? [];
    List<Comment> childrenList = childrenFromJson.map((i) => Comment.fromJson(i)).toList();

    return Comment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '내용 없음',
      authorNickname: json['authorNickname'] ?? '알 수 없음',
      authorProfileImageUrl: json['authorProfileImageUrl'],
      attachmentUrl: json['attachmentUrl'],
      attachmentType: json['attachmentType'],
      createdAt: json['createdAt'] ?? '',
      isDeleted: json['deleted'] ?? false, // 백엔드 필드명 'deleted'
      children: childrenList,
    );
  }
}
