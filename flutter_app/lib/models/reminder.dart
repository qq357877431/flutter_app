class Reminder {
  final int? id;
  final String reminderType;
  final String scheduledTime;
  final String? content;
  final bool isEnabled;

  Reminder({
    this.id,
    required this.reminderType,
    required this.scheduledTime,
    this.content,
    this.isEnabled = true,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as int?,
      reminderType: json['reminder_type'] as String,
      scheduledTime: json['scheduled_time'] as String,
      content: json['content'] as String?,
      isEnabled: json['is_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'reminder_type': reminderType,
      'scheduled_time': scheduledTime,
      'content': content ?? '',
      'is_enabled': isEnabled,
    };
  }

  Reminder copyWith({
    int? id,
    String? reminderType,
    String? scheduledTime,
    String? content,
    bool? isEnabled,
  }) {
    return Reminder(
      id: id ?? this.id,
      reminderType: reminderType ?? this.reminderType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      content: content ?? this.content,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  bool get isBedtime => reminderType == 'bedtime';
  bool get isPeriodic => reminderType == 'periodic';
}
