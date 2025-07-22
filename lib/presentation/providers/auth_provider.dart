// lib/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/data/models/user_model.dart';


enum AuthStatus { uninitialized, authenticating, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final _secureStorage = const FlutterSecureStorage();

  AuthProvider(this._apiService);

  AuthStatus _authStatus = AuthStatus.uninitialized;
  String? _token;
  User? _user;

  AuthStatus get authStatus => _authStatus;
  String? get token => _token;
  User? get user => _user;

  Future<void> _fetchUser() async {
    debugPrint("[AuthProvider] _fetchUser: Attempting to fetch user details...");
    try {
      _user = await _apiService.getMe();
      debugPrint("[AuthProvider] _fetchUser: User details fetched successfully. User: ${_user?.nickname}");
      notifyListeners();
    } catch (e) {
      debugPrint("[AuthProvider] _fetchUser: Failed to fetch user details. Error: $e");
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
          debugPrint("[AuthProvider] login: User fetch successful. Setting status to authenticated.");
          _authStatus = AuthStatus.authenticated;
          notifyListeners();
          return true;
        } else {
          // _fetchUser 내부에서 에러가 발생하여 _user가 null이 된 경우
          debugPrint("[AuthProvider] login: User is null after fetch. Setting status to unauthenticated.");
          _authStatus = AuthStatus.unauthenticated;
          notifyListeners();
          return false;
        }
      }
      // 토큰을 받지 못한 경우
      debugPrint("[AuthProvider] login: Token was not received. Setting status to unauthenticated.");
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("[AuthProvider] login: An exception occurred during login. Error: $e");
      _authStatus = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    debugPrint("[AuthProvider] tryAutoLogin: Checking for stored token.");
    final storedToken = await _secureStorage.read(key: 'jwt_token');
    if (storedToken != null) {
      debugPrint("[AuthProvider] tryAutoLogin: Token found. Proceeding to fetch user.");
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
}