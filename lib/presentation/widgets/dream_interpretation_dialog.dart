// lib/presentation/widgets/dream_interpretation_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package.provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:sleeprism_app/presentation/utils/apiConstants.dart';
import 'dart:math';

import '../providers/dream_interpretation_provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/dream_interpretation_model.dart';
// import '../../utils/api_constants.dart'; // 카드 뒷면 이미지 경로를 위해

class DreamInterpretationDialog extends StatefulWidget {
  const DreamInterpretationDialog({super.key});

  @override
  State<DreamInterpretationDialog> createState() => _DreamInterpretationDialogState();
}

class _DreamInterpretationDialogState extends State<DreamInterpretationDialog> {
  final Map<int, GlobalKey<FlipCardState>> _cardKeys = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.all(0),
      contentPadding: const EdgeInsets.all(16),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Consumer를 사용하여 Provider의 상태 변화에 따라 UI를 업데이트
      content: Consumer<DreamInterpretationProvider>(
        builder: (context, provider, child) {
          // 상태에 따라 다른 위젯을 보여줌
          switch (provider.step) {
            case InterpretationStep.loading:
              return _buildLoadingView();
            case InterpretationStep.error:
              return _buildErrorView(provider.error);
            case InterpretationStep.selection:
              return _buildSelectionView(provider);
            case InterpretationStep.result:
              return _buildResultView(provider);
          }
        },
      ),
    );
  }

  Widget _buildLoadingView() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('AI가 당신의 꿈을 분석하고 있습니다...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String? error) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('오류 발생', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          Text(error ?? '알 수 없는 오류가 발생했습니다.', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          )
        ],
      ),
    );
  }

  Widget _buildSelectionView(DreamInterpretationProvider provider) {
    final options = provider.interpretation?.interpretationOptions ?? [];
    // 각 카드에 대한 GlobalKey를 생성하거나 가져옵니다.
    for (var option in options) {
      _cardKeys.putIfAbsent(option.optionIndex, () => GlobalKey<FlipCardState>());
    }

    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('마음이 이끄는 카드를 선택하세요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('AI가 당신의 꿈을 분석하여 3개의 카드를 준비했습니다.', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          if (options.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: options.map((option) {
                final index = options.indexOf(option);
                return Transform.rotate(
                  angle: (index - 1) * (pi / 20), // 가운데를 중심으로 약간씩 회전
                  child: _buildFlipCard(option, provider),
                );
              }).toList(),
            )
          else
            const Text('해몽 옵션이 없습니다.'),
          const SizedBox(height: 16),
          TextButton(
            child: const Text('닫기'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(InterpretationOption option, DreamInterpretationProvider provider) {
    const cardWidth = 80.0;
    const cardHeight = cardWidth * 1.5;
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return GestureDetector(
      onTap: () {
        if (token != null) {
          // 카드를 뒤집고 provider에 선택 알림
          _cardKeys[option.optionIndex]?.currentState?.toggleCard();
          provider.selectOption(option, token);
        }
      },
      child: FlipCard(
        key: _cardKeys[option.optionIndex],
        flipOnTouch: false, // 직접 제어
        front: Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              // TODO: 카드 뒷면 이미지를 assets에 추가하고 경로 수정
              // image: NetworkImage('${ApiConstants.baseUrl}/images/tarot_back.png'),
              image: NetworkImage('/images/back_card.png'),
              // Image.asset('asset/images/back_card.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5),
            ],
          ),
        ),
        back: Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(option.tarotCardImageUrl ?? ''),
              fit: BoxFit.cover,
              onError: (e, s) => print('Error loading image: $e'),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(DreamInterpretationProvider provider) {
    final result = provider.selectedOption;
    if (result == null) return const Center(child: Text('결과를 표시할 수 없습니다.'));

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            result.tarotCardImageUrl ?? '',
            height: 180,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, st) => const Icon(Icons.image_not_supported, size: 100),
          ),
          const SizedBox(height: 16),
          Text(result.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(result.tarotCardName ?? '', style: const TextStyle(color: Colors.grey)),
          const Divider(height: 24),
          Text(result.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => provider.reset(),
                child: const Text('다시 선택'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    // 다이얼로그가 닫힐 때 Provider 상태를 안전하게 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<DreamInterpretationProvider>(context, listen: false).clearState();
      }
    });
    super.deactivate();
  }
}
