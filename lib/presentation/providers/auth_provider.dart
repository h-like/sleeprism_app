// lib/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_result.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/data/models/user_model.dart';

enum AuthStatus {
  uninitialized,
  authenticating,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final _secureStorage = const FlutterSecureStorage();

  AuthProvider(this._apiService) {
    // tryAutoLogin(); // AuthProvider 생성 시 자동 로그인 시도
  }

  AuthStatus _authStatus = AuthStatus.uninitialized;
  String? _token;
  User? _user;

  AuthStatus get authStatus => _authStatus;

  String? get token => _token;

  User? get user => _user;

  Future<void> _fetchUser() async {
    debugPrint(
      "[AuthProvider] _fetchUser: Attempting to fetch user details...",
    );
    try {
      _user = await _apiService.getMe();
      debugPrint(
        "[AuthProvider] _fetchUser: User details fetched successfully. User: ${_user?.nickname}",
      );
      notifyListeners();
    } catch (e) {
      debugPrint(
        "[AuthProvider] _fetchUser: Failed to fetch user details. Error: $e",
      );
      await logout();
    }
  }

  Future<bool> login(String email, String password) async {
    debugPrint("[AuthProvider] login: Login process started for $email.");
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final receivedToken = await _apiService.login(email, password);

      if (receivedToken != null) {
        debugPrint("[AuthProvider] login: Token received successfully.");
        _token = receivedToken;
        await _secureStorage.write(key: 'jwt_token', value: _token);
        debugPrint("[AuthProvider] login: Token stored securely.");

        await _fetchUser();

        if (_user != null) {
          debugPrint(
            "[AuthProvider] login: User fetch successful. Setting status to authenticated.",
          );
          _authStatus = AuthStatus.authenticated;
          notifyListeners();
          return true;
        } else {
          // _fetchUser 내부에서 에러가 발생하여 _user가 null이 된 경우
          debugPrint(
            "[AuthProvider] login: User is null after fetch. Setting status to unauthenticated.",
          );
          _authStatus = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      }
      // 토큰을 받지 못한 경우
      debugPrint(
        "[AuthProvider] login: Token was not received. Setting status to unauthenticated.",
      );
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint(
        "[AuthProvider] login: An exception occurred during login. Error: $e",
      );
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // 백엔드로부터 JWT 토큰을 받아와 저장하고 유저 정보를 가져옵니다.
  Future<bool> _processSocialLogin(Future<String?> Function() apiCall) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final receivedToken = await apiCall();

      if (receivedToken != null) {
        debugPrint("[AuthProvider] Social Login: Token received successfully.");
        _token = receivedToken;
        await _secureStorage.write(key: 'jwt_token', value: _token);
        debugPrint("[AuthProvider] Social Login: Token stored securely.");

        await _fetchUser();

        if (_user != null) {
          debugPrint(
            "[AuthProvider] Social Login: User fetch successful. Setting status to authenticated.",
          );
          _authStatus = AuthStatus.authenticated;
          notifyListeners();
          return true;
        }
      }

      // 토큰을 못 받았거나, 유저 정보 패치 실패 시
      debugPrint(
        "[AuthProvider] Social Login: Failed to get token or fetch user.",
      );
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint(
        "[AuthProvider] Social Login: An exception occurred. Error: $e",
      );
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }


  // 구글 로그인
  Future<bool> signInWithGoogle() async {
    try {
      // 별칭을 쓴 타입으로 명확히 지정 (이름 충돌 방지)
      final gsign.GoogleSignIn googleSignIn = gsign.GoogleSignIn(
        scopes: const [
          'email',
          'openid',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
        // 필요 시 웹에서는 clientId 지정
        // clientId: kIsWeb ? 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com' : null,
      );

      final gsign.GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return false; // 사용자가 취소

      final gsign.GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 최신 플러그인은 accessToken 대신 idToken 사용 권장
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        debugPrint("[AuthProvider] Google Login: Failed to get ID token.");
        return false;
      }

      debugPrint("[AuthProvider] Google ID Token: $idToken");
      return _processSocialLogin(() => _apiService.socialLogin('google', idToken));
    } catch (error) {
      debugPrint('[AuthProvider] Google 로그인 실패: $error');
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }



  // 네이버 로그인
  Future<bool> signInWithNaver() async {
    try {
      final NaverLoginResult result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final String accessToken = result.accessToken!.accessToken;

        debugPrint("[AuthProvider] Naver Access Token: $accessToken");
        // 공통 로직 호출
        return _processSocialLogin(
          () => _apiService.socialLogin('naver', accessToken),
        );
      } else {
        // 로그인 취소 또는 실패
        debugPrint("[AuthProvider] Naver Login: Login canceled or failed.");
        return false;
      }
    } catch (error) {
      debugPrint('[AuthProvider] 네이버 로그인 실패: $error');
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    debugPrint("[AuthProvider] tryAutoLogin: Checking for stored token.");
    final storedToken = await _secureStorage.read(key: 'jwt_token');
    if (storedToken != null) {
      debugPrint(
        "[AuthProvider] tryAutoLogin: Token found. Proceeding to fetch user.",
      );
      _token = storedToken;
      await _fetchUser();
      if (_user != null) {
        _authStatus = AuthStatus.authenticated;
      } else {
        _authStatus = AuthStatus.unauthenticated;
      }
    } else {
      debugPrint("[AuthProvider] tryAutoLogin: No token found.");
      _authStatus = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint("[AuthProvider] logout: Logging out.");
    _token = null;
    _user = null;
    await _secureStorage.delete(key: 'jwt_token');
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // 카카오 로그인
  Future<bool> signInWithKakao() async {
    try {
      final bool isKakaoAvailable = await kakao.isKakaoTalkInstalled(); // 수정 코드

      kakao.OAuthToken token = isKakaoAvailable // 변수 이름 변경
          ? await kakao.UserApi.instance.loginWithKakaoTalk()
          : await kakao.UserApi.instance.loginWithKakaoAccount();

      final String accessToken = token.accessToken;

      debugPrint("[AuthProvider] Kakao Access Token: $accessToken");
      // 공통 로직 호출
      return _processSocialLogin(
        () => _apiService.socialLogin('kakao', accessToken),
      );
    } catch (error) {
      debugPrint('[AuthProvider] 카카오 로그인 실패: $error');
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }
}
