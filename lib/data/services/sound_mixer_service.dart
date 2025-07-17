// lib/data/services/sound_mixer_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sound_mixer_models.dart';

class SoundMixerService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  // 내부 프리셋 사운드 목록 조회 (URL 변환 로직 추가)
  Future<List<SoundInfo>> fetchInternalSounds() async {
    final response = await http.get(Uri.parse('$_baseUrl/api/sounds/internal'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      // 여기서 baseUrl을 전달하여 모델 생성 시 완전한 URL을 만듭니다.
      return jsonData.map((json) => SoundInfo.fromInternalJson(json, _baseUrl)).toList();
    } else {
      throw Exception('Failed to load internal sounds');
    }
  }

  // Freesound 검색
  Future<List<SoundInfo>> searchFreesound(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/api/freesound-search?query=$query'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      final List<dynamic> results = jsonData['results'];
      return results.map((json) => SoundInfo.fromFreesoundJson(json)).toList();
    } else {
      throw Exception('Failed to search Freesound');
    }
  }

  // 나의 믹스 저장
  Future<void> saveMyMix(String mixName, String mixData, String token) async {
    await http.post(
      Uri.parse('$_baseUrl/api/me/sound-mixes'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'mixName': mixName, 'mixData': mixData}),
    );
  }

  // 나의 믹스 목록 조회
  Future<List<UserSoundMix>> fetchMyMixes(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/me/sound-mixes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonData.map((json) => UserSoundMix.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my mixes');
    }
  }
}
