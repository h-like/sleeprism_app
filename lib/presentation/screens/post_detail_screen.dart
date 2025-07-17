// lib/presentation/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../utils/image_url_builder.dart';
import '../widgets/comment_section.dart'; // 새로 만든 댓글 섹션 위젯 임포트

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<PostProvider>(context, listen: false).fetchPostDetails(widget.postId, token);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<PostProvider>(context, listen: false).clearPostDetails();
      }
    });
    _commentController.dispose();
    super.dispose();
  }

  void _postComment() {
    if (_commentController.text.isEmpty) return;
    // TODO: 댓글 작성 API 연동
    print('Posting comment: ${_commentController.text}');
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading || provider.detailedPost == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.detailError != null) {
            return Center(child: Text('에러: ${provider.detailError}'));
          }

          final post = provider.detailedPost!;
          final correctedHtmlContent = post.content.replaceAll('localhost:8080', '10.0.2.2:8080');

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // 1. 게시글 내용
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            _buildAuthorInfo(post),
                            const Divider(height: 32),
                            HtmlWidget(correctedHtmlContent),
                            const SizedBox(height: 16),
                            _buildActionButtons(context, provider),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(thickness: 8)),
                    // 2. 댓글 목록 헤더
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('댓글 ${post.commentCount}개', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // --- 3. 분리된 댓글 섹션 위젯 사용 ---
                    provider.isCommentsLoading
                        ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                        : CommentSection(comments: provider.comments),
                  ],
                ),
              ),
              // 4. 댓글 입력창
              _buildCommentInputField(),
            ],
          );
        },
      ),
    );
  }

  // --- 아래의 _buildCommentList와 _buildCommentItem 메소드는 CommentSection으로 이동했으므로 삭제 ---

  Widget _buildAuthorInfo(post) {
    final authorProfileUrl = ImageUrlBuilder.build(post.authorProfileImageUrl);
    return Row(children: [
      CircleAvatar(
        radius: 20,
        backgroundImage: authorProfileUrl != null ? NetworkImage(authorProfileUrl) : null,
        child: authorProfileUrl == null ? const Icon(Icons.person) : null,
      ),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(post.authorNickname, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(post.createdAt, style: Theme.of(context).textTheme.bodySmall),
      ]),
    ]);
  }

  Widget _buildActionButtons(BuildContext context, PostProvider provider) {
    // ... (기존과 동일)
    final post = provider.detailedPost!;
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton.icon(
          onPressed: token == null ? null : () => provider.toggleLikeOnDetail(token),
          icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border, color: post.isLiked ? Colors.red : null),
          label: Text('좋아요 ${post.likeCount}'),
        ),
        TextButton.icon(
          onPressed: token == null ? null : () => provider.toggleBookmarkOnDetail(token),
          icon: Icon(post.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: post.isBookmarked ? Colors.amber : null),
          label: const Text('북마크'),
        ),
        TextButton.icon(
          onPressed: () { /* TODO: 공유 기능 */ },
          icon: const Icon(Icons.share),
          label: const Text('공유'),
        ),
      ],
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _postComment,
          ),
        ],
      ),
    );
  }
}
