import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/plan.dart';
import '../services/api_service.dart';

class PlanState {
  final List<Plan> plans;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;

  PlanState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now().add(const Duration(days: 1));

  PlanState copyWith({
    List<Plan>? plans,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class PlanNotifier extends StateNotifier<PlanState> {
  final ApiService _apiService;

  PlanNotifier(this._apiService) : super(PlanState());

  Future<void> loadPlans({DateTime? date}) async {
    final targetDate = date ?? state.selectedDate;
    state = state.copyWith(isLoading: true, error: null, selectedDate: targetDate);
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
      final response = await _apiService.getPlans(date: dateStr);
      final plans = (response.data as List)
          .map((json) => Plan.fromJson(json))
          .toList();
      state = state.copyWith(plans: plans, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载计划失败');
    }
  }

  Future<bool> createPlan(String content) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate);
      await _apiService.createPlan(content, dateStr);
      await loadPlans();
      return true;
    } catch (e) {
      state = state.copyWith(error: '创建计划失败');
      return false;
    }
  }

  Future<bool> updatePlan(int id, {String? content, String? status}) async {
    try {
      await _apiService.updatePlan(id, content: content, status: status);
      await loadPlans();
      return true;
    } catch (e) {
      state = state.copyWith(error: '更新计划失败');
      return false;
    }
  }

  Future<bool> togglePlanStatus(Plan plan) async {
    final newStatus = plan.isCompleted ? 'pending' : 'completed';
    return updatePlan(plan.id!, status: newStatus);
  }

  Future<bool> deletePlan(int id) async {
    try {
      await _apiService.deletePlan(id);
      await loadPlans();
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除计划失败');
      return false;
    }
  }

  void setSelectedDate(DateTime date) {
    loadPlans(date: date);
  }
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ApiService());
});
