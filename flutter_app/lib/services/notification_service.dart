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
    for (int i = 0; i < 16; i++) {
      await _notifications.cancel(id + i);
    }
    
    // 计算从开始时间到晚上22点的所有提醒时间
    final now = tz.TZDateTime.now(tz.local);
    final endHour = 22; // 晚上10点停止提醒
    
    int notificationIndex = 0;
    var currentTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, startHour, startMinute);
    
    while (currentTime.hour < endHour && notificationIndex < 16) {
      var scheduledTime = currentTime;
      
      // 如果时间已过，设置为明天
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await _notifications.zonedSchedule(
        id + notificationIndex,
        '喝水提醒',
        '记得喝水，保持健康！💧',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            '喝水提醒',
            channelDescription: '定时喝水提醒',
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
        matchDateTimeComponents: DateTimeComponents.time, // 每天重复
      );
      
      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
      notificationIndex++;
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

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
