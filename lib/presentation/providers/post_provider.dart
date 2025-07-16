// lib/presentation/providers/post_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/post_model.dart';
import '../../data/services/post_service.dart';

// ChangeNotifier를 상속받아 변화를 감지하고 알릴 수 있게 합니다.
class PostProvider with ChangeNotifier {
  final PostService _postService = PostService();

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 외부에서 안전하게 데이터에 접근할 수 있도록 getter를 제공합니다.
  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 게시글 데이터를 불러오는 메소드
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // 상태 변경을 UI에 알림 (로딩 시작)

    try {
      _posts = await _postService.fetchPosts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // 상태 변경을 UI에 알림 (로딩 끝 또는 에러 발생)
    }
  }
}
