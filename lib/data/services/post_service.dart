// lib/data/services/post_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';
import '../models/post_category.dart'; // PostCategory enum 임포트

class PostService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // 공통 헤더 생성
  Map<String, String> _getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // API 요청을 위한 공통 헬퍼 함수
  Future<List<Post>> _fetchPostsFromApi(String endpoint, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      // 목록 조회 API는 isLiked, isBookmarked 정보를 포함하지 않으므로 기본값 false로 처리
      return jsonData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('게시글 목록을 불러오는데 실패했습니다. (경로: $endpoint, 상태 코드: ${response.statusCode})');
    }
  }

  // --- 메소드 수정: 카테고리 필터링 기능 추가 ---
  Future<List<Post>> fetchPosts({PostCategory? category}) async {
    String endpoint = '/api/posts';
    if (category != null) {
      // 백엔드 API 형식에 맞게 쿼리 파라미터 추가 (예: /api/posts?category=DREAM_DIARY)
      endpoint += '?category=${category.name}';
    }
    return _fetchPostsFromApi(endpoint);
  }

  // 특정 게시글 상세 정보 가져오기
  Future<Post> fetchPostById(int postId, {String? token}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/posts/$postId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      final postJson = jsonDecode(utf8.decode(response.bodyBytes));
      bool isLiked = false;
      bool isBookmarked = false;

      if (token != null) {
        try {
          // 좋아요, 북마크 상태를 동시에 확인하여 API 호출 횟수를 줄임
          final results = await Future.wait([
            http.get(Uri.parse('$_baseUrl/api/posts/$postId/like/status'), headers: _getHeaders(token: token)),
            http.get(Uri.parse('$_baseUrl/api/posts/$postId/bookmark/status'), headers: _getHeaders(token: token)),
          ]);

          if (results[0].statusCode == 200) isLiked = jsonDecode(results[0].body)['isLiked'] ?? false;
          if (results[1].statusCode == 200) isBookmarked = jsonDecode(results[1].body)['isBookmarked'] ?? false;

        } catch (e) {
          print('Like/Bookmark status check failed: $e');
        }
      }
      return Post.fromJson(postJson, isLiked: isLiked, isBookmarked: isBookmarked);
    } else {
      throw Exception('게시글 상세 정보를 불러오는데 실패했습니다.');
    }
  }

  // 좋아요 토글
  Future<void> toggleLike(int postId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/posts/$postId/like'),
      headers: _getHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception('좋아요 처리에 실패했습니다.');
    }
  }

  // 북마크 토글
  Future<void> toggleBookmark(int postId, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/posts/$postId/bookmark'),
      headers: _getHeaders(token: token),
    );
    if (response.statusCode != 200) {
      throw Exception('북마크 처리에 실패했습니다.');
    }
  }

  // --- 검색 메소드 추가 ---
  Future<List<Post>> searchPosts({required String type, required String keyword}) async {
    final endpoint = '/api/posts/search?type=$type&keyword=$keyword';
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('게시글 검색에 실패했습니다.');
    }
  }

  // --- 기존 메소드들 내용 채우기 ---
  Future<List<Post>> fetchMyPosts(String token) async {
    return _fetchPostsFromApi('/api/me/posts', token: token);
  }

  Future<List<Post>> fetchLikedPosts(String token) async {
    return _fetchPostsFromApi('/api/me/liked-posts', token: token);
  }

  Future<List<Post>> fetchBookmarkedPosts(String token) async {
    return _fetchPostsFromApi('/api/me/bookmarked-posts', token: token);
  }
}
