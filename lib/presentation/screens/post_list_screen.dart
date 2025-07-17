// lib/presentation/screens/post_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/presentation/screens/post_search_delegate.dart';
import '../../data/models/post_category.dart';
import '../providers/post_provider.dart';
import 'post_detail_screen.dart'; // 상세 페이지 import

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  bool _isInitialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialised) {
      // PostListType.all 타입의 게시글을 불러옴
      Provider.of<PostProvider>(context, listen: false).fetchPostsFor(PostListType.all);
      _isInitialised = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          // 검색 아이콘 버튼 추가
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PostSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 카테고리 필터 드롭다운 메뉴
          _buildCategoryFilter(),
          // 게시글 목록
          Expanded(
            child: Consumer<PostProvider>(
              builder: (context, postProvider, child) {
                final posts = postProvider.postsFor(PostListType.all);
                final isLoading = postProvider.isLoadingFor(PostListType.all);
                final error = postProvider.errorFor(PostListType.all);

                if (isLoading && posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (error != null) {
                  return Center(child: Text('에러 발생: $error'));
                }
                if (posts.isEmpty) {
                  return const Center(child: Text('게시글이 없습니다.'));
                }

                return RefreshIndicator(
                  onRefresh: () => postProvider.fetchPostsFor(PostListType.all),
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text('작성자: ${post.authorNickname}\n카테고리: ${post.category} | 조회수: ${post.viewCount}'),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PostDetailScreen(postId: post.id)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 필터 위젯
  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.centerRight,
      child: Consumer<PostProvider>(
        builder: (context, provider, child) {
          return DropdownButton<PostCategory?>(
            value: provider.selectedCategory,
            hint: const Text('전체 카테고리'),
            underline: const SizedBox(), // 밑줄 제거
            items: [
              // '전체' 메뉴 아이템
              const DropdownMenuItem<PostCategory?>(
                value: null,
                child: Text('전체'),
              ),
              // Enum으로부터 메뉴 아이템 목록 생성
              ...PostCategory.values.map((category) {
                return DropdownMenuItem<PostCategory?>(
                  value: category,
                  child: Text(category.displayName), // 한글 이름으로 표시
                );
              }).toList(),
            ],
            onChanged: (newValue) {
              // Provider의 메소드를 호출하여 카테고리 변경
              provider.changeCategoryAndFetch(newValue);
            },
          );
        },
      ),
    );
  }
}
