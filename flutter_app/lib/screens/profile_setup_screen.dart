import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // 预设头像列表
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
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textSecondary = isDark ? const Color(0xFF8E8E93) : Colors.grey[600];
    final itemBgColor = isDark ? const Color(0xFF3A3A3C) : Colors.grey[100];
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _skip,
            child: Text('跳过', style: TextStyle(color: textSecondary, fontSize: 16)),
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
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ).createShader(b),
                child: const Text(
                  '完善个人信息',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '设置你的昵称和头像，让大家认识你',
                style: TextStyle(fontSize: 15, color: textSecondary),
              ),
              const SizedBox(height: 40),
              
              // 头像选择
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667EEA).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _selectedAvatar.isEmpty ? '👤' : _selectedAvatar,
                          style: const TextStyle(fontSize: 50),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('选择头像', style: TextStyle(color: textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // 头像选项
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
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
                          color: isSelected ? const Color(0xFF667EEA).withOpacity(0.1) : itemBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: const Color(0xFF667EEA), width: 2) : null,
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
              Text('昵称', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textSecondary)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoTextField(
                  controller: _nicknameController,
                  placeholder: '给自己取个名字吧',
                  padding: const EdgeInsets.all(16),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  placeholderStyle: TextStyle(color: textSecondary),
                  decoration: BoxDecoration(
                    color: cardColor,
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
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text(
                            '完成设置',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
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
