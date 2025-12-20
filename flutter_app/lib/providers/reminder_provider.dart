import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder.dart';
import '../services/api_service.dart';

class ReminderState {
  final List<Reminder> reminders;
  final bool isLoading;
  final String? error;

  ReminderState({
    this.reminders = const [],
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    bool? isLoading,
    String? error,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Reminder? get bedtimeReminder {
    try {
      return reminders.firstWhere((r) => r.isBedtime);
    } catch (_) {
      return null;
    }
  }

  List<Reminder> get periodicReminders {
    return reminders.where((r) => r.isPeriodic).toList();
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ApiService _apiService;

  ReminderNotifier(this._apiService) : super(ReminderState());

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.getReminders();
      final reminders = (response.data as List)
          .map((json) => Reminder.fromJson(json))
          .toList();
      state = state.copyWith(reminders: reminders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载提醒设置失败');
    }
  }

  Future<bool> createReminder(String type, String scheduledTime, String? content) async {
    try {
      await _apiService.createReminder(type, scheduledTime, content);
      await loadReminders();
      return true;
    } catch (e) {
      state = state.copyWith(error: '创建提醒失败');
      return false;
    }
  }

  Future<bool> updateReminder(int id, {String? scheduledTime, String? content, bool? isEnabled}) async {
    try {
      await _apiService.updateReminder(id, scheduledTime: scheduledTime, content: content, isEnabled: isEnabled);
      await loadReminders();
      return true;
    } catch (e) {
      state = state.copyWith(error: '更新提醒失败');
      return false;
    }
  }

  Future<bool> toggleReminder(Reminder reminder) async {
    return updateReminder(reminder.id!, isEnabled: !reminder.isEnabled);
  }

  Future<bool> deleteReminder(int id) async {
    try {
      await _apiService.deleteReminder(id);
      await loadReminders();
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除提醒失败');
      return false;
    }
  }
}

final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  return ReminderNotifier(ApiService());
});
