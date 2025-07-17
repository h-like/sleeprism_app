// lib/presentation/screens/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import 'post_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 탭 컨트롤러 초기화 (기간 4개)
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);

    // 첫 화면 로딩 시, 기본 선택된 '주간' 탭의 데이터를 불러옴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPopularPosts();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final provider = Provider.of<PostProvider>(context, listen: false);
    // 탭 인덱스에 맞는 기간으로 변경하고 데이터 요청
    provider.changePeriodAndFetch(PopularPostPeriod.values[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '오늘'),
            Tab(text: '주간'),
            Tab(text: '월간'),
            Tab(text: '전체'),
          ],
        ),
      ),
      body: Consumer<PostProvider>(
        builder: (context, provider, child) {
          if (provider.isPopularLoading && provider.popularPosts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.popularError != null) {
            return Center(child: Text('에러: ${provider.popularError}'));
          }
          if (provider.popularPosts.isEmpty) {
            return const Center(child: Text('인기 게시글이 없습니다.'));
          }

          final posts = provider.popularPosts;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                leading: _buildRankingBadge(index + 1),
                title: Text(post.title),
                subtitle: Text('❤️ ${post.likeCount}  💬 ${post.commentCount}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // 랭킹 배지 위젯
  Widget _buildRankingBadge(int rank) {
    Color badgeColor = Colors.grey;
    if (rank == 1) badgeColor = const Color(0xFFFFD700); // Gold
    if (rank == 2) badgeColor = const Color(0xFFC0C0C0); // Silver
    if (rank == 3) badgeColor = const Color(0xFFCD7F32); // Bronze

    return CircleAvatar(
      radius: 16,
      backgroundColor: badgeColor,
      child: Text(
        rank.toString(),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
