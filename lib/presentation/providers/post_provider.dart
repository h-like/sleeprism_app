// lib/presentation/providers/post_provider.dart

import 'package:flutter/material.dart';
import 'package:sleeprism_app/data/models/post_category.dart';

// import 'package.flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/post_model.dart';
import '../../data/services/comment_service.dart';
import '../../data/services/post_service.dart';

// 여러 종류의 게시글 목록을 관리하기 위한 열거형
enum PostListType { all, myPosts, likedPosts, bookmarkedPosts }

class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();
  final CommentService _commentService = CommentService();

  // --- 목록 페이지 상태 ---
  Map<PostListType, List<Post>> _posts = {};
  Map<PostListType, bool> _isLoading = {};
  Map<PostListType, String?> _errorMessages = {};
  PostCategory? _selectedCategory; // 선택된 카테고리 상태 추가


  // --- 상세 페이지 상태 ---
  Post? _detailedPost;
  bool _isDetailLoading = false;
  String? _detailError;

  List<Comment> _comments = [];
  bool _isCommentsLoading = false;
  String? _commentsError;

  // --- 검색 상태 변수  ---
  List<Post> _searchResults = [];
  bool _isSearchLoading = false;
  String? _searchError;

  // --- 목록 페이지 Getter ---
  List<Post> postsFor(PostListType type) => _posts[type] ?? [];
  bool isLoadingFor(PostListType type) => _isLoading[type] ?? false;
  String? errorFor(PostListType type) => _errorMessages[type];

  // --- 상세 페이지 Getter ---
  Post? get detailedPost => _detailedPost;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailError => _detailError;
  PostCategory? get selectedCategory => _selectedCategory;

  List<Comment> get comments => _comments;
  bool get isCommentsLoading => _isCommentsLoading;
  String? get commentsError => _commentsError;

  // --- 검색 Getter 추가 ---
  List<Post> get searchResults => _searchResults;
  bool get isSearchLoading => _isSearchLoading;
  String? get searchError => _searchError;

  // 카테고리 변경 및 데이터 리프레시
  Future<void> changeCategoryAndFetch(PostCategory? category) async {
    _selectedCategory = category;
    // PostListType.all 목록을 새로운 카테고리로 다시 불러옴
    await fetchPostsFor(PostListType.all);
  }

  // --- 목록 페이지 메소드 ---
  Future<void> fetchPostsFor(PostListType type, {String? token}) async {
    if (isLoadingFor(type)) return;

    _isLoading[type] = true;
    _errorMessages[type] = null;
    notifyListeners();

    try {
      switch (type) {
        case PostListType.all:
          _posts[type] = await _postService.fetchPosts(category: _selectedCategory);
          break;
        case PostListType.myPosts:
          _posts[type] = await _postService.fetchMyPosts(token!);
          break;
        case PostListType.likedPosts:
          _posts[type] = await _postService.fetchLikedPosts(token!);
          break;
        case PostListType.bookmarkedPosts:
          _posts[type] = await _postService.fetchBookmarkedPosts(token!);
          break;
      }
    } catch (e) {
      _errorMessages[type] = e.toString();
    } finally {
      _isLoading[type] = false;
      notifyListeners();
    }
  }

  // --- 상세 페이지 메소드 ---

  // 특정 게시글의 상세 정보와 댓글을 모두 불러옵니다.
  Future<void> fetchPostDetails(int postId, String? token) async {
    // 상세 페이지 데이터 초기화
    _isDetailLoading = true;
    _isCommentsLoading = true;
    notifyListeners();

    // 게시글 상세 정보 가져오기
    try {
      _detailedPost = await _postService.fetchPostById(postId, token: token);
      _detailError = null;
    } catch (e) {
      _detailError = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }

    // 댓글 목록 가져오기
    try {
      _comments = await _commentService.fetchCommentsByPostId(postId);
      _commentsError = null;
    } catch (e) {
      _commentsError = e.toString();
    } finally {
      _isCommentsLoading = false;
      notifyListeners();
    }
  }

  // 상세 페이지의 게시글에 좋아요 토글
  Future<void> toggleLikeOnDetail(String token) async {
    if (_detailedPost == null) return;

    final originalPost = _detailedPost!;
    final originalLiked = originalPost.isLiked;
    final originalLikeCount = originalPost.likeCount;

    // UI 즉시 업데이트 (Optimistic Update)
    _detailedPost = originalPost.copyWith(
      isLiked: !originalLiked,
      likeCount: originalLiked ? originalLikeCount - 1 : originalLikeCount + 1,
    );
    notifyListeners();

    try {
      // API 호출
      await _postService.toggleLike(originalPost.id, token);
    } catch (e) {
      // 실패 시 UI 롤백
      _detailedPost = originalPost;
      notifyListeners();
      // 사용자에게 에러 알림 (예: SnackBar)
    }
  }

  // --- 검색 메소드 추가 ---
  Future<void> searchPosts(String keyword, {String type = 'title'}) async {
    if (keyword.isEmpty) return;

    _isSearchLoading = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _postService.searchPosts(type: type, keyword: keyword);
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  // 상세 페이지의 게시글에 북마크 토글
  Future<void> toggleBookmarkOnDetail(String token) async {
    if (_detailedPost == null) return;

    final originalPost = _detailedPost!;
    final originalBookmarked = originalPost.isBookmarked;

    _detailedPost = originalPost.copyWith(isBookmarked: !originalBookmarked);
    notifyListeners();

    try {
      await _postService.toggleBookmark(originalPost.id, token);
    } catch (e) {
      _detailedPost = originalPost;
      notifyListeners();
    }
  }

  // 상세 페이지 데이터 초기화 (화면을 나갈 때 호출)
  void clearPostDetails() {
    _detailedPost = null;
    _comments = [];
    _detailError = null;
    _commentsError = null;
  }
}
