// lib/data/models/post_model.dart

import 'post_category.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final PostCategory category;
  final int viewCount;
  final bool isDeleted;
  final String authorNickname;
  final int originalAuthorId;
  final String? authorProfileImageUrl;
  final String createdAt;
  final String? updatedAt;
  final bool isSellable;
  final bool isSold;
  final int likeCount;
  final int commentCount;
  final int bookmarkCount;
  final bool isLiked;
  final bool isBookmarked;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.viewCount,
    required this.isDeleted,
    required this.authorNickname,
    required this.originalAuthorId,
    this.authorProfileImageUrl,
    required this.createdAt,
    this.updatedAt,
    required this.isSellable,
    required this.isSold,
    required this.likeCount,
    required this.commentCount,
    required this.bookmarkCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json, {bool isLiked = false, bool isBookmarked = false}) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '제목 없음',
      content: json['content'] ?? '',
      // String을 PostCategory enum으로 변환
      category: PostCategory.values.firstWhere(
            (e) => e.name == json['category'],
        orElse: () => PostCategory.FREE_TALK,
      ),
      viewCount: (json['viewCount'] ?? 0).toInt(),
      isDeleted: json['deleted'] ?? false,
      authorNickname: json['authorNickname'] ?? '알 수 없음',
      originalAuthorId: json['originalAuthorId'] ?? 0,
      authorProfileImageUrl: json['authorProfileImageUrl'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'],
      isSellable: json['sellable'] ?? false,
      isSold: json['sold'] ?? false,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      bookmarkCount: json['bookmarkCount'] ?? 0,
      isLiked: isLiked,
      isBookmarked: isBookmarked,
    );
  }

  Post copyWith({
    bool? isLiked,
    bool? isBookmarked,
    int? likeCount,
  }) {
    return Post(
      id: this.id,
      title: this.title,
      content: this.content,
      category: this.category,
      viewCount: this.viewCount,
      isDeleted: this.isDeleted,
      authorNickname: this.authorNickname,
      originalAuthorId: this.originalAuthorId,
      authorProfileImageUrl: this.authorProfileImageUrl,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
      isSellable: this.isSellable,
      isSold: this.isSold,
      likeCount: likeCount ?? this.likeCount,
      commentCount: this.commentCount,
      bookmarkCount: this.bookmarkCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
