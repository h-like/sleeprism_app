// lib/data/services/comment_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment_model.dart';

class CommentService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // 특정 게시글의 댓글 목록 가져오기
  Future<List<Comment>> fetchCommentsByPostId(int postId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/comments/post/$postId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('댓글을 불러오는데 실패했습니다.');
    }
  }
}
