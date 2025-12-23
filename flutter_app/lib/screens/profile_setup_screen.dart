import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nicknameController = TextEditingController();
  String _selectedAvatar = '';
  bool _isLoading = false;

  final List<String> _avatarOptions = [
    '😀', '😎', '🤖', '👨‍💻', '👩‍💻', '🦊', '🐱', '🐶',
    '🌟', '🚀', '💎', '🎯', '🎨', '🎵', '📚', '💡',
  ];

  Future<void> _saveProfile() async {
    if (_nicknameController.text.isEmpty && _selectedAvatar.isEmpty) {
      _skip();
      return;
    }

    setState(() => _isLoading = true);
    
    final success = await ref.read(authProvider.notifier).updateProfile(
      nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
      avatar: _selectedAvatar.isNotEmpty ? _selectedAvatar : null,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      ref.read(authProvider.notifier).clearNewUserFlag();
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _skip() {
    ref.read(authProvider.notifier).clearNewUserFlag();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text('跳过', style: TextStyle(color: colors.textSecondary, fontSize: 16)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                '完善个人信息',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '设置你的昵称和头像，让大家认识你',
                style: TextStyle(fontSize: 15, color: colors.textSecondary),
              ),
              const SizedBox(height: 40),
              
              // 头像选择
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: colors.buttonDecoration(radius: 50),
                      child: Center(
                        child: Text(
                          _selectedAvatar.isEmpty ? '👤' : _selectedAvatar,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('选择头像', style: TextStyle(color: colors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // 头像选项
              Container(
                padding: const EdgeInsets.all(20),
                decoration: colors.cardDecoration(radius: 16),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _avatarOptions.map((emoji) {
                    final isSelected = _selectedAvatar == emoji;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = emoji),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected ? colors.primary.withOpacity(0.1) : colors.cardBgSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              
              // 昵称输入
              Text(
                '昵称',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: colors.cardDecoration(radius: 12),
                child: CupertinoTextField(
                  controller: _nicknameController,
                  placeholder: '给自己取个名字吧',
                  padding: const EdgeInsets.all(16),
                  style: TextStyle(color: colors.textPrimary, fontSize: 16),
                  placeholderStyle: TextStyle(color: colors.textTertiary),
                  decoration: BoxDecoration(
                    color: colors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  maxLength: 20,
                ),
              ),
              const SizedBox(height: 40),
              
              // 保存按钮
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: colors.buttonDecoration(radius: 12),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                            '完成设置',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
