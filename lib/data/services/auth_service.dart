// lib/data/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
// import '../models/auth_response_model.dart'; // AuthResponseDTO에 해당하는 모델

class AuthService {
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

  // 로그인 API 호출 (새로 작성하거나 기존 코드와 통합)
  // 이 메서드가 로그인 후 토큰을 저장하는 역할을 해야 합니다.
  Future<void> signIn(String email, String password) async {
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
      // AuthResponseDTO에 해당하는 모델이 있다면 그 모델을 사용합니다.
      // 여기서는 임시로 'accessToken'이라는 키를 사용했습니다.
      final accessToken = responseBody['accessToken'] as String?;
      if (accessToken != null) {
        await _saveToken(accessToken); // 로그인 성공 시 토큰 저장
      } else {
        throw Exception('Access token not found in response.');
      }
    } else {
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
  static const _tokenKey = 'auth_token';

  // 토큰을 로컬 저장소에 저장하는 메서드
  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // 로컬 저장소에서 토큰을 가져오는 메서드
  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 토큰을 삭제하는 메서드 (로그아웃 시)
  Future<void> deleteUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

}
