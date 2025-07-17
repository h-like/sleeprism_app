// lib/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _authStatus = AuthStatus.uninitialized;
  User? _user;
  String? _token;

  AuthStatus get authStatus => _authStatus;
  User? get user => _user;
  String? get token => _token;

  AuthProvider() {
    _initAuth();
  }

  // 앱 시작 시 호출되어 로그인 상태를 확인
  Future<void> _initAuth() async {
    _token = await _authService.getToken();
    if (_token != null) {
      try {
        // 토큰이 있으면 프로필 정보를 가져와서 로그인 상태로 만듦
        _user = await _authService.fetchUserProfile();
        _authStatus = AuthStatus.authenticated;
      } catch (e) {
        // 토큰이 유효하지 않으면 로그아웃 상태로 만듦
        _authStatus = AuthStatus.unauthenticated;
      }
    } else {
      _authStatus = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _authStatus = AuthStatus.authenticating;
    notifyListeners();

    try {
      final authResponse = await _authService.signIn(email, password);
      _user = authResponse.user;
      _token = authResponse.accessToken;
      _authStatus = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.deleteToken();
    _user = null;
    _token = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
