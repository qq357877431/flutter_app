import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> checkAuth() async {
    await _apiService.loadToken();
    if (_apiService.hasToken) {
      // 验证 token 是否有效
      final isValid = await _apiService.verifyToken();
      if (isValid) {
        state = state.copyWith(isLoggedIn: true);
      } else {
        // token 无效，清除并跳转登录
        await _apiService.clearToken();
        state = state.copyWith(isLoggedIn: false);
      }
    }
  }

  Future<bool> register(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.register(phoneNumber, password);
      final token = response.data['token'] as String;
      final user = User.fromJson(response.data['user'], token: token);
      await _apiService.setToken(token);
      state = state.copyWith(user: user, isLoading: false, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '注册失败，请重试');
      return false;
    }
  }

  Future<bool> login(String phoneNumber, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.login(phoneNumber, password);
      final token = response.data['token'] as String;
      final user = User.fromJson(response.data['user'], token: token);
      await _apiService.setToken(token);
      state = state.copyWith(user: user, isLoading: false, isLoggedIn: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '登录失败，请检查手机号和密码');
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.clearToken();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ApiService());
});
