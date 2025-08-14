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
  String? _token;

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

  Future<String?> socialLogin(String provider, String socialToken) async {
    // API 엔드포인트 URL을 생성합니다.
    final url = Uri.parse('$_baseUrl/oauth2/authorization');

    debugPrint("[ApiService] socialLogin: Requesting to $url");
    debugPrint("[ApiService] socialLogin: Provider=$provider");

    try {
      // 백엔드로 POST 요청을 보냅니다.
      final response = await http.post(
        url,
        headers: {
          // 요청 본문이 JSON 형식임을 명시합니다.
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // 백엔드와 약속된 key 값으로 데이터를 전송합니다.
          'provider': provider,
          'token': socialToken,
        }),
      );

      // --- 응답 처리 ---

      // 요청이 성공적으로 처리되었을 경우 (HTTP 상태 코드 200 또는 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("[ApiService] socialLogin: Success. Status code: ${response.statusCode}");
        final responseBody = jsonDecode(response.body);

        // 백엔드가 반환해주는 JWT 토큰을 추출합니다. ('token' 또는 'accessToken' 등 백엔드 응답 key에 맞춰주세요)
        final jwtToken = responseBody['token'] as String?;

        if (jwtToken != null) {
          _token = jwtToken; // ApiService 내부 토큰 업데이트
          debugPrint("[ApiService] socialLogin: JWT Token received.");
          return jwtToken;
        } else {
          debugPrint("[ApiService] socialLogin: Token is null in response body.");
          throw Exception('소셜 로그인 후 토큰을 받지 못했습니다.');
        }
      } else {
        // 요청이 실패한 경우 (4xx, 5xx 에러)
        debugPrint("[ApiService] socialLogin: Failed. Status code: ${response.statusCode}");
        debugPrint("[ApiService] socialLogin: Response body: ${response.body}");
        throw Exception('소셜 로그인에 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      debugPrint("[ApiService] socialLogin: An exception occurred. Error: $e");
      throw Exception('소셜 로그인 중 오류가 발생했습니다.');
    }
  }
}
