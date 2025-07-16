// lib/data/models/post_model.dart

class Post {
  final int id;
  final String title;
  final String content;
  final String authorName;
  final String category;
  final String createdAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.category,
    required this.createdAt,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
  });

  // JSON 데이터를 Post 객체로 변환하는 팩토리 생성자
  // 백엔드의 PostResponseDTO 필드명과 정확히 일치해야 합니다.
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '알 수 없음',
      category: json['category'] ?? '기타',
      createdAt: json['createdAt'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }
}
