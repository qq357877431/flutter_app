import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 提醒设置标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('提醒设置', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          // 早睡提醒
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: _icon(Icons.nightlight_round, const Color(0xFF5856D6)),
                  title: const Text('早睡提醒'),
                  subtitle: Text('每天 ${_formatTime(_bedtime)}'),
                  trailing: Switch.adaptive(value: _bedtimeEnabled, onChanged: _toggleBedtime),
                ),
                if (_bedtimeEnabled) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: _icon(Icons.access_time, const Color(0xFF007AFF)),
                    title: const Text('提醒时间'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_formatTime(_bedtime), style: TextStyle(color: Colors.grey[600])),
                        const Icon(Icons.chevron_right, color: Colors.grey),
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
            child: Text('账户', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _icon(Icons.logout, const Color(0xFFFF3B30)),
              title: const Text('退出登录', style: TextStyle(color: Color(0xFFFF3B30))),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showLogoutDialog,
            ),
          ),
          const SizedBox(height: 24),
          // 关于标题
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text('关于', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: _icon(Icons.info_outline, const Color(0xFF007AFF)),
              title: const Text('版本'),
              trailing: Text('1.1.1', style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ],
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
