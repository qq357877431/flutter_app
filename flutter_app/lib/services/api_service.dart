import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String? _token;
  static GlobalKey<NavigatorState>? navigatorKey;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://120.27.115.89:8080/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await clearToken();
          _navigateToLogin();
        }
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  bool get hasToken => _token != null;
  String? get token => _token;

  void _navigateToLogin() {
    if (navigatorKey?.currentState != null) {
      navigatorKey!.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Auth
  Future<Response> register(String username, String phoneNumber, String password) async {
    return _dio.post('/auth/register', data: {
      'username': username,
      'phone_number': phoneNumber,
      'password': password,
    });
  }

  Future<Response> login(String account, String password) async {
    return _dio.post('/auth/login', data: {
      'account': account,  // 用户名或手机号
      'password': password,
    });
  }

  // 验证token是否有效
  Future<bool> verifyToken() async {
    if (_token == null) return false;
    try {
      await _dio.get('/auth/verify');
      return true;
    } catch (e) {
      await clearToken();
      return false;
    }
  }

  // 获取用户信息
  Future<Response> getProfile() async {
    return _dio.get('/user/profile');
  }

  // 更新用户信息
  Future<Response> updateProfile({String? nickname, String? avatar}) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatar != null) data['avatar'] = avatar;
    return _dio.put('/user/profile', data: data);
  }

  // 修改密码
  Future<Response> changePassword(String oldPassword, String newPassword) async {
    return _dio.put('/user/password', data: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  // Plans
  Future<Response> getPlans({String? date}) async {
    return _dio.get('/plans', queryParameters: date != null ? {'date': date} : null);
  }

  Future<Response> createPlan(String content, String executionDate) async {
    return _dio.post('/plans', data: {
      'content': content,
      'execution_date': executionDate,
    });
  }

  Future<Response> updatePlan(int id, {String? content, String? status}) async {
    final data = <String, dynamic>{};
    if (content != null) data['content'] = content;
    if (status != null) data['status'] = status;
    return _dio.put('/plans/$id', data: data);
  }

  Future<Response> deletePlan(int id) async {
    return _dio.delete('/plans/$id');
  }

  // Expenses
  Future<Response> getExpenses() async {
    return _dio.get('/expenses');
  }

  Future<Response> createExpense(double amount, String category, String? note) async {
    return _dio.post('/expenses', data: {
      'amount': amount,
      'category': category,
      'note': note ?? '',
    });
  }

  Future<Response> updateExpense(int id, {double? amount, String? category, String? note}) async {
    final data = <String, dynamic>{};
    if (amount != null) data['amount'] = amount;
    if (category != null) data['category'] = category;
    if (note != null) data['note'] = note;
    return _dio.put('/expenses/$id', data: data);
  }

  Future<Response> deleteExpense(int id) async {
    return _dio.delete('/expenses/$id');
  }

  // Reminders
  Future<Response> getReminders() async {
    return _dio.get('/reminders');
  }

  Future<Response> createReminder(String type, String scheduledTime, String? content) async {
    return _dio.post('/reminders', data: {
      'reminder_type': type,
      'scheduled_time': scheduledTime,
      'content': content ?? '',
    });
  }

  Future<Response> updateReminder(int id, {String? scheduledTime, String? content, bool? isEnabled}) async {
    final data = <String, dynamic>{};
    if (scheduledTime != null) data['scheduled_time'] = scheduledTime;
    if (content != null) data['content'] = content;
    if (isEnabled != null) data['is_enabled'] = isEnabled;
    return _dio.put('/reminders/$id', data: data);
  }

  Future<Response> deleteReminder(int id) async {
    return _dio.delete('/reminders/$id');
  }
}
