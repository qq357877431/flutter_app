import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _waterIntervalMinutes = 120;
  bool _waterEnabled = false;

  @override
  void initState() { super.initState(); _initNotifications(); }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  String _formatWaterInterval() {
    final hours = _waterIntervalMinutes ~/ 60;
    final minutes = _waterIntervalMinutes % 60;
    if (hours > 0 && minutes > 0) return '$hours小时$minutes分钟';
    if (hours > 0) return '$hours小时';
    return '$minutes分钟';
  }

  Future<void> _toggleBedtimeReminder(bool value) async {
    setState(() => _bedtimeEnabled = value);
    if (value) await _notificationService.scheduleBedtimeReminder(hour: _bedtime.hour, minute: _bedtime.minute);
    else await _notificationService.cancelNotification(1000);
  }

  Future<void> _toggleWaterReminder(bool value) async {
    setState(() => _waterEnabled = value);
    if (value) await _notificationService.scheduleWaterReminder(intervalMinutes: _waterIntervalMinutes);
    else await _notificationService.cancelNotification(2000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF0F4FF), Color(0xFFFAFBFF)])),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(backgroundColor: Colors.transparent, title: const Text('设置')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('提醒设置', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667EEA))),
                    const SizedBox(height: 12),
                    _buildCard([
                      _buildSwitch('早睡提醒', '每天 ${_bedtime.format(context)}', _bedtimeEnabled, _toggleBedtimeReminder),
                    ]),
                    const SizedBox(height: 16),
                    _buildCard([
                      _buildSwitch('喝水提醒', '每 ${_formatWaterInterval()} 提醒', _waterEnabled, _toggleWaterReminder),
                    ]),
                    const SizedBox(height: 32),
                    const Text('账户', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667EEA))),
                    const SizedBox(height: 12),
                    _buildCard([
                      ListTile(title: const Text('退出登录'), trailing: const Icon(CupertinoIcons.chevron_right), onTap: _logout),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
    child: Column(children: children),
  );

  Widget _buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600]))])),
      CupertinoSwitch(value: value, onChanged: onChanged),
    ]),
  );

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }
}
