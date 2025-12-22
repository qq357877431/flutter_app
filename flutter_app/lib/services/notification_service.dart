import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _isSupported = false;

  NotificationService._internal();

  Future<void> initialize() async {
    if (_initialized) return;

    // Windows 平台不支持本地通知
    if (Platform.isWindows) {
      _initialized = true;
      _isSupported = false;
      return;
    }

    _isSupported = true;
    tz.initializeTimeZones();
    
    // 设置本地时区为上海
    tz.setLocalLocation(tz.getLocation('Asia/Shanghai'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (!_isSupported) return;
    
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 设置每日定时提醒（早睡提醒）
  /// [hour] 小时 (0-23)
  /// [minute] 分钟 (0-59)
  Future<void> scheduleDailyNotification({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;
    
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '每日提醒',
          channelDescription: '每日定时提醒通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 设置周期性提醒
  /// [intervalHours] 间隔小时数
  Future<void> schedulePeriodicNotification({
    required int id,
    required int intervalHours,
    required String title,
    required String body,
  }) async {
    if (!_isSupported) return;
    
    RepeatInterval interval;
    if (intervalHours <= 1) {
      interval = RepeatInterval.hourly;
    } else if (intervalHours <= 24) {
      interval = RepeatInterval.daily;
    } else {
      interval = RepeatInterval.weekly;
    }

    await _notifications.periodicallyShow(
      id,
      title,
      body,
      interval,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'periodic_reminder',
          '周期提醒',
          channelDescription: '周期性提醒通知',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// 设置早睡提醒（默认 23:00）
  Future<void> scheduleBedtimeReminder({
    int id = 1000,
    int hour = 23,
    int minute = 0,
  }) async {
    await scheduleDailyNotification(
      id: id,
      hour: hour,
      minute: minute,
      title: '早睡提醒',
      body: '该休息了，早睡早起身体好！',
    );
  }

  /// 设置喝水提醒 (支持自定义开始时间和分钟精度间隔)
  Future<void> scheduleWaterReminder({
    int id = 2000,
    int startHour = 8,
    int startMinute = 0,
    int intervalMinutes = 60,
  }) async {
    if (!_isSupported) return;
    
    // 取消之前的提醒
    for (int i = 0; i < 24; i++) {
      await _notifications.cancel(id + i);
    }
    
    // 计算从开始时间到晚上22点的所有提醒时间点
    final endHour = 22; // 晚上10点停止提醒
    
    // 收集所有需要提醒的时间点 (小时:分钟)
    List<Map<String, int>> reminderTimes = [];
    int currentHour = startHour;
    int currentMinute = startMinute;
    
    while (currentHour < endHour && reminderTimes.length < 24) {
      reminderTimes.add({'hour': currentHour, 'minute': currentMinute});
      
      // 增加间隔
      currentMinute += intervalMinutes;
      while (currentMinute >= 60) {
        currentMinute -= 60;
        currentHour++;
      }
    }
    
    // 为每个时间点设置每日重复提醒
    for (int i = 0; i < reminderTimes.length; i++) {
      final time = reminderTimes[i];
      await scheduleDailyNotification(
        id: id + i,
        hour: time['hour']!,
        minute: time['minute']!,
        title: '喝水提醒',
        body: '记得喝水，保持健康！💧',
      );
    }
  }

  /// 取消指定提醒
  Future<void> cancelNotification(int id) async {
    if (!_isSupported) return;
    await _notifications.cancel(id);
  }

  /// 取消所有提醒
  Future<void> cancelAllNotifications() async {
    if (!_isSupported) return;
    await _notifications.cancelAll();
  }

  /// 立即发送测试通知
  Future<void> showTestNotification() async {
    if (!_isSupported) return;
    
    await _notifications.show(
      9999,
      '测试通知',
      '通知功能正常工作！🎉',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notification',
          '测试通知',
          channelDescription: '测试通知功能',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
