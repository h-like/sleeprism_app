// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
// import '../models/auth_response_model.dart'; // AuthResponseDTO에 해당하는 모델

class AuthService {
  // ⚠️ 중요: 이 주소를 실제 백엔드 서버 주소로 변경해야 합니다!
  static const String _baseUrl = 'http://10.0.2.2:8080';
  final _storage = const FlutterSecureStorage();

  // JWT 토큰을 안전하게 저장
  Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // 저장된 JWT 토큰을 읽어옴
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // 토큰 삭제 (로그아웃)
  Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // 로그인 API 호출
  Future<AuthResponse> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/users/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      final authResponse = AuthResponse.fromJson(responseBody);
      // 로그인이 성공하면 토큰을 저장
      await _saveToken(authResponse.accessToken);
      return authResponse;
    } else {
      // TODO: 서버에서 오는 에러 메시지를 파싱해서 보여주면 더 좋습니다.
      throw Exception('로그인에 실패했습니다.');
    }
  }

  // 내 프로필 정보 가져오기
  Future<User> fetchUserProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('인증 토큰이 없습니다. 로그인이 필요합니다.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // 헤더에 토큰 추가
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('프로필 정보를 불러오는데 실패했습니다.');
    }
  }
}

// AuthResponseDTO를 위한 모델
class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({required this.accessToken, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      user: User.fromJson(json['user']),
    );
  }
}
