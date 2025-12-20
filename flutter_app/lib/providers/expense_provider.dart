import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseState {
  final List<Expense> expenses;
  final double total;
  final bool isLoading;
  final String? error;

  ExpenseState({
    this.expenses = const [],
    this.total = 0,
    this.isLoading = false,
    this.error,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    double? total,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ApiService _apiService;

  ExpenseNotifier(this._apiService) : super(ExpenseState());

  Future<void> loadExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _apiService.getExpenses();
      final total = (response.data['total'] as num).toDouble();
      final expenses = (response.data['expenses'] as List)
          .map((json) => Expense.fromJson(json))
          .toList();
      state = state.copyWith(expenses: expenses, total: total, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '加载消费记录失败');
    }
  }

  Future<bool> createExpense(double amount, String category, String? note) async {
    try {
      await _apiService.createExpense(amount, category, note);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(error: '创建消费记录失败');
      return false;
    }
  }

  Future<bool> updateExpense(int id, {double? amount, String? category, String? note}) async {
    try {
      await _apiService.updateExpense(id, amount: amount, category: category, note: note);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(error: '更新消费记录失败');
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _apiService.deleteExpense(id);
      await loadExpenses();
      return true;
    } catch (e) {
      state = state.copyWith(error: '删除消费记录失败');
      return false;
    }
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  return ExpenseNotifier(ApiService());
});
