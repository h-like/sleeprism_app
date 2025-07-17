// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/presentation/screens/post_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../../data/models/post_model.dart';
import '../../data/models/user_model.dart'; // User 모델 import 추가

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 탭이 변경될 때마다 해당 목록을 불러옴
    _tabController.addListener(_fetchDataForTab);

    // 첫 화면 로딩 시, 첫 번째 탭의 데이터를 불러옴
    // initState에서는 context를 통한 provider 접근이 안전하지 않을 수 있으므로
    // didChangeDependencies 또는 addPostFrameCallback을 사용하는 것이 더 안정적입니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataForTab();
    });
  }

  void _fetchDataForTab() {
    // 탭 전환 애니메이션 중에는 호출하지 않도록 함
    if (!_tabController.indexIsChanging) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) return;

      PostListType currentType;
      switch (_tabController.index) {
        case 0:
          currentType = PostListType.myPosts;
          break;
        case 1:
          currentType = PostListType.likedPosts;
          break;
        case 2:
          currentType = PostListType.bookmarkedPosts;
          break;
        default:
          return;
      }
      // 이미 로딩된 데이터가 있다면 다시 호출하지 않음 (선택적 최적화)
      if (postProvider.postsFor(currentType).isEmpty) {
        postProvider.fetchPostsFor(currentType, token: token);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_fetchDataForTab);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // user 모델은 authProvider에서 가져오므로 직접적인 null 체크가 필요합니다.
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('로그인 정보가 없습니다. 다시 로그인해주세요.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildProfileHeader(user),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '내가 쓴 글'),
                    Tab(text: '좋아요'),
                    Tab(text: '북마크'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostList(PostListType.myPosts),
            _buildPostList(PostListType.likedPosts),
            // 오타 수정: PostList_buildPostList -> _buildPostList
            _buildPostList(PostListType.bookmarkedPosts),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    // 백엔드 기본 URL
    const String baseUrl = "http://10.0.2.2:8080";
    // 최종 이미지 URL
    String? finalImageUrl;
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      // 백엔드 DTO가 반환하는 URL이 /files/ 로 시작하는지, 아니면 파일명만 오는지 확인해야 합니다.
      // LocalStorageService를 보면 `/files/directory/filename` 형태로 반환하므로,
      // 이 경로를 그대로 사용하면 됩니다.
      finalImageUrl = baseUrl + user.profileImageUrl!;
    }


    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: finalImageUrl != null
                ? NetworkImage(finalImageUrl)
                : null,
            child: finalImageUrl == null
                ? const Icon(Icons.person, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nickname, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostList(PostListType type) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingFor(type)) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorFor(type) != null) {
          return Center(child: Text('에러: ${provider.errorFor(type)}'));
        }
        final posts = provider.postsFor(type);
        if (posts.isEmpty) {
          return const Center(child: Text('게시글이 없습니다.'));
        }
        return ListView.builder(
          padding: EdgeInsets.zero, // NestedScrollView 안에서는 padding을 0으로
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return ListTile(
              title: Text(post.title),
              subtitle: Text(post.authorNickname),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostDetailScreen(postId: post.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// TabBar를 SliverPersistentHeader에 고정시키기 위한 델리게이트
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // 배경색 설정
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
