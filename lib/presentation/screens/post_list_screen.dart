import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/presentation/screens/post_search_delegate.dart';
import '../../data/models/post_category.dart';
import '../providers/post_provider.dart';
import '../widgets/post_list_item.dart'; // 새로 만든 PostListItem 위젯 import

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
      Provider.of<PostProvider>(context, listen: false).fetchPostsFor(PostListType.all);
      _isInitialised = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        // AppBar 디자인은 기존 코드를 유지하거나 원하는 대로 수정할 수 있습니다.
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        actions: [
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

                // 새로고침 기능이 있는 ListView
                return RefreshIndicator(
                  onRefresh: () => postProvider.fetchPostsFor(PostListType.all),
                  child: ListView.builder(
                    // ListView의 상하단 기본 패딩 제거
                    padding: EdgeInsets.zero,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      // 새로 만든 PostListItem 위젯을 사용
                      return PostListItem(post: post);
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

  // 카테고리 필터 위젯 (기존 코드와 동일)
  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.0)),
      ),
      child: Consumer<PostProvider>(
        builder: (context, provider, child) {
          return DropdownButton<PostCategory?>(
            value: provider.selectedCategory,
            hint: const Text('전체 카테고리'),
            underline: const SizedBox(), // 밑줄 제거
            items: [
              const DropdownMenuItem<PostCategory?>(
                value: null,
                child: Text('전체'),
              ),
              ...PostCategory.values.map((category) {
                return DropdownMenuItem<PostCategory?>(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
            ],
            onChanged: (newValue) {
              provider.changeCategoryAndFetch(newValue);
            },
          );
        },
      ),
    );
  }
}
