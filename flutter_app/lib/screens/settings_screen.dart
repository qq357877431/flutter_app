import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _notificationService = NotificationService();
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  bool _bedtimeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBedtimeSettings();
  }

  // 加载早睡提醒设置
  Future<void> _loadBedtimeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bedtimeEnabled = prefs.getBool('bedtime_enabled') ?? false;
      final hour = prefs.getInt('bedtime_hour') ?? 23;
      final minute = prefs.getInt('bedtime_minute') ?? 0;
      _bedtime = TimeOfDay(hour: hour, minute: minute);
    });
    
    // 如果启用了提醒，重新设置
    if (_bedtimeEnabled) {
      await _notificationService.scheduleBedtimeReminder(hour: _bedtime.hour, minute: _bedtime.minute);
    }
  }

  // 保存早睡提醒设置
  Future<void> _saveBedtimeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bedtime_enabled', _bedtimeEnabled);
    await prefs.setInt('bedtime_hour', _bedtime.hour);
    await prefs.setInt('bedtime_minute', _bedtime.minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showBedtimePicker() {
    int tempH = _bedtime.hour;
    int tempM = _bedtime.minute;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
                CupertinoButton(child: const Text('确定'), onPressed: () async {
                  setState(() => _bedtime = TimeOfDay(hour: tempH, minute: tempM));
                  Navigator.pop(ctx);
                  if (_bedtimeEnabled) {
                    await _notificationService.scheduleBedtimeReminder(hour: tempH, minute: tempM);
                  }
                  await _saveBedtimeSettings();
                }),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2024, 1, 1, _bedtime.hour, _bedtime.minute),
                onDateTimeChanged: (dt) {
                  tempH = dt.hour;
                  tempM = dt.minute;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBedtime(bool v) async {
    setState(() => _bedtimeEnabled = v);
    if (v) {
      await _notificationService.scheduleBedtimeReminder(hour: _bedtime.hour, minute: _bedtime.minute);
    } else {
      await _notificationService.cancelNotification(1000);
    }
    await _saveBedtimeSettings();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
    final textSecondary = isDark ? const Color(0xFF8E8E93) : Colors.grey[600];
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 个人信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // 头像
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      user?.avatar?.isNotEmpty == true ? user!.avatar! : '👤',
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // 用户信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '未设置昵称',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // 编辑按钮
                GestureDetector(
                  onTap: _showEditProfileSheet,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // 外观设置标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('外观', style: TextStyle(fontSize: 13, color: textSecondary)),
          ),
          // 主题设置
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _icon(Icons.palette, const Color(0xFF34C759)),
              title: const Text('主题模式'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getThemeModeText(ref.watch(themeModeProvider)), style: TextStyle(color: textSecondary)),
                  Icon(Icons.chevron_right, color: textSecondary),
                ],
              ),
              onTap: _showThemePicker,
            ),
          ),
          const SizedBox(height: 24),
          
          // 提醒设置标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('提醒设置', style: TextStyle(fontSize: 13, color: textSecondary)),
          ),
          // 早睡提醒
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: _icon(Icons.nightlight_round, const Color(0xFF5856D6)),
                  title: const Text('早睡提醒'),
                  subtitle: Text('每天 ${_formatTime(_bedtime)}'),
                  trailing: Switch.adaptive(value: _bedtimeEnabled, onChanged: _toggleBedtime),
                ),
                if (_bedtimeEnabled) ...[
                  Divider(height: 1, indent: 56, color: isDark ? const Color(0xFF38383A) : null),
                  ListTile(
                    leading: _icon(Icons.access_time, const Color(0xFF007AFF)),
                    title: const Text('提醒时间'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatTime(_bedtime), style: TextStyle(color: textSecondary)),
                        Icon(Icons.chevron_right, color: textSecondary),
                      ],
                    ),
                    onTap: _showBedtimePicker,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 账户标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('账户', style: TextStyle(fontSize: 13, color: textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _icon(Icons.logout, const Color(0xFFFF3B30)),
              title: const Text('退出登录', style: TextStyle(color: Color(0xFFFF3B30))),
              trailing: Icon(Icons.chevron_right, color: textSecondary),
              onTap: _showLogoutDialog,
            ),
          ),
          const SizedBox(height: 24),
          // 关于标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('关于', style: TextStyle(fontSize: 13, color: textSecondary)),
          ),
          Container(
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _icon(Icons.info_outline, const Color(0xFF007AFF)),
              title: const Text('版本'),
              trailing: Text('1.2.0', style: TextStyle(color: textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  // 预设头像列表
  final List<String> _avatarOptions = [
    '😀', '😎', '🤖', '👨‍💻', '👩‍💻', '🦊', '🐱', '🐶',
    '🌟', '🚀', '💎', '🎯', '🎨', '🎵', '📚', '💡',
  ];

  void _showEditProfileSheet() {
    final user = ref.read(authProvider).user;
    final nicknameController = TextEditingController(text: user?.nickname ?? '');
    String selectedAvatar = user?.avatar ?? '';

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '编辑个人信息',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // 头像选择
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      selectedAvatar.isEmpty ? '👤' : selectedAvatar,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // 头像选项
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _avatarOptions.map((emoji) {
                  final isSelected = selectedAvatar == emoji;
                  return GestureDetector(
                    onTap: () => setS(() => selectedAvatar = emoji),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: const Color(0xFF667EEA), width: 2) : null,
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              
              // 昵称输入
              CupertinoTextField(
                controller: nicknameController,
                placeholder: '昵称',
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),
              
              // 保存按钮
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  onPressed: () async {
                    await ref.read(authProvider.notifier).updateProfile(
                      nickname: nicknameController.text.isNotEmpty ? nicknameController.text : null,
                      avatar: selectedAvatar.isNotEmpty ? selectedAvatar : null,
                    );
                    if (mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showThemePicker() {
    final currentMode = ref.read(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('选择主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 20),
            _buildThemeOption(
              ctx,
              icon: Icons.light_mode_rounded,
              title: '浅色模式',
              subtitle: '始终使用浅色主题',
              isSelected: currentMode == ThemeMode.light,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              ctx,
              icon: Icons.dark_mode_rounded,
              title: '深色模式',
              subtitle: '始终使用深色主题',
              isSelected: currentMode == ThemeMode.dark,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildThemeOption(
              ctx,
              icon: Icons.brightness_auto_rounded,
              title: '跟随系统',
              subtitle: '自动适应系统主题设置',
              isSelected: currentMode == ThemeMode.system,
              onTap: () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
              isDark: isDark,
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final selectedColor = const Color(0xFF007AFF);
    final bgColor = isSelected 
        ? selectedColor.withOpacity(0.1)
        : (isDark ? const Color(0xFF3A3A3C) : Colors.grey[100]);
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? const Color(0xFF8E8E93) : Colors.grey[600];
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : (isDark ? const Color(0xFF48484A) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[600]), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: subtitleColor)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: selectedColor, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          CupertinoDialogAction(child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('退出'),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
