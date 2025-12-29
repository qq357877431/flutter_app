import 'dart:ui';
import 'dart:math' as math;
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

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
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

  late AnimationController _backgroundController;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Background animation
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Entry animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _backgroundController.dispose();
    _entryController.dispose();
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

    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Mesh Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MeshGradientPainter(
                    animationValue: _backgroundController.value,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),

          // 2. Glassmorphism Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: colors.primaryGradient,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(CupertinoIcons.checkmark_seal_fill, size: 50, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Title
                        Text(
                          'Plan Manager',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '规划生活，记录点滴',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Glass Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.black.withOpacity(0.4) 
                                    : Colors.white.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark 
                                      ? Colors.white.withOpacity(0.1) 
                                      : Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  if (_isLogin) ...[
                                    _buildInputField(
                                      controller: _accountController,
                                      placeholder: '用户名 / 手机号',
                                      icon: CupertinoIcons.person,
                                      error: _accountError,
                                      colors: colors,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _passwordController,
                                      placeholder: '密码',
                                      icon: CupertinoIcons.lock,
                                      obscureText: _obscurePassword,
                                      error: _passwordError,
                                      colors: colors,
                                      isDark: isDark,
                                      suffix: _buildEyeButton(_obscurePassword, () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      }, colors, isDark),
                                    ),
                                  ] else ...[
                                    _buildInputField(
                                      controller: _usernameController,
                                      placeholder: '用户名（登录用）',
                                      icon: CupertinoIcons.person,
                                      error: _usernameError,
                                      colors: colors,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _phoneController,
                                      placeholder: '手机号',
                                      icon: CupertinoIcons.phone,
                                      keyboardType: TextInputType.phone,
                                      error: _phoneError,
                                      maxLength: 11,
                                      colors: colors,
                                      isDark: isDark,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _passwordController,
                                      placeholder: '密码（至少6位）',
                                      icon: CupertinoIcons.lock,
                                      obscureText: _obscurePassword,
                                      error: _passwordError,
                                      colors: colors,
                                      isDark: isDark,
                                      suffix: _buildEyeButton(_obscurePassword, () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      }, colors, isDark),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildInputField(
                                      controller: _confirmPasswordController,
                                      placeholder: '确认密码',
                                      icon: CupertinoIcons.lock,
                                      obscureText: _obscureConfirmPassword,
                                      error: _confirmPasswordError,
                                      colors: colors,
                                      isDark: isDark,
                                      suffix: _buildEyeButton(_obscureConfirmPassword, () {
                                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                      }, colors, isDark),
                                    ),
                                  ],

                                  if (authState.error != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: colors.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: colors.error.withOpacity(0.2)),
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

                                  const SizedBox(height: 32),

                                  // Submit Button
                                  Container(
                                    width: double.infinity,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: colors.primaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.primary.withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: authState.isLoading ? null : _submit,
                                      child: authState.isLoading
                                          ? const CupertinoActivityIndicator(color: Colors.white)
                                          : Text(
                                              _isLogin ? '登录' : '注册',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Switch Mode
                        CupertinoButton(
                          onPressed: _switchMode,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(text: _isLogin ? '没有账号？' : '已有账号？'),
                                TextSpan(
                                  text: _isLogin ? ' 立即注册' : ' 立即登录',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildEyeButton(bool obscure, VoidCallback onTap, AppColors colors, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Icon(
          obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
          color: isDark ? Colors.white54 : Colors.black45,
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
    required bool isDark,
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
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null 
                  ? colors.error 
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
              width: 1,
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            placeholderStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Icon(
                icon, 
                color: isDark ? Colors.white54 : Colors.black54, 
                size: 20
              ),
            ),
            suffix: suffix,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            style: TextStyle(
              fontSize: 16, 
              color: isDark ? Colors.white : Colors.black87
            ),
            decoration: null, // Remove default decoration
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

class _MeshGradientPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;

  _MeshGradientPainter({required this.animationValue, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Base background
    paint.color = isDark ? const Color(0xFF0F1115) : const Color(0xFFF5F7FA);
    canvas.drawRect(rect, paint);

    // Dynamic orbs
    final t = animationValue * 2 * math.pi;
    
    // Orb 1: Primary Color
    _drawOrb(
      canvas, 
      size, 
      Offset(
        size.width * 0.2 + math.cos(t) * 30,
        size.height * 0.2 + math.sin(t) * 30,
      ),
      isDark ? const Color(0xFF4A5A9E) : const Color(0xFF6B7FE6),
      size.width * 0.6,
    );

    // Orb 2: Secondary/Accent Color
    _drawOrb(
      canvas, 
      size, 
      Offset(
        size.width * 0.8 - math.sin(t) * 30,
        size.height * 0.8 - math.cos(t) * 30,
      ),
      isDark ? const Color(0xFF5A7AB8) : const Color(0xFF8BB8F8),
      size.width * 0.5,
    );

    // Orb 3: Subtle fill
    _drawOrb(
      canvas, 
      size, 
      Offset(
        size.width * 0.5 + math.sin(t * 0.5) * 50,
        size.height * 0.5 + math.cos(t * 0.5) * 50,
      ),
      isDark ? const Color(0xFF2A2D35) : const Color(0xFFE0E5EC),
      size.width * 0.8,
    );
  }

  void _drawOrb(Canvas canvas, Size size, Offset center, Color color, double radius) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.4),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..blendMode = BlendMode.srcOver;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshGradientPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.isDark != isDark;
  }
}
