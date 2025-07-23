import 'package:flutter/material.dart';
import 'package:sleeprism_app/data/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

// import '../../data/models/post.dart'; // Post 모델 import
import '../../data/models/post_category.dart'; // PostCategory 확장 기능 import
import '../screens/post_detail_screen.dart'; // 상세 페이지 import

/// 게시글 목록에 표시될 각 아이템을 디자인하는 위젯
class PostListItem extends StatelessWidget {
  final Post post;

  const PostListItem({super.key, required this.post});

  /// HTML 내용에서 첫 번째 이미지 URL을 추출하는 함수
  /// 이미지가 없으면 null을 반환합니다.
  String? _extractFirstImageUrl(String htmlContent) {
    // img 태그의 src 속성을 찾기 위한 정규식
    final RegExp regex = RegExp(r'<img[^>]+src="([^">]+)"');
    final Match? match = regex.firstMatch(htmlContent);

    if (match != null && match.groupCount >= 1) {
      String imageUrl = match.group(1)!;
      // Android 에뮬레이터에서 localhost 이미지를 볼 수 있도록 주소 변경
      // 실제 프로덕션 환경에서는 이 부분이 필요 없을 수 있습니다.
      if (imageUrl.contains('localhost:8080')) {
        imageUrl = imageUrl.replaceAll('localhost:8080', '10.0.2.2:8080');
      }
      return imageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // 게시글 내용(HTML)에서 썸네일로 사용할 이미지 URL 추출
    final thumbnailUrl = _extractFirstImageUrl(post.content);

    return InkWell(
      onTap: () {
        // 상세 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(postId: post.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 메인 콘텐츠 영역 (제목, 내용, 정보)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1-1. 카테고리 아이콘과 제목
                  Row(
                    children: [
                      Icon(post.category.icon, color: post.category.color, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // 1-2. 내용 미리보기 (HTML 태그 제거)
                  Text(
                    post.content
                        .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
                        .replaceAll('\n', ' ')
                        .trim(),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // 1-3. 하단 정보 (좋아요, 댓글, 작성 시간)
                  _buildFooter(),
                ],
              ),
            ),
            // 2. 썸네일 이미지 영역 (추출된 URL이 있을 경우)
            if (thumbnailUrl != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    // 이미지 로딩 중 에러 발생 시 처리
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 하단 정보 (좋아요, 댓글, 작성 시간) 위젯
  Widget _buildFooter() {
    return Row(
      children: [
        // 좋아요 수
        _buildIconWithText(Icons.favorite_border, post.likeCount.toString(), Colors.red.shade400),
        const SizedBox(width: 12),
        // 댓글 수
        _buildIconWithText(Icons.chat_bubble_outline, post.commentCount.toString(), Colors.blue.shade400),
        const Spacer(), // 남은 공간을 모두 차지하여 시간을 오른쪽 끝으로 보냄
        // 작성 시간 (timeago 포맷)
        Text(
          timeago.format(DateTime.parse(post.createdAt), locale: 'ko'),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  /// 아이콘과 텍스트를 함께 표시하는 작은 위젯
  Widget _buildIconWithText(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
