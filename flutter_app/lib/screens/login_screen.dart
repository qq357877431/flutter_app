import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _accountController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _accountError;
  String? _usernameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _accountController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      if (_isLogin) {
        _accountError = _accountController.text.isEmpty ? '请输入用户名或手机号' : null;
        _passwordError = _passwordController.text.isEmpty ? '请输入密码' : null;
      } else {
        _usernameError = _usernameController.text.isEmpty 
            ? '请输入用户名' 
            : (_usernameController.text.length < 3 ? '用户名至少3位' : null);
        _phoneError = _phoneController.text.isEmpty 
            ? '请输入手机号' 
            : (_phoneController.text.length != 11 ? '请输入有效的手机号' : null);
        _passwordError = _passwordController.text.isEmpty 
            ? '请输入密码' 
            : (_passwordController.text.length < 6 ? '密码至少6位' : null);
        _confirmPasswordError = _confirmPasswordController.text.isEmpty 
            ? '请确认密码' 
            : (_confirmPasswordController.text != _passwordController.text ? '两次密码不一致' : null);
      }
    });
    
    if (_isLogin) {
      return _accountError == null && _passwordError == null;
    } else {
      return _usernameError == null && _phoneError == null && 
             _passwordError == null && _confirmPasswordError == null;
    }
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    
    final authNotifier = ref.read(authProvider.notifier);
    bool success;
    
    if (_isLogin) {
      success = await authNotifier.login(_accountController.text, _passwordController.text);
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      success = await authNotifier.register(
        _usernameController.text,
        _phoneController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/profile-setup');
      }
    }
  }

  void _switchMode() {
    setState(() {
      _isLogin = !_isLogin;
      _accountError = null;
      _usernameError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    return CupertinoPageScaffold(
      child: Container(
        color: colors.scaffoldBg,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 90,
                    height: 90,
                    decoration: colors.buttonDecoration(radius: 24),
                    child: const Center(
                      child: Icon(CupertinoIcons.checkmark_seal_fill, size: 45, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Plan Manager',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '规划生活，记录点滴',
                    style: TextStyle(color: colors.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  
                  // 表单卡片
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: colors.cardDecoration(radius: 16),
                    child: Column(
                      children: [
                        if (_isLogin) ...[
                          _buildInputField(
                            controller: _accountController,
                            placeholder: '用户名 / 手机号',
                            icon: CupertinoIcons.person,
                            error: _accountError,
                            colors: colors,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _passwordController,
                            placeholder: '密码',
                            icon: CupertinoIcons.lock,
                            obscureText: _obscurePassword,
                            error: _passwordError,
                            colors: colors,
                            suffix: _buildEyeButton(_obscurePassword, () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            }, colors),
                          ),
                        ] else ...[
                          _buildInputField(
                            controller: _usernameController,
                            placeholder: '用户名（登录用）',
                            icon: CupertinoIcons.person,
                            error: _usernameError,
                            colors: colors,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _phoneController,
                            placeholder: '手机号',
                            icon: CupertinoIcons.phone,
                            keyboardType: TextInputType.phone,
                            error: _phoneError,
                            maxLength: 11,
                            colors: colors,
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _passwordController,
                            placeholder: '密码（至少6位）',
                            icon: CupertinoIcons.lock,
                            obscureText: _obscurePassword,
                            error: _passwordError,
                            colors: colors,
                            suffix: _buildEyeButton(_obscurePassword, () {
                              setState(() => _obscurePassword = !_obscurePassword);
                            }, colors),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            placeholder: '确认密码',
                            icon: CupertinoIcons.lock,
                            obscureText: _obscureConfirmPassword,
                            error: _confirmPasswordError,
                            colors: colors,
                            suffix: _buildEyeButton(_obscureConfirmPassword, () {
                              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                            }, colors),
                          ),
                        ],
                        
                        // 错误提示
                        if (authState.error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.exclamationmark_circle, color: colors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: TextStyle(color: colors.error, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // 提交按钮
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: colors.buttonDecoration(radius: 12),
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              onPressed: authState.isLoading ? null : _submit,
                              child: authState.isLoading
                                  ? const CupertinoActivityIndicator(color: Colors.white)
                                  : Text(
                                      _isLogin ? '登录' : '注册',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 切换登录/注册
                  CupertinoButton(
                    onPressed: _switchMode,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: colors.textSecondary, fontSize: 15),
                        children: [
                          TextSpan(text: _isLogin ? '没有账号？' : '已有账号？'),
                          TextSpan(
                            text: _isLogin ? '立即注册' : '立即登录',
                            style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEyeButton(bool obscure, VoidCallback onTap, AppColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: colors.textTertiary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    required AppColors colors,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? error,
    Widget? suffix,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.cardBgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: error != null ? Border.all(color: colors.error, width: 1) : null,
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: TextStyle(color: colors.textTertiary),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Icon(icon, color: colors.textSecondary, size: 20),
            ),
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            style: TextStyle(fontSize: 16, color: colors.textPrimary),
            decoration: BoxDecoration(
              color: colors.cardBgSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(error, style: TextStyle(color: colors.error, fontSize: 12)),
          ),
      ],
    );
  }
}
