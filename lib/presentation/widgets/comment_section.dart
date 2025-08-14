// lib/presentation/widgets/comment_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/comment_model.dart';
import '../utils/image_url_builder.dart';

/// 댓글 목록 전체를 표시하는 위젯
class CommentSection extends StatelessWidget {
  final List<Comment> comments;
  const CommentSection({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text('첫 댓글을 작성해보세요.'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) => _CommentItem(comment: comments[index]),
        childCount: comments.length,
      ),
    );
  }
}

/// 개별 댓글 및 대댓글을 표시하는 내부 위젯
class _CommentItem extends StatelessWidget {
  final Comment comment;
  final int depth; // 대댓글의 깊이 (들여쓰기용)

  const _CommentItem({required this.comment, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final authorProfileUrl = ImageUrlBuilder.build(comment.authorProfileImageUrl);
    final attachmentUrl = ImageUrlBuilder.build(comment.attachmentUrl);

    return Padding(
      // 깊이에 따라 왼쪽에 패딩을 줌
      padding: EdgeInsets.fromLTRB(16.0 + (24.0 * depth), 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 댓글 내용
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: authorProfileUrl != null ? NetworkImage(authorProfileUrl) : null,
                child: authorProfileUrl == null ? const Icon(Icons.person, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.authorNickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(comment.createdAt)), style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      comment.isDeleted ? '삭제된 댓글입니다.' : comment.content,
                      style: TextStyle(color: comment.isDeleted ? Colors.grey : null),
                    ),
                    if (comment.attachmentType == 'IMAGE' && attachmentUrl != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(attachmentUrl),
                        ),
                      ),
                    const SizedBox(height: 4),

                  ],
                ),
              ),
            ],
          ),
          // 대댓글 목록 (재귀적으로 표시)
          if (comment.children.isNotEmpty)
            ListView.builder(
              shrinkWrap: true, // 부모 스크롤 안에서 자신의 크기만큼만 차지
              physics: const NeverScrollableScrollPhysics(), // 중첩 스크롤 방지
              itemCount: comment.children.length,
              itemBuilder: (context, index) {
                // 깊이를 1 증가시켜 대댓글을 렌더링
                return _CommentItem(comment: comment.children[index], depth: depth + 1);
              },
            ),
        ],
      ),
    );
  }
}
