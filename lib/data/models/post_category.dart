// lib/data/models/post_category.dart

import 'dart:ui';

import 'package:flutter/material.dart';

enum PostCategory { DREAM_DIARY, SLEEP_INFO, FREE_TALK }

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
        return '자유';
    }
  }

  /// 카테고리별 아이콘
  IconData get icon {
    switch (this) {
      case PostCategory.DREAM_DIARY:
        return Icons.nightlight_round; // 꿈 일기: 달 아이콘
      case PostCategory.SLEEP_INFO:
        return Icons.bedtime_outlined; // 수면 정보: 침대 아이콘
      case PostCategory.FREE_TALK:
        return Icons.chat_bubble_outline; // 자유로운 이야기: 말풍선 아이콘
    }
  }

  /// 카테고리별 색상
  Color get color {
    switch (this) {
      case PostCategory.DREAM_DIARY:
        return Colors.purple.shade300; // 꿈 일기: 보라색
      case PostCategory.SLEEP_INFO:
        return Colors.blue.shade300; // 수면 정보: 파란색
      case PostCategory.FREE_TALK:
        return Colors.green.shade300; // 자유로운 이야기: 초록색
    }
  }
}
