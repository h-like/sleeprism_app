// lib/data/services/dream_interpretation_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sleeprism_app/presentation/utils/apiConstants.dart';
import '../models/dream_interpretation_model.dart';
// import '../../utils/api_constants.dart';

class DreamInterpretationService {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  // AI 꿈 해몽 요청 API
  Future<DreamInterpretationResponse> interpretDream(int postId, String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/dream-interpretations/interpret');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'postId': postId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        return DreamInterpretationResponse.fromJson(jsonDecode(responseBody));
      } else {
        final errorBody = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorBody['errorMessage'] ?? '꿈 해몽을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('꿈 해몽 API 호출 중 에러 발생: $e');
    }
  }

  // 사용자가 선택한 해몽을 서버에 저장하는 API
  Future<void> selectInterpretationOption({
    required int interpretationId,
    required int optionIndex,
    required int tarotCardId,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/dream-interpretations/$interpretationId/select');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'selectedOptionIndex': optionIndex,
          'selectedTarotCardId': tarotCardId,
        }),
      );

      if (response.statusCode != 200) {
        // 실패했지만 클라이언트 경험에 치명적이지 않으므로 로그만 남깁니다.
        print('Failed to save selection: ${response.body}');
      }
    } catch (e) {
      print('Error saving selection: $e');
    }
  }
}
