import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
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

  final List<String> _avatarOptions = [
    '😀', '😎', '🤖', '👨‍💻', '👩‍💻', '🦊', '🐱', '🐶',
    '🌟', '🚀', '💎', '🎯', '🎨', '🎵', '📚', '💡',
  ];

  @override
  void initState() {
    super.initState();
    _loadBedtimeSettings();
  }

  Future<void> _loadBedtimeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bedtimeEnabled = prefs.getBool('bedtime_enabled') ?? false;
      final hour = prefs.getInt('bedtime_hour') ?? 23;
      final minute = prefs.getInt('bedtime_minute') ?? 0;
      _bedtime = TimeOfDay(hour: hour, minute: minute);
    });
    
    if (_bedtimeEnabled) {
      await _notificationService.scheduleBedtimeReminder(hour: _bedtime.hour, minute: _bedtime.minute);
    }
  }

  Future<void> _saveBedtimeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bedtime_enabled', _bedtimeEnabled);
    await prefs.setInt('bedtime_hour', _bedtime.hour);
    await prefs.setInt('bedtime_minute', _bedtime.minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
    final colors = AppColors(isDark);
    
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 个人信息卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: colors.specialCardDecoration(color: colors.cardBg),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Text(
                      user?.avatar?.isNotEmpty == true ? user!.avatar! : '👤',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '未设置昵称',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.phoneNumber ?? '',
                        style: TextStyle(color: colors.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showEditProfileSheet,
                  child: Container(
                    decoration: colors.circleButtonDecoration(shadowColor: colors.primary),
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.edit, color: colors.primary, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          // 外观设置
          _buildSectionTitle('外观', colors),
          Container(
            decoration: colors.cardDecoration(radius: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: _icon(Icons.palette, colors.success),
                title: Text('主题模式', style: TextStyle(color: colors.textPrimary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeModeText(ref.watch(themeModeProvider)),
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    Icon(Icons.chevron_right, color: colors.textTertiary),
                  ],
                ),
                onTap: _showThemePicker,
              ),
            ),
          ),
          const SizedBox(height: 28),
          
          // 提醒设置
          _buildSectionTitle('提醒设置', colors),
          Container(
            decoration: colors.cardDecoration(radius: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _icon(Icons.nightlight_round, const Color(0xFFAF52DE)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('早睡提醒', style: TextStyle(fontSize: 16, color: colors.textPrimary)),
                              const SizedBox(height: 2),
                              Text('每天 ${_formatTime(_bedtime)}', style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                            ],
                          ),
                        ),
                        _buildSwitch(_bedtimeEnabled, (v) => _toggleBedtime(v), colors),
                      ],
                    ),
                  ),
                  if (_bedtimeEnabled) ...[
                    Divider(height: 1, indent: 56, color: colors.divider),
                    ListTile(
                      leading: _icon(Icons.access_time, colors.accent),
                      title: Text('提醒时间', style: TextStyle(color: colors.textPrimary)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_formatTime(_bedtime), style: TextStyle(color: colors.textSecondary)),
                          Icon(Icons.chevron_right, color: colors.textTertiary),
                        ],
                      ),
                      onTap: _showBedtimePicker,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          
          // 账户安全
          _buildSectionTitle('账户安全', colors),
          Container(
            decoration: colors.cardDecoration(radius: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: [
                  ListTile(
                    leading: _icon(Icons.lock_outline, colors.accent),
                    title: Text('修改密码', style: TextStyle(color: colors.textPrimary)),
                    trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                    onTap: _showChangePasswordSheet,
                  ),
                  Divider(height: 1, indent: 56, color: colors.divider),
                  ListTile(
                    leading: _icon(Icons.logout, colors.error),
                    title: Text('退出登录', style: TextStyle(color: colors.error)),
                    trailing: Icon(Icons.chevron_right, color: colors.textTertiary),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          
          // 关于
          _buildSectionTitle('关于', colors),
          Container(
            decoration: colors.cardDecoration(radius: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                leading: _icon(Icons.info_outline, colors.accent),
                title: Text('版本', style: TextStyle(color: colors.textPrimary)),
                trailing: Text('1.5.0', style: TextStyle(color: colors.textSecondary)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged, AppColors colors) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? colors.primary : colors.divider,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value ? Icon(Icons.check, size: 16, color: colors.primary) : null,
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
      case ThemeMode.light: return '浅色';
      case ThemeMode.dark: return '深色';
      case ThemeMode.system: return '跟随系统';
    }
  }

  void _showBedtimePicker() {
    int tempH = _bedtime.hour;
    int tempM = _bedtime.minute;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 340,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('取消', style: TextStyle(color: colors.textSecondary)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                Text('选择时间', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                )),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('确定', style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  )),
                  onPressed: () async {
                    setState(() => _bedtime = TimeOfDay(hour: tempH, minute: tempM));
                    Navigator.pop(ctx);
                    if (_bedtimeEnabled) {
                      await _notificationService.scheduleBedtimeReminder(hour: tempH, minute: tempM);
                    }
                    await _saveBedtimeSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
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

  void _showThemePicker() {
    final currentMode = ref.read(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Text('选择主题', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 20),
            _buildThemeOption(ctx, Icons.light_mode_rounded, '浅色模式', '始终使用浅色主题',
              currentMode == ThemeMode.light, () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              }, colors),
            const SizedBox(height: 12),
            _buildThemeOption(ctx, Icons.dark_mode_rounded, '深色模式', '始终使用深色主题',
              currentMode == ThemeMode.dark, () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              }, colors),
            const SizedBox(height: 12),
            _buildThemeOption(ctx, Icons.brightness_auto_rounded, '跟随系统', '自动适应系统主题设置',
              currentMode == ThemeMode.system, () {
                ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              }, colors),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext ctx, IconData icon, String title, String subtitle,
      bool isSelected, VoidCallback onTap, AppColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : colors.cardBgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.divider,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : colors.textSecondary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: colors.textSecondary)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: colors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  void _showEditProfileSheet() {
    final user = ref.read(authProvider).user;
    final nicknameController = TextEditingController(text: user?.nickname ?? '');
    String selectedAvatar = user?.avatar ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('编辑个人信息', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80, height: 80,
                  child: Center(child: Text(selectedAvatar.isEmpty ? '👤' : selectedAvatar, style: const TextStyle(fontSize: 48))),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10, runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _avatarOptions.map((emoji) {
                  final isSelected = selectedAvatar == emoji;
                  return GestureDetector(
                    onTap: () => setS(() => selectedAvatar = emoji),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary.withOpacity(0.1) : colors.cardBgSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
                      ),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: nicknameController,
                placeholder: '昵称',
                padding: const EdgeInsets.all(14),
                style: TextStyle(color: colors.textPrimary),
                placeholderStyle: TextStyle(color: colors.textTertiary),
                decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: colors.buttonDecoration(radius: 12),
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

  void _showChangePasswordSheet() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Text('修改密码', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
                const SizedBox(height: 20),
                _buildPasswordField(oldPasswordController, '当前密码', colors),
                const SizedBox(height: 12),
                _buildPasswordField(newPasswordController, '新密码（至少6位）', colors),
                const SizedBox(height: 12),
                _buildPasswordField(confirmPasswordController, '确认新密码', colors),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(errorMessage!, style: TextStyle(color: colors.error, fontSize: 14)),
                ],
                const SizedBox(height: 20),
                Container(
                  decoration: colors.buttonDecoration(radius: 12),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: isLoading ? null : () async {
                      if (oldPasswordController.text.isEmpty) { setS(() => errorMessage = '请输入当前密码'); return; }
                      if (newPasswordController.text.length < 6) { setS(() => errorMessage = '新密码至少6位'); return; }
                      if (newPasswordController.text != confirmPasswordController.text) { setS(() => errorMessage = '两次密码不一致'); return; }
                      setS(() { isLoading = true; errorMessage = null; });
                      try {
                        await ApiService().changePassword(oldPasswordController.text, newPasswordController.text);
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('密码修改成功'), backgroundColor: colors.success));
                        }
                      } catch (e) {
                        setS(() { isLoading = false; errorMessage = '当前密码错误'; });
                      }
                    },
                    child: isLoading
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : const Text('确认修改', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String placeholder, AppColors colors) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: true,
      padding: const EdgeInsets.all(14),
      style: TextStyle(color: colors.textPrimary),
      placeholderStyle: TextStyle(color: colors.textTertiary),
      decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.logout_rounded, color: colors.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text('退出登录', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            )),
            const SizedBox(height: 8),
            Text('确定要退出当前账号吗？', style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
            )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.cardBgSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('取消', style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('退出', style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
