// lib/presentation/screens/post_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import 'post_detail_screen.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  // 검색창 placeholder 텍스트
  @override
  String get searchFieldLabel => '게시글 검색';

  // AppBar의 액션 버튼 (오른쪽 아이콘)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // 검색어 초기화
        },
      ),
    ];
  }

  // AppBar의 리딩 버튼 (왼쪽 아이콘)
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null); // 검색창 닫기
      },
    );
  }

  // 검색 결과 UI
  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('검색어를 입력해주세요.'));
    }
    // 검색어가 입력되면 검색 실행
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    postProvider.searchPosts(query);

    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        if (provider.isSearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.searchError != null) {
          return Center(child: Text('검색 중 오류 발생: ${provider.searchError}'));
        }
        if (provider.searchResults.isEmpty) {
          return const Center(child: Text('검색 결과가 없습니다.'));
        }

        final results = provider.searchResults;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final post = results[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.authorNickname),
              onTap: () {
                close(context, post); // 검색창 닫고 결과 전달
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostDetailScreen(postId: post.id)),
                );
              },
            );
          },
        );
      },
    );
  }

  // 검색어 제안 UI (입력 중일 때 표시)
  @override
  Widget buildSuggestions(BuildContext context) {
    // 여기서는 간단히 비워두거나, 최근 검색어 목록 등을 보여줄 수 있습니다.
    return const SizedBox.shrink();
  }
}
