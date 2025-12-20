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
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _phoneError = _phoneController.text.isEmpty ? '请输入手机号' : (_phoneController.text.length != 11 ? '请输入有效的手机号' : null);
      _passwordError = _passwordController.text.isEmpty ? '请输入密码' : (_passwordController.text.length < 6 ? '密码至少6位' : null);
    });
    return _phoneError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    final authNotifier = ref.read(authProvider.notifier);
    final success = _isLogin
        ? await authNotifier.login(_phoneController.text, _passwordController.text)
        : await authNotifier.register(_phoneController.text, _passwordController.text);
    if (success && mounted) Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F4FF), Color(0xFFE8F0FE), Color(0xFFF5E6FF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 高级 Logo 设计
                  _buildLogo(),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]).createShader(b),
                    child: const Text('每日计划', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
                  ),
                  const SizedBox(height: 8),
                  Text('规划生活，记录点滴', style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  const SizedBox(height: 48),
                  // 手机号
                  _buildInputField(
                    controller: _phoneController,
                    placeholder: '手机号',
                    icon: CupertinoIcons.phone_fill,
                    keyboardType: TextInputType.phone,
                    error: _phoneError,
                    maxLength: 11,
                  ),
                  const SizedBox(height: 16),
                  // 密码
                  _buildInputField(
                    controller: _passwordController,
                    placeholder: '密码',
                    icon: CupertinoIcons.lock_fill,
                    obscureText: _obscurePassword,
                    error: _passwordError,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(_obscurePassword ? CupertinoIcons.eye : CupertinoIcons.eye_slash, color: Colors.grey[500], size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 错误提示
                  if (authState.error != null)
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [const Color(0xFFFF6B6B).withOpacity(0.1), const Color(0xFFFF8E8E).withOpacity(0.1)]),
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
                  // 登录按钮
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: authState.isLoading ? null : _submit,
                      child: authState.isLoading
                          ? const CupertinoActivityIndicator(color: Colors.white)
                          : Text(_isLogin ? '登录' : '注册', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 切换登录/注册
                  CupertinoButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                        children: [
                          TextSpan(text: _isLogin ? '没有账号？' : '已有账号？'),
                          TextSpan(text: _isLogin ? '立即注册' : '立即登录', style: const TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.w600)),
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

  // 高级 Logo 组件
  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 外层光晕
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
        // 主体容器
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
              BoxShadow(color: const Color(0xFF764BA2).withOpacity(0.3), blurRadius: 20, offset: const Offset(-5, -5)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 装饰圆环
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                ),
              ),
              // 装饰线条
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 主图标
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.checkmark_seal_fill, size: 36, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PLAN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 装饰小点
        Positioned(
          top: 10,
          right: 20,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.5), blurRadius: 6)],
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          left: 15,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFA709A), Color(0xFFFEE140)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFFA709A).withOpacity(0.5), blurRadius: 6)],
            ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
            border: error != null ? Border.all(color: const Color(0xFFFF6B6B), width: 1.5) : null,
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
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
            style: const TextStyle(fontSize: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
