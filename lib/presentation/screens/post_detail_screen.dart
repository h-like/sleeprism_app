// lib/presentation/screens/post_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:sleeprism_app/data/services/auth_service.dart';
import 'package:sleeprism_app/presentation/screens/post_edit_screen.dart';

import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../providers/dream_interpretation_provider.dart'; // 해몽 프로바이더 임포트
import '../../data/models/post_category.dart'; // 카테고리 enum 임포트
import '../utils/image_url_builder.dart';
import '../widgets/comment_section.dart';
import '../widgets/dream_interpretation_dialog.dart'; // 해몽 다이얼로그 임포트

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentUserId();
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      Provider.of<PostProvider>(
        context,
        listen: false,
      ).fetchPostDetails(widget.postId, token);
    });
  }
  // 현재 로그인한 사용자 ID를 가져오는 메서드
  Future<void> _loadCurrentUserId() async {
    final authService = AuthService();
    try {
      final user = await authService.fetchUserProfile();
      setState(() {
        _currentUserId = user.id.toString();
        print('currentUserId: ${_currentUserId}');
      });
    } catch (e) {
      _currentUserId = null;
    }
  }

  @override
  void dispose() {
    // Provider의 clearPostDetails가 위젯 트리에서 PostProvider를 제거할 수 있으므로
    // addPostFrameCallback으로 다음 프레임에서 실행되도록 합니다.
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

  // --- AI 꿈 해몽 모달을 보여주는 함수 ---
  void _showDreamInterpretationDialog() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    // API 호출 시작
    Provider.of<DreamInterpretationProvider>(
      context,
      listen: false,
    ).fetchInterpretation(widget.postId, token);

    // 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false, // 로딩 중에는 닫히지 않도록 설정
      builder: (BuildContext context) {
        return const DreamInterpretationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _buildActionButtons(),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isDetailLoading || provider.detailedPost == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.detailError != null) {
            return Center(child: Text('에러: ${provider.detailError}'));
          }

          final post = provider.detailedPost!;
          final correctedHtmlContent = post.content.replaceAll(
            'localhost:8080',
            '10.0.2.2:8080',
          );

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            // 작성자
                            _buildAuthorInfo(post),
                            const Divider(height: 32),
                            HtmlWidget(correctedHtmlContent),
                            const SizedBox(height: 16),
                            // --- 게시글 하단 버튼 영역 ---
                            _buildBottomButtons(context, provider),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: Divider(thickness: 8)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          '댓글 ${post.commentCount}개',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    provider.isCommentsLoading
                        ? const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    )
                        : CommentSection(comments: provider.comments),
                  ],
                ),
              ),
              _buildCommentInputField(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAuthorInfo(post) {
    final authorProfileUrl = ImageUrlBuilder.build(post.authorProfileImageUrl);
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage:
          authorProfileUrl != null ? NetworkImage(authorProfileUrl) : null,
          child: authorProfileUrl == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.authorNickname,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              // post.createdAt,
                DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(post.createdAt)),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  // --- 기존 _buildActionButtons를 _buildBottomButtons로 변경하고 해몽 버튼 추가 ---
  Widget _buildBottomButtons(BuildContext context, PostProvider provider) {
    final post = provider.detailedPost!;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final bool isDreamDiary = post.category == PostCategory.DREAM_DIARY;

    return Column(
      children: [
        // --- 꿈 일기일 때만 해몽 버튼 표시 ---
        if (isDreamDiary)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showDreamInterpretationDialog,
                icon: const Icon(Icons.psychology_outlined),
                label: const Text('AI로 해몽하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

        // 기존 버튼들 (좋아요, 북마크, 공유)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed:
              token == null
                  ? null
                  : () => provider.toggleLikeOnDetail(token),
              icon: Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : null,
              ),
              label: Text('좋아요 ${post.likeCount}'),
            ),
            TextButton.icon(
              onPressed:
              token == null
                  ? null
                  : () => provider.toggleBookmarkOnDetail(token),
              icon: Icon(
                post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: post.isBookmarked ? Colors.amber : null,
              ),
              label: const Text('북마크'),
            ),
            TextButton.icon(
              onPressed: () {
                /* TODO: 공유 기능 */
              },
              icon: const Icon(Icons.share),
              label: const Text('공유'),
            ),
          ],
        ),
      ],
    );
  }


  List<Widget> _buildActionButtons() {
    final post = Provider.of<PostProvider>(context).detailedPost;
      print('게시글의 오리지널 작가 ${post?.originalAuthorId} 현재 유저: ${_currentUserId}');

    print('type check authorId: ${post!.originalAuthorId} (${post.originalAuthorId.runtimeType}), '
        'currentUser: $_currentUserId (${_currentUserId.runtimeType})');

    if (post != null && post.originalAuthorId.toString() == _currentUserId) {
      print('authorId: ${post?.originalAuthorId}, currentUser: $_currentUserId');
      return [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PostEditScreen(
                  postId: post.id,
                  initialTitle: post.title,
                  initialHtml: post.content,
                  initialCategory: post.category,
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _showDeleteDialog(context, post.id.toString()),
        ),
      ];
    }
    return [];
  }

  void _showDeleteDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 이 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await context.read<PostProvider>().deletePost(id: postId);
                Navigator.of(context).pop(); // 상세 페이지에서 나가기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('게시글이 삭제되었습니다.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('삭제 실패: $e')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        8,
        8 + MediaQuery.of(context).padding.bottom,
      ),
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
          IconButton(icon: const Icon(Icons.send), onPressed: _postComment),
        ],
      ),
    );
  }
}
