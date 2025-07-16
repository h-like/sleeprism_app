// lib/data/services/post_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  // ⚠️ 중요: 이 주소를 실제 백엔드 서버 주소로 변경해야 합니다!
  // - 안드로이드 에뮬레이터에서 로컬 PC의 서버에 접속할 때: 'http://10.0.2.2:8080'
  // - iOS 시뮬레이터 또는 실제 기기에서 접속할 때: PC의 실제 IP 주소 (예: 'http://192.168.0.5:8080')
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // 모든 게시글 목록을 가져오는 함수
  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/posts'));

    if (response.statusCode == 200) {
      // 응답이 성공적이면 JSON을 파싱합니다.
      // 한글 깨짐 방지를 위해 utf8.decode 사용
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));

      // JSON 리스트를 Post 객체 리스트로 변환
      return jsonData.map((json) => Post.fromJson(json)).toList();
    } else {
      // 응답이 실패하면 에러를 발생시킵니다.
      throw Exception('게시글을 불러오는데 실패했습니다. (상태 코드: ${response.statusCode})');
    }
  }
}
