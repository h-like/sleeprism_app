// lib/presentation/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  // 위젯이 처음 빌드될 때 딱 한 번만 데이터를 불러오기 위한 플래그
  bool _isInitialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialised) {
      // Provider를 통해 데이터 로딩 함수 호출
      // listen: false 옵션으로 불필요한 재빌드를 방지
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
      _isInitialised = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumer 위젯을 사용해 PostProvider의 변화를 감지하고 UI를 다시 그립니다.
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 목록'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          // 1. 로딩 중일 때
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. 에러가 발생했을 때
          if (postProvider.errorMessage != null) {
            return Center(child: Text('에러 발생: ${postProvider.errorMessage}'));
          }
          // 3. 데이터가 없거나 비어있을 때
          if (postProvider.posts.isEmpty) {
            return const Center(child: Text('게시글이 없습니다.'));
          }

          // 4. 데이터 로딩에 성공했을 때
          final posts = postProvider.posts;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    post.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text('작성자: ${post.authorName}\n카테고리: ${post.category} | 조회수: ${post.viewCount}'),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: 나중에 게시글 상세 페이지로 이동하는 로직 구현
                    print('${post.title} tapped!');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
