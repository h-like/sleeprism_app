// lib/presentation/providers/sound_mixer_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/sound_mixer_models.dart';
import '../../data/services/sound_mixer_service.dart';

// 현재 재생 중인 사운드의 상태를 관리하는 클래스
class ActiveSound {
  final SoundInfo soundInfo;
  final AudioPlayer player;
  double volume;

  ActiveSound({required this.soundInfo, required this.player, this.volume = 0.5});
}

class SoundMixerProvider with ChangeNotifier {
  final SoundMixerService _service = SoundMixerService();

  // --- 상태 변수 ---
  List<SoundInfo> _internalSounds = [];
  List<UserSoundMix> _myMixes = [];
  bool _isLoading = false;
  final Map<String, ActiveSound> _activeSounds = {};


  // --- 검색 관련 상태 변수 추가 ---
  List<SoundInfo> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;

  // --- Getter ---
  List<SoundInfo> get internalSounds => _internalSounds;
  Map<String, ActiveSound> get activeSounds => _activeSounds;
  bool get isLoading => _isLoading;
  List<SoundInfo> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get searchError => _searchError;


  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _internalSounds = await _service.fetchInternalSounds();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  // 사운드 재생/정지 토글
  Future<void> togglePlay(SoundInfo sound) async {
    if (_activeSounds.containsKey(sound.id)) {
      // 이미 재생 중이면 정지 및 제거
      final activeSound = _activeSounds.remove(sound.id)!;
      await activeSound.player.stop();
      await activeSound.player.dispose();
    } else {
      // 새로 재생
      final player = AudioPlayer();
      try {
        await player.setUrl(sound.url);
        await player.setLoopMode(LoopMode.one); // 반복 재생
        player.play();
        _activeSounds[sound.id] = ActiveSound(soundInfo: sound, player: player);
      } catch (e) {
        print("Error playing sound: $e");
        player.dispose();
      }
    }
    notifyListeners();
  }

  // 볼륨 조절
  void changeVolume(String soundId, double volume) {
    if (_activeSounds.containsKey(soundId)) {
      final activeSound = _activeSounds[soundId]!;
      activeSound.volume = volume;
      activeSound.player.setVolume(volume);
      notifyListeners();
    }
  }

  // 현재 믹스 저장
  Future<void> saveCurrentMix(String mixName, String token) async {
    final mixDataList = _activeSounds.values.map((s) => {
      'soundId': s.soundInfo.id,
      'volume': s.volume,
    }).toList();
    final mixDataJson = jsonEncode(mixDataList);
    await _service.saveMyMix(mixName, mixDataJson, token);
    // TODO: 저장 후 '나의 믹스' 목록 갱신
  }

  // --- [추가] Freesound 검색 메소드 ---
  Future<void> searchFreesound(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      _searchResults = await _service.searchFreesound(query);
    } catch (e) {
      _searchError = e.toString();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Provider가 소멸될 때 모든 플레이어 정리
  @override
  void dispose() {
    for (var sound in _activeSounds.values) {
      sound.player.dispose();
    }
    _activeSounds.clear();
    super.dispose();
  }
}
