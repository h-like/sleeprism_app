// lib/presentation/providers/dream_interpretation_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/dream_interpretation_model.dart';
import '../../data/services/dream_interpretation_service.dart';

// UI 상태를 나타내는 enum
enum InterpretationStep { loading, selection, result, error }

class DreamInterpretationProvider with ChangeNotifier {
  final DreamInterpretationService _service = DreamInterpretationService();

  InterpretationStep _step = InterpretationStep.loading;
  InterpretationStep get step => _step;

  DreamInterpretationResponse? _interpretation;
  DreamInterpretationResponse? get interpretation => _interpretation;

  InterpretationOption? _selectedOption;
  InterpretationOption? get selectedOption => _selectedOption;

  String? _error;
  String? get error => _error;

  // AI 해몽 불러오기
  Future<void> fetchInterpretation(int postId, String token) async {
    // 상태 초기화
    _step = InterpretationStep.loading;
    _error = null;
    _interpretation = null;
    _selectedOption = null;
    notifyListeners();

    try {
      _interpretation = await _service.interpretDream(postId, token);

      // 이미 선택한 기록이 있는지 확인
      if (_interpretation?.selectedOptionIndex != null) {
        _selectedOption = _interpretation!.interpretationOptions
            .firstWhere((opt) => opt.optionIndex == _interpretation!.selectedOptionIndex);
        _step = InterpretationStep.result;
      } else {
        _step = InterpretationStep.selection;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _step = InterpretationStep.error;
    } finally {
      notifyListeners();
    }
  }

  // 사용자가 카드를 선택했을 때 호출
  Future<void> selectOption(InterpretationOption option, String token) async {
    _selectedOption = option;

    // 1초 후 결과 화면으로 전환 (카드 뒤집히는 애니메이션 시간)
    await Future.delayed(const Duration(milliseconds: 800));
    _step = InterpretationStep.result;
    notifyListeners();

    // 백그라운드에서 서버에 선택 결과 저장
    if (_interpretation != null && option.tarotCardId != null) {
      _service.selectInterpretationOption(
        interpretationId: _interpretation!.id,
        optionIndex: option.optionIndex,
        tarotCardId: option.tarotCardId!,
        token: token,
      );
    }
  }

  // 다시 선택하기
  void reset() {
    if (_interpretation != null) {
      _step = InterpretationStep.selection;
      _selectedOption = null;
      notifyListeners();
    }
  }

  // 모달이 닫힐 때 상태 초기화
  void clearState() {
    _step = InterpretationStep.loading;
    _interpretation = null;
    _selectedOption = null;
    _error = null;
  }
}
