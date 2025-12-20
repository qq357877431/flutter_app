import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final _notificationService = NotificationService();
  List<WaterRecord> _records = [];
  int _todayTotal = 0;
  final int _dailyGoal = 2000; // 每日目标 2000ml
  
  // 提醒设置
  bool _reminderEnabled = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  int _intervalMinutes = 60;

  final List<DrinkType> _drinkTypes = [
    DrinkType('白开水', Icons.water_drop, const Color(0xFF007AFF), 250),
    DrinkType('茶', Icons.emoji_food_beverage, const Color(0xFF34C759), 200),
    DrinkType('咖啡', Icons.coffee, const Color(0xFF8B4513), 150),
    DrinkType('牛奶', Icons.local_cafe, const Color(0xFFF5F5DC), 250),
    DrinkType('奶茶', Icons.bubble_chart, const Color(0xFFDEB887), 500),
    DrinkType('果汁', Icons.local_bar, const Color(0xFFFF9500), 300),
    DrinkType('饮料', Icons.local_drink, const Color(0xFFFF2D55), 330),
    DrinkType('其他', Icons.add_circle_outline, const Color(0xFF8E8E93), 200),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final recordsJson = prefs.getString('water_records_$today') ?? '[]';
    final records = (jsonDecode(recordsJson) as List)
        .map((e) => WaterRecord.fromJson(e))
        .toList();
    
    _reminderEnabled = prefs.getBool('water_reminder_enabled') ?? false;
    _startTime = TimeOfDay(
      hour: prefs.getInt('water_start_hour') ?? 8,
      minute: prefs.getInt('water_start_minute') ?? 0,
    );
    _intervalMinutes = prefs.getInt('water_interval') ?? 60;
    
    setState(() {
      _records = records;
      _todayTotal = records.fold(0, (sum, r) => sum + r.amount);
    });
  }


  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    await prefs.setString('water_records_$today', jsonEncode(_records.map((e) => e.toJson()).toList()));
    await prefs.setBool('water_reminder_enabled', _reminderEnabled);
    await prefs.setInt('water_start_hour', _startTime.hour);
    await prefs.setInt('water_start_minute', _startTime.minute);
    await prefs.setInt('water_interval', _intervalMinutes);
  }

  void _addRecord(DrinkType type, int amount) {
    setState(() {
      _records.insert(0, WaterRecord(
        type: type.name,
        amount: amount,
        time: DateTime.now(),
        icon: type.icon.codePoint,
        color: type.color.value,
      ));
      _todayTotal += amount;
    });
    _saveData();
  }

  void _deleteRecord(int index) {
    setState(() {
      _todayTotal -= _records[index].amount;
      _records.removeAt(index);
    });
    _saveData();
  }

  void _showAddDialog(DrinkType type) {
    int amount = type.defaultAmount;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
                Text(type.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                CupertinoButton(
                  child: const Text('添加'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addRecord(type, amount);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('选择饮用量 (ml)', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(initialItem: amount ~/ 50 - 1),
                onSelectedItemChanged: (i) => amount = (i + 1) * 50,
                children: List.generate(20, (i) => Center(
                  child: Text('${(i + 1) * 50} ml', style: const TextStyle(fontSize: 22)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderSettings() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Material(
          color: Colors.transparent,
          child: Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(ctx),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('喝水提醒', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    CupertinoButton(child: const Text('完成'), onPressed: () {
                      Navigator.pop(ctx);
                      _saveData();
                      if (_reminderEnabled) _scheduleReminder();
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                _settingRow('开启提醒', CupertinoSwitch(
                  value: _reminderEnabled,
                  onChanged: (v) {
                    setSheetState(() => _reminderEnabled = v);
                    setState(() => _reminderEnabled = v);
                    if (!v) _notificationService.cancelNotification(2000);
                  },
                )),
                _settingRow('开始时间', GestureDetector(
                  onTap: () => _pickTime(ctx, setSheetState),
                  child: Text('${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFF007AFF), fontSize: 16)),
                )),
                _settingRow('提醒间隔', GestureDetector(
                  onTap: () => _pickInterval(ctx, setSheetState),
                  child: Text('${_intervalMinutes}分钟',
                    style: const TextStyle(color: Color(0xFF007AFF), fontSize: 16)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 16)), trailing],
      ),
    );
  }

  void _pickTime(BuildContext ctx, StateSetter setSheetState) {
    int h = _startTime.hour, m = _startTime.minute;
    showCupertinoModalPopup(
      context: ctx,
      builder: (c) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(c),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(child: const Text('取消'), onPressed: () => Navigator.pop(c)),
                CupertinoButton(child: const Text('确定'), onPressed: () {
                  setSheetState(() => _startTime = TimeOfDay(hour: h, minute: m));
                  setState(() => _startTime = TimeOfDay(hour: h, minute: m));
                  Navigator.pop(c);
                }),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: DateTime(2024, 1, 1, _startTime.hour, _startTime.minute),
                onDateTimeChanged: (dt) { h = dt.hour; m = dt.minute; },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickInterval(BuildContext ctx, StateSetter setSheetState) {
    final intervals = [15, 30, 45, 60, 90, 120];
    showCupertinoModalPopup(
      context: ctx,
      builder: (c) => Container(
        height: 280,
        color: CupertinoColors.systemBackground.resolveFrom(c),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text('选择提醒间隔', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 44,
                scrollController: FixedExtentScrollController(
                  initialItem: intervals.indexOf(_intervalMinutes).clamp(0, intervals.length - 1),
                ),
                onSelectedItemChanged: (i) {
                  setSheetState(() => _intervalMinutes = intervals[i]);
                  setState(() => _intervalMinutes = intervals[i]);
                },
                children: intervals.map((i) => Center(
                  child: Text('$i 分钟', style: const TextStyle(fontSize: 20)),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleReminder() async {
    await _notificationService.scheduleWaterReminder(
      startHour: _startTime.hour,
      startMinute: _startTime.minute,
      intervalMinutes: _intervalMinutes,
    );
  }


  @override
  Widget build(BuildContext context) {
    final progress = (_todayTotal / _dailyGoal).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('喝水记录', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_reminderEnabled ? Icons.notifications_active : Icons.notifications_none,
              color: _reminderEnabled ? const Color(0xFF007AFF) : Colors.grey),
            onPressed: _showReminderSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 今日进度卡片
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: const Color(0xFF007AFF).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('今日饮水', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('$_todayTotal ml', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text('目标 $_dailyGoal ml', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ],
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 快速添加
          const Text('快速添加', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _drinkTypes.map((type) => _buildDrinkButton(type)).toList(),
          ),
          const SizedBox(height: 20),
          // 今日记录
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('今日记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                if (_records.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('还没有记录，点击上方添加', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...List.generate(_records.length, (i) => Column(
                    children: [
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildRecordItem(i),
                      ),
                    ],
                  )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkButton(DrinkType type) {
    return GestureDetector(
      onTap: () => _showAddDialog(type),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: type.color, size: 26),
            const SizedBox(height: 4),
            Text(type.name, style: TextStyle(fontSize: 11, color: type.color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(int index) {
    final record = _records[index];
    final time = '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}';
    return Dismissible(
      key: Key(record.time.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteRecord(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(record.color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(IconData(record.icon, fontFamily: 'MaterialIcons'), color: Color(record.color)),
        ),
        title: Text(record.type),
        subtitle: Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Text('${record.amount} ml', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF007AFF))),
      ),
    );
  }
}

class DrinkType {
  final String name;
  final IconData icon;
  final Color color;
  final int defaultAmount;
  DrinkType(this.name, this.icon, this.color, this.defaultAmount);
}

class WaterRecord {
  final String type;
  final int amount;
  final DateTime time;
  final int icon;
  final int color;
  WaterRecord({required this.type, required this.amount, required this.time, required this.icon, required this.color});
  
  Map<String, dynamic> toJson() => {'type': type, 'amount': amount, 'time': time.toIso8601String(), 'icon': icon, 'color': color};
  factory WaterRecord.fromJson(Map<String, dynamic> json) => WaterRecord(
    type: json['type'],
    amount: json['amount'],
    time: DateTime.parse(json['time']),
    icon: json['icon'],
    color: json['color'],
  );
}
