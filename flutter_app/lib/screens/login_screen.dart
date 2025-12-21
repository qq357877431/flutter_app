import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // 新用户跳转到设置个人信息页面
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
    final bgColors = isDark 
        ? [const Color(0xFF1C1C1E), const Color(0xFF1C1C1E), const Color(0xFF1C1C1E)]
        : [const Color(0xFFF0F4FF), const Color(0xFFE8F0FE), const Color(0xFFF5E6FF)];
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryTextColor = isDark ? const Color(0xFF8E8E93) : Colors.grey[600];

    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ).createShader(b),
                    child: const Text(
                      'Plan Manager',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '规划生活，记录点滴',
                    style: TextStyle(color: secondaryTextColor, fontSize: 15),
                  ),
                  const SizedBox(height: 40),
                  
                  if (_isLogin) ...[
                    // 登录表单
                    _buildInputField(
                      controller: _accountController,
                      placeholder: '用户名 / 手机号',
                      icon: CupertinoIcons.person_fill,
                      error: _accountError,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: '密码',
                      icon: CupertinoIcons.lock_fill,
                      obscureText: _obscurePassword,
                      error: _passwordError,
                      isDark: isDark,
                      cardColor: cardColor,
                      suffix: _buildEyeButton(_obscurePassword, () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }, isDark),
                    ),
                  ] else ...[
                    // 注册表单
                    _buildInputField(
                      controller: _usernameController,
                      placeholder: '用户名（登录用）',
                      icon: CupertinoIcons.person_fill,
                      error: _usernameError,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _phoneController,
                      placeholder: '手机号',
                      icon: CupertinoIcons.phone_fill,
                      keyboardType: TextInputType.phone,
                      error: _phoneError,
                      maxLength: 11,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _passwordController,
                      placeholder: '密码（至少6位）',
                      icon: CupertinoIcons.lock_fill,
                      obscureText: _obscurePassword,
                      error: _passwordError,
                      isDark: isDark,
                      cardColor: cardColor,
                      suffix: _buildEyeButton(_obscurePassword, () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      }, isDark),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      controller: _confirmPasswordController,
                      placeholder: '确认密码',
                      icon: CupertinoIcons.lock_fill,
                      obscureText: _obscureConfirmPassword,
                      error: _confirmPasswordError,
                      isDark: isDark,
                      cardColor: cardColor,
                      suffix: _buildEyeButton(_obscureConfirmPassword, () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      }, isDark),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // 错误提示
                  if (authState.error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFFF6B6B).withOpacity(0.1), const Color(0xFFFF8E8E).withOpacity(0.1)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.exclamationmark_circle_fill, color: Color(0xFFFF6B6B), size: 20),
                          const SizedBox(width: 10),
                          Expanded(child: Text(authState.error!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 14))),
                        ],
                      ),
                    ),
                  
                  // 提交按钮
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(
                              _isLogin ? '登录' : '注册',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 切换登录/注册
                  CupertinoButton(
                    onPressed: _switchMode,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: secondaryTextColor, fontSize: 15),
                        children: [
                          TextSpan(text: _isLogin ? '没有账号？' : '已有账号？'),
                          const TextSpan(
                            text: '',
                          ),
                          TextSpan(
                            text: _isLogin ? '立即注册' : '立即登录',
                            style: const TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.w600),
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

  Widget _buildEyeButton(bool obscure, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: isDark ? const Color(0xFF8E8E93) : Colors.grey[500],
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFF667EEA).withOpacity(0.2), Colors.transparent],
            ),
          ),
        ),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFE040FB)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 15)),
            ],
          ),
          child: const Center(
            child: Icon(CupertinoIcons.checkmark_seal_fill, size: 50, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? error,
    Widget? suffix,
    int? maxLength,
    required bool isDark,
    required Color cardColor,
  }) {
    final textColor = isDark ? Colors.white : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: const Color(0xFF667EEA).withOpacity(isDark ? 0.05 : 0.08), blurRadius: 15, offset: const Offset(0, 5)),
            ],
            border: error != null ? Border.all(color: const Color(0xFFFF6B6B), width: 1.5) : null,
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: TextStyle(color: isDark ? const Color(0xFF8E8E93) : Colors.grey[400]),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]).createShader(b),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            style: TextStyle(fontSize: 16, color: textColor),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(error, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
          ),
      ],
    );
  }
}
