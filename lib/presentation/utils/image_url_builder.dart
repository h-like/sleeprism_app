// lib/presentation/utils/image_url_builder.dart

class ImageUrlBuilder {
  // 안드로이드 에뮬레이터에서 로컬 PC 서버에 접근하기 위한 주소
  static const String _baseUrl = "http://10.0.2.2:8080";

  /// 다양한 형태의 이미지 경로를 완전한 URL로 변환합니다.
  static String? build(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    // Case 1: 이미 완전한 URL인 경우 (예: 소셜 로그인 프로필 이미지)
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Case 2: '/files/'로 시작하는 경로 (예: 직접 업로드한 프로필 이미지)
    if (path.startsWith('/files/')) {
      return _baseUrl + path;
    }

    // --- [추가된 로직] ---
    // Case 3: 'comment/'로 시작하는 경로 (예: 댓글 첨부 파일)
    // 백엔드의 FileController 경로에 맞춰 다운로드 URL 생성
    if (path.startsWith('comment/')) {
      return '$_baseUrl/api/comments/files/$path';
    }

    // 예외적인 경우에 대한 처리 (필요시 규칙 추가)
    return _baseUrl + (path.startsWith('/') ? path : '/$path');
  }
}
