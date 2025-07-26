import 'package:flutter/material.dart';

/// 글쓰기, 맨 위로 스크롤 기능을 제공하는 재사용 가능한 플로팅 액션 버튼 위젯
class ReusableFloatingActionButtons extends StatelessWidget {
  /// 맨 위로 스크롤 버튼 표시 여부
  final bool showScrollToTopButton;
  /// 글쓰기 버튼을 눌렀을 때 실행될 콜백
  final VoidCallback onWritePost;
  /// 맨 위로 스크롤 버튼을 눌렀을 때 실행될 콜백
  final VoidCallback onScrollToTop;

  const ReusableFloatingActionButtons({
    super.key,
    required this.showScrollToTopButton,
    required this.onWritePost,
    required this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // showScrollToTopButton이 true일 때만 버튼을 표시
        AnimatedOpacity(
          opacity: showScrollToTopButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton.small(
            heroTag: 'scrollToTop', // Hero 태그 중복 방지
            onPressed: onScrollToTop,
            tooltip: '맨 위로',
            child: const Icon(Icons.arrow_upward),
          ),
        ),
        const SizedBox(height: 16),
        // 글쓰기 버튼
        FloatingActionButton(
          heroTag: 'writePost', // Hero 태그 중복 방지
          onPressed: onWritePost,
          tooltip: '글쓰기',
          child: const Icon(Icons.edit),
        ),
      ],
    );
  }
}
