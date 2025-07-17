// lib/data/models/post_category.dart

enum PostCategory {
  DREAM_DIARY,
  SLEEP_INFO,
  FREE_TALK,
}

// 화면에 표시할 한글 이름을 반환하는 확장 기능
extension PostCategoryExtension on PostCategory {
  String get displayName {
    switch (this) {
      case PostCategory.DREAM_DIARY:
        return '꿈 일기';
      case PostCategory.SLEEP_INFO:
        return '수면 정보';
      case PostCategory.FREE_TALK:
        return '자유로운 이야기';
      default:
        return '';
    }
  }
}
