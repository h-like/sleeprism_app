
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
      debugPrint("[ApiService] Login failed with status code: ${response.statusCode}");
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
      debugPrint("[ApiService] getMe failed with status code: ${response.statusCode}");
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
      throw Exception('Failed to load notifications. Status Code: ${response.statusCode}');
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
      throw Exception('Failed to load chat rooms. Status Code: ${response.statusCode}');
    }
  }
}