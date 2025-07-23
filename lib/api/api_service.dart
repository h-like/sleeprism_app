import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sleeprism_app/data/models/chat_room_model.dart';
import 'package:sleeprism_app/data/models/notification_model.dart';
import 'package:sleeprism_app/data/models/user_model.dart';

// import '../models/notification_model.dart';
// import '../models/chat_room_model.dart';

class ApiService {
  final String _baseUrl = "http://10.0.2.2:8080";
  final _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _secureStorage.read(key: 'jwt_token');
    if (token != null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    }
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/signin'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['accessToken'];
    } else {
      debugPrint(
        "[ApiService] Login failed with status code: ${response.statusCode}",
      );
      return null;
    }
  }

  Future<User> getMe() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/users/me'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      debugPrint(
        "[ApiService] getMe failed with status code: ${response.statusCode}",
      );
      throw Exception('Failed to load user information');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/me/notifications'), // 이제 이 엔드포인트가 유효합니다.
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load notifications. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<List<ChatRoomModel>> getChatRooms() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/chats/rooms'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => ChatRoomModel.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load chat rooms. Status Code: ${response.statusCode}',
      );
    }
  }

  Future<String?> uploadChatFile(String filePath) async {
    final uri = Uri.parse('$_baseUrl/api/chats/files/upload');
    final request = http.MultipartRequest('POST', uri);

    // 헤더 추가
    final headers = await _getHeaders();
    request.headers.addAll(headers);

    // 파일 추가
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // 백엔드 @RequestParam("file")과 일치
        filePath,
        // contentType: MediaType('image', 'jpeg'), // 파일 타입에 맞게 수정 가능
      ),
    );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['fileUrl']; // 백엔드가 반환하는 URL 키
      } else {
        debugPrint("File upload failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("File upload failed with error: $e");
      return null;
    }
  }
}
