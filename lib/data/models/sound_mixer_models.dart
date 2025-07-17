// lib/data/models/sound_mixer_models.dart

/// 백엔드(/api/sounds/internal) 또는 Freesound API의 사운드 정보를 담는 모델
class SoundInfo {
  final String id;
  final String name;
  final String url; // 실제 오디오 파일의 전체 URL
  final String? icon; // 내부 프리셋용 이모지 아이콘

  SoundInfo({
    required this.id,
    required this.name,
    required this.url,
    this.icon,
  });

  // 백엔드의 /api/sounds/internal 응답을 위한 생성자
  factory SoundInfo.fromInternalJson(Map<String, dynamic> json, String baseUrl) {
    return SoundInfo(
      id: json['id'],
      name: json['name'],
      url: baseUrl + json['url'], // baseUrl과 합쳐 전체 URL 생성
      icon: json['name'].split(' ').last, // 이름에서 이모지 추출
    );
  }

  // Freesound API 응답을 위한 생성자
  factory SoundInfo.fromFreesoundJson(Map<String, dynamic> json) {
    return SoundInfo(
      id: json['id'].toString(),
      name: json['name'],
      // Freesound는 여러 품질의 미리듣기를 제공하므로, 그중 하나를 선택
      url: json['previews']['preview-hq-mp3'] ?? json['previews']['preview-lq-mp3'],
    );
  }
}

/// 사용자가 저장한 믹스 프리셋 정보를 담는 모델
class UserSoundMix {
  final int id;
  final String mixName;
  final String mixData; // JSON 문자열 형태의 믹스 데이터

  UserSoundMix({
    required this.id,
    required this.mixName,
    required this.mixData,
  });

  factory UserSoundMix.fromJson(Map<String, dynamic> json) {
    return UserSoundMix(
      id: json['id'],
      mixName: json['mixName'],
      mixData: json['mixData'],
    );
  }
}
