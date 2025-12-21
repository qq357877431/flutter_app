import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final bool isNewUser; // 新注册用户标记

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.isNewUser = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    bool? isNewUser,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> checkAuth() async {
    await _apiService.loadToken();
    if (_apiService.hasToken) {
      final isValid = await _apiService.verifyToken();
      if (isValid) {
        // 获取用户信息
        try {
          final response = await _apiService.getProfile();
          final user = User.fromJson(response.data);
          state = state.copyWith(user: user, isLoggedIn: true);
        } catch (e) {
          state = state.copyWith(isLoggedIn: true);
        }
      } else {
        await _apiService.clearToken();
        state = state.copyWith(isLoggedIn: false);
      }
    }
  }

  Future<bool> register(String username, String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.register(username, phoneNumber, password);
      final token = response.data['token'] as String;
      final user = User.fromJson(response.data['user'], token: token);
      await _apiService.setToken(token);
      state = state.copyWith(user: user, isLoading: false, isLoggedIn: true, isNewUser: true);
      return true;
    } catch (e) {
      String errorMsg = '注册失败，请重试';
      if (e.toString().contains('username already exists')) {
        errorMsg = '用户名已存在';
      } else if (e.toString().contains('phone number already registered')) {
        errorMsg = '手机号已注册';
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
      return false;
    }
  }

  Future<bool> login(String account, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(account, password);
      final token = response.data['token'] as String;
      final user = User.fromJson(response.data['user'], token: token);
      await _apiService.setToken(token);
      state = state.copyWith(user: user, isLoading: false, isLoggedIn: true, isNewUser: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '登录失败，请检查账号和密码');
      return false;
    }
  }

  Future<bool> updateProfile({String? nickname, String? avatar}) async {
    try {
      final response = await _apiService.updateProfile(nickname: nickname, avatar: avatar);
      final user = User.fromJson(response.data);
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearNewUserFlag() {
    state = state.copyWith(isNewUser: false);
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});
