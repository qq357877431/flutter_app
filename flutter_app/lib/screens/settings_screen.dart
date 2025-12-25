import 'dart:ui';
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(user, colors, isDark)),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('外观', colors),
                _buildSettingCard(colors, children: [
                  _buildSettingItem(
                    icon: Icons.palette_rounded, iconBg: colors.success,
                    title: '主题模式',
                    value: _getThemeModeText(ref.watch(themeModeProvider)),
                    onTap: _showThemePicker, colors: colors,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('提醒设置', colors),
                _buildSettingCard(colors, children: [
                  _buildSettingItemWithSwitch(
                    icon: Icons.nightlight_round, iconBg: const Color(0xFFAF52DE),
                    title: '早睡提醒', subtitle: '每天 ${_formatTime(_bedtime)}',
                    value: _bedtimeEnabled, onChanged: _toggleBedtime, colors: colors,
                  ),
                  if (_bedtimeEnabled) ...[
                    _buildDivider(colors),
                    _buildSettingItem(
                      icon: Icons.access_time_rounded, iconBg: colors.accent,
                      title: '提醒时间', value: _formatTime(_bedtime),
                      onTap: _showBedtimePicker, colors: colors,
                    ),
                  ],
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('账户安全', colors),
                _buildSettingCard(colors, children: [
                  _buildSettingItem(
                    icon: Icons.lock_rounded, iconBg: colors.blue,
                    title: '修改密码', onTap: _showChangePasswordSheet, colors: colors,
                  ),
                  _buildDivider(colors),
                  _buildSettingItem(
                    icon: Icons.logout_rounded, iconBg: colors.error,
                    title: '退出登录', titleColor: colors.error,
                    onTap: _showLogoutDialog, colors: colors,
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSectionTitle('关于', colors),
                _buildSettingCard(colors, children: [
                  _buildSettingItem(
                    icon: Icons.info_rounded, iconBg: colors.orange,
                    title: '版本', value: '1.5.4', showArrow: false, colors: colors,
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user, AppColors colors, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: colors.primaryGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(children: const [
              Text('设置', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ]),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Row(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: Text(
                      user?.avatar?.isNotEmpty == true ? user!.avatar! : '👤',
                      style: const TextStyle(fontSize: 36),
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '未设置昵称',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.phoneNumber ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  )),
                  GestureDetector(
                    onTap: _showEditProfileSheet,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: TextStyle(
        fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary, letterSpacing: 0.5,
      )),
    );
  }

  Widget _buildSettingCard(AppColors colors, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg, borderRadius: BorderRadius.circular(16),
        boxShadow: colors.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 60),
      child: Divider(height: 1, color: colors.divider),
    );
  }

  Widget _buildSettingItem({
    required IconData icon, required Color iconBg, required String title,
    String? value, Color? titleColor, bool showArrow = true,
    VoidCallback? onTap, required AppColors colors,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: titleColor ?? colors.textPrimary,
            ))),
            if (value != null) Text(value, style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w500, color: colors.textSecondary,
            )),
            if (showArrow) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: colors.textTertiary, size: 22),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildSettingItemWithSwitch({
    required IconData icon, required Color iconBg, required String title,
    String? subtitle, required bool value, required Function(bool) onChanged,
    required AppColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colors.textPrimary)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSecondary)),
            ],
          ],
        )),
        _buildSwitch(value, onChanged, colors),
      ]),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged, AppColors colors) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value ? LinearGradient(colors: colors.primaryGradient) : null,
          color: value ? null : colors.divider,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28, height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: value ? Icon(Icons.check, size: 16, color: colors.primary) : null,
          ),
        ),
      ),
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
    int tempH = _bedtime.hour, tempM = _bedtime.minute;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 340, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CupertinoButton(padding: EdgeInsets.zero, onPressed: () => Navigator.pop(ctx),
              child: Text('取消', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600))),
            Text('选择时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            CupertinoButton(padding: EdgeInsets.zero, onPressed: () async {
              setState(() => _bedtime = TimeOfDay(hour: tempH, minute: tempM));
              Navigator.pop(ctx);
              if (_bedtimeEnabled) await _notificationService.scheduleBedtimeReminder(hour: tempH, minute: tempM);
              await _saveBedtimeSettings();
            }, child: Text('确定', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 10),
          Expanded(child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time, use24hFormat: true,
            initialDateTime: DateTime(2024, 1, 1, _bedtime.hour, _bedtime.minute),
            onDateTimeChanged: (dt) { tempH = dt.hour; tempM = dt.minute; },
          )),
        ]),
      ),
    );
  }

  void _showThemePicker() {
    final currentMode = ref.read(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colors.cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('选择主题', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 20),
          _buildThemeOption(ctx, Icons.light_mode_rounded, '浅色模式', '始终使用浅色主题',
            currentMode == ThemeMode.light, () { ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light); Navigator.pop(ctx); }, colors),
          const SizedBox(height: 12),
          _buildThemeOption(ctx, Icons.dark_mode_rounded, '深色模式', '始终使用深色主题',
            currentMode == ThemeMode.dark, () { ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark); Navigator.pop(ctx); }, colors),
          const SizedBox(height: 12),
          _buildThemeOption(ctx, Icons.brightness_auto_rounded, '跟随系统', '自动适应系统主题设置',
            currentMode == ThemeMode.system, () { ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system); Navigator.pop(ctx); }, colors),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
        ]),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext ctx, IconData icon, String title, String subtitle, bool isSelected, VoidCallback onTap, AppColors colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.1) : colors.cardBgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(colors: colors.primaryGradient) : null,
              color: isSelected ? null : colors.divider,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isSelected ? Colors.white : colors.textSecondary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colors.textSecondary)),
          ])),
          if (isSelected) Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(gradient: LinearGradient(colors: colors.primaryGradient), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
        ]),
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
          decoration: BoxDecoration(color: colors.cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('编辑个人信息', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 20),
            Center(child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors.primaryGradient),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: Text(selectedAvatar.isEmpty ? '👤' : selectedAvatar, style: const TextStyle(fontSize: 48))),
            )),
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: _avatarOptions.map((emoji) {
              final isSelected = selectedAvatar == emoji;
              return GestureDetector(
                onTap: () => setS(() => selectedAvatar = emoji),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? colors.primary.withOpacity(0.1) : colors.cardBgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: colors.primary, width: 2) : null,
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: nicknameController, placeholder: '昵称', padding: const EdgeInsets.all(14),
              style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
              placeholderStyle: TextStyle(color: colors.textTertiary),
              decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(12)),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: colors.buttonDecoration(radius: 14),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () async {
                  await ref.read(authProvider.notifier).updateProfile(
                    nickname: nicknameController.text.isNotEmpty ? nicknameController.text : null,
                    avatar: selectedAvatar.isNotEmpty ? selectedAvatar : null,
                  );
                  if (mounted) Navigator.pop(ctx);
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();
    bool isLoading = false;
    String? errorMsg;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: colors.cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('修改密码', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 20),
              _buildPasswordField(oldPwdCtrl, '当前密码', colors),
              const SizedBox(height: 12),
              _buildPasswordField(newPwdCtrl, '新密码（至少6位）', colors),
              const SizedBox(height: 12),
              _buildPasswordField(confirmPwdCtrl, '确认新密码', colors),
              if (errorMsg != null) ...[const SizedBox(height: 12), Text(errorMsg!, style: TextStyle(color: colors.error, fontSize: 14, fontWeight: FontWeight.w500))],
              const SizedBox(height: 20),
              Container(
                decoration: colors.buttonDecoration(radius: 14),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: isLoading ? null : () async {
                    if (oldPwdCtrl.text.isEmpty) { setS(() => errorMsg = '请输入当前密码'); return; }
                    if (newPwdCtrl.text.length < 6) { setS(() => errorMsg = '新密码至少6位'); return; }
                    if (newPwdCtrl.text != confirmPwdCtrl.text) { setS(() => errorMsg = '两次密码不一致'); return; }
                    setS(() { isLoading = true; errorMsg = null; });
                    try {
                      await ApiService().changePassword(oldPwdCtrl.text, newPwdCtrl.text);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('密码修改成功', style: TextStyle(fontWeight: FontWeight.w500)),
                          backgroundColor: colors.success, behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    } catch (e) { setS(() { isLoading = false; errorMsg = '当前密码错误'; }); }
                  },
                  child: isLoading
                    ? const CupertinoActivityIndicator(color: Colors.white)
                    : const Text('确认修改', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String placeholder, AppColors colors) {
    return CupertinoTextField(
      controller: controller, placeholder: placeholder, obscureText: true, padding: const EdgeInsets.all(14),
      style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w500),
      placeholderStyle: TextStyle(color: colors.textTertiary),
      decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colors.cardBg, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: colors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.logout_rounded, color: colors.error, size: 32),
          ),
          const SizedBox(height: 16),
          Text('退出登录', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 8),
          Text('确定要退出当前账号吗？', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: colors.textSecondary)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text('取消', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            )),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).logout();
                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: Text('退出', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            )),
          ]),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 10),
        ]),
      ),
    );
  }
}
