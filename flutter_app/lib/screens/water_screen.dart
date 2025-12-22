import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math' as math;
import '../config/colors.dart';
import '../services/notification_service.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> with SingleTickerProviderStateMixin {
  final _notificationService = NotificationService();
  List<WaterRecord> _records = [];
  int _todayTotal = 0;
  final int _dailyGoal = 2000;
  
  bool _reminderEnabled = false;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  int _intervalMinutes = 60;
  
  late AnimationController _waveController;

  final List<DrinkType> _drinkTypes = [
    DrinkType('白开水', Icons.water_drop_rounded, const Color(0xFF42A5F5), 250),
    DrinkType('茶', Icons.emoji_food_beverage_rounded, const Color(0xFF66BB6A), 200),
    DrinkType('咖啡', Icons.coffee_rounded, const Color(0xFF8D6E63), 150),
    DrinkType('牛奶', Icons.local_cafe_rounded, const Color(0xFFFFECB3), 250),
    DrinkType('奶茶', Icons.bubble_chart_rounded, const Color(0xFFD7CCC8), 500),
    DrinkType('果汁', Icons.local_bar_rounded, const Color(0xFFFFB74D), 300),
    DrinkType('饮料', Icons.local_drink_rounded, const Color(0xFFEF5350), 330),
    DrinkType('其他', Icons.add_circle_outline_rounded, const Color(0xFF90A4AE), 200),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadData();
    _initNotifications();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
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
                Row(
                  children: [
                    Icon(type.icon, color: type.color, size: 24),
                    const SizedBox(width: 8),
                    Text(type.name, style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    )),
                  ],
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('添加', style: TextStyle(
                    color: colors.blue,
                    fontWeight: FontWeight.w600,
                  )),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addRecord(type, amount);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('选择饮用量', style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            )),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 50,
                scrollController: FixedExtentScrollController(initialItem: amount ~/ 50 - 1),
                onSelectedItemChanged: (i) => amount = (i + 1) * 50,
                children: List.generate(20, (i) => Center(
                  child: Text(
                    '${(i + 1) * 50} ml',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Material(
          color: Colors.transparent,
          child: Container(
            height: 420,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('喝水提醒', style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    )),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text('完成', style: TextStyle(
                        color: colors.blue,
                        fontWeight: FontWeight.w600,
                      )),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _saveData();
                        if (_reminderEnabled) _scheduleReminder();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSettingItem(
                  colors,
                  '开启提醒',
                  null,
                  _buildSwitch(colors, _reminderEnabled, (v) {
                    setSheetState(() => _reminderEnabled = v);
                    setState(() => _reminderEnabled = v);
                    if (!v) {
                      for (int i = 0; i < 24; i++) {
                        _notificationService.cancelNotification(2000 + i);
                      }
                    }
                  }),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  colors,
                  '开始时间',
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                  null,
                  onTap: () => _pickTime(ctx, setSheetState),
                ),
                const SizedBox(height: 16),
                _buildSettingItem(
                  colors,
                  '提醒间隔',
                  '$_intervalMinutes 分钟',
                  null,
                  onTap: () => _pickInterval(ctx, setSheetState),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: colors.gradientDecoration(colors.blueGradient),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: () async {
                        await _notificationService.showTestNotification();
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('测试通知已发送'),
                              backgroundColor: colors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                      child: const Text('发送测试通知', style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem(AppColors colors, String label, String? value, Widget? trailing, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: colors.cardDecoration(color: colors.cardBgSecondary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(
              fontSize: 16,
              color: colors.textPrimary,
            )),
            trailing ?? Row(
              children: [
                Text(value ?? '', style: TextStyle(
                  fontSize: 16,
                  color: colors.blue,
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: colors.textTertiary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(AppColors colors, bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value ? LinearGradient(colors: colors.blueGradient) : null,
          color: value ? null : colors.divider,
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
            child: value ? Icon(Icons.check, size: 16, color: colors.blue) : null,
          ),
        ),
      ),
    );
  }

  void _pickTime(BuildContext ctx, StateSetter setSheetState) {
    int h = _startTime.hour, m = _startTime.minute;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: ctx,
      builder: (c) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('取消', style: TextStyle(color: colors.textSecondary)),
                    onPressed: () => Navigator.pop(c),
                  ),
                  CupertinoButton(
                    child: Text('确定', style: TextStyle(color: colors.blue, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      setSheetState(() => _startTime = TimeOfDay(hour: h, minute: m));
                      setState(() => _startTime = TimeOfDay(hour: h, minute: m));
                      Navigator.pop(c);
                    },
                  ),
                ],
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: ctx,
      builder: (c) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('选择提醒间隔', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            )),
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
                  child: Text('$i 分钟', style: TextStyle(
                    fontSize: 20,
                    color: colors.textPrimary,
                  )),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部标题栏
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('喝水记录', style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    )),
                    GestureDetector(
                      onTap: _showReminderSettings,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _reminderEnabled 
                              ? colors.blue.withOpacity(0.15)
                              : colors.cardBgSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _reminderEnabled 
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_none_rounded,
                          color: _reminderEnabled ? colors.blue : colors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 进度卡片
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: colors.gradientDecoration(colors.blueGradient, radius: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('今日饮水', style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            )),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$_todayTotal', style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                )),
                                const SizedBox(width: 4),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text('ml', style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                  )),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('目标 $_dailyGoal ml', style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13,
                            )),
                          ],
                        ),
                        // 圆形进度
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 波浪动画背景
                              AnimatedBuilder(
                                animation: _waveController,
                                builder: (context, child) {
                                  return CustomPaint(
                                    size: const Size(90, 90),
                                    painter: _WavePainter(
                                      progress: progress,
                                      wavePhase: _waveController.value * 2 * math.pi,
                                    ),
                                  );
                                },
                              ),
                              // 百分比文字
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // 快速添加标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text('快速添加', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                )),
              ),
            ),
            
            // 饮品网格
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _drinkTypes.map((type) => _buildDrinkButton(type, colors)).toList(),
                ),
              ),
            ),
            
            // 今日记录标题
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('今日记录', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                )),
              ),
            ),
            
            // 记录列表
            _records.isEmpty
                ? SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(40),
                      decoration: colors.cardDecoration(),
                      child: Column(
                        children: [
                          Icon(Icons.water_drop_outlined, 
                            size: 48, 
                            color: colors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text('还没有记录', style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 15,
                          )),
                          const SizedBox(height: 4),
                          Text('点击上方添加饮水记录', style: TextStyle(
                            color: colors.textTertiary,
                            fontSize: 13,
                          )),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, index == _records.length - 1 ? 20 : 8),
                        child: _buildRecordItem(index, colors),
                      ),
                      childCount: _records.length,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrinkButton(DrinkType type, AppColors colors) {
    return GestureDetector(
      onTap: () => _showAddDialog(type),
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: type.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: type.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type.icon, color: type.color, size: 28),
            const SizedBox(height: 4),
            Text(type.name, style: TextStyle(
              fontSize: 11,
              color: type.color,
              fontWeight: FontWeight.w500,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordItem(int index, AppColors colors) {
    final record = _records[index];
    final time = '${record.time.hour.toString().padLeft(2, '0')}:${record.time.minute.toString().padLeft(2, '0')}';
    
    return Dismissible(
      key: Key(record.time.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteRecord(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.redGradient),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: colors.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(record.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                IconData(record.icon, fontFamily: 'MaterialIcons'),
                color: Color(record.color),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.type, style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  )),
                  const SizedBox(height: 2),
                  Text(time, style: TextStyle(
                    fontSize: 13,
                    color: colors.textSecondary,
                  )),
                ],
              ),
            ),
            Text('${record.amount} ml', style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.blue,
            )),
          ],
        ),
      ),
    );
  }
}

// 波浪动画画笔
class _WavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;

  _WavePainter({required this.progress, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 裁剪为圆形
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    
    // 背景圆
    final bgPaint = Paint()..color = Colors.white.withOpacity(0.2);
    canvas.drawCircle(center, radius, bgPaint);
    
    // 波浪
    final wavePaint = Paint()..color = Colors.white.withOpacity(0.4);
    final waveHeight = 4.0;
    final waterLevel = size.height * (1 - progress);
    
    final path = Path();
    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = waterLevel + math.sin((x / size.width * 2 * math.pi) + wavePhase) * waveHeight;
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.wavePhase != wavePhase;
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
