// lib/data/models/dream_interpretation_model.dart

// API 응답의 최상위 구조
import 'package:sleeprism_app/presentation/utils/image_url_builder.dart';

class DreamInterpretationResponse {
  final int id;
  final int postId;
  final List<InterpretationOption> interpretationOptions;
  final int? selectedOptionIndex;
  final String? errorMessage;

  DreamInterpretationResponse({
    required this.id,
    required this.postId,
    required this.interpretationOptions,
    this.selectedOptionIndex,
    this.errorMessage,
  });

  factory DreamInterpretationResponse.fromJson(Map<String, dynamic> json) {
    var optionsList = json['interpretationOptions'] as List? ?? [];
    // 백엔드에서 받은 원본 JSON을 InterpretationOption으로 변환합니다.
    List<InterpretationOption> options = optionsList
        .map((i) => InterpretationOption.fromJson(i))
        .toList();

    return DreamInterpretationResponse(
      id: json['id'],
      postId: json['postId'],
      interpretationOptions: options,
      selectedOptionIndex: json['selectedOptionIndex'],
      errorMessage: json['errorMessage'],
    );
  }
}

// 각 해몽 선택지 구조
class InterpretationOption {
  final int optionIndex;
  final String title;
  final String content;
  final int? tarotCardId;
  final String? tarotCardName;
  final String? tarotCardImageUrl;

  InterpretationOption({
    required this.optionIndex,
    required this.title,
    required this.content,
    this.tarotCardId,
    this.tarotCardName,
    this.tarotCardImageUrl,
  });

  // --- 수정된 fromJson 팩토리 생성자 ---
  factory InterpretationOption.fromJson(Map<String, dynamic> json) {
    String rawText = json['title'] ?? '제목 없음';
    String finalTitle = '제목 없음';
    String finalContent = '내용 없음';

    // // 콜론 ':'을 기준으로 문자열을 분리합니다.
    // int colonIndex = rawText.indexOf(':');
    // if (colonIndex != -1) {
    //   // 콜론 앞부분을 title로 사용합니다.
    //   finalTitle = rawText.substring(0, colonIndex).trim();
    //   // 콜론 뒷부분을 content로 사용합니다.
    //   if (rawText.length > colonIndex + 1) {
    //     finalContent = rawText.substring(colonIndex + 1).trim();
    //   }
    // } else {
    //   // 콜론이 없으면 전체 문자열을 title로 사용합니다.
    //   finalTitle = rawText;
    // }

    return InterpretationOption(
      optionIndex: json['optionIndex'],
      title: finalTitle, // 분리된 제목
      content: finalContent, // 분리된 내용
      tarotCardId: json['tarotCardId'],
      tarotCardName: json['tarotCardName'],
      // ImageUrlBuilder를 사용하여 전체 URL 생성
      tarotCardImageUrl: ImageUrlBuilder.build(json['tarotCardImageUrl']),
    );
  }
}
