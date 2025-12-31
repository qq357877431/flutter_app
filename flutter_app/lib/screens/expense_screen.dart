import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/haptic_service.dart';
import '../widgets/liquid/fluid_background.dart';
import '../widgets/liquid/liquid_header.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  int? _selectedYear;
  int? _selectedMonth;
  
  final _categories = [
    {'name': '餐饮', 'icon': CupertinoIcons.cart_fill, 'colors': [const Color(0xFFF59E0B), const Color(0xFFD97706)]},
    {'name': '交通', 'icon': CupertinoIcons.car_fill, 'colors': [const Color(0xFF3B82F6), const Color(0xFF2563EB)]},
    {'name': '购物', 'icon': CupertinoIcons.bag_fill, 'colors': [const Color(0xFFEC4899), const Color(0xFFDB2777)]},
    {'name': '娱乐', 'icon': CupertinoIcons.game_controller_solid, 'colors': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]},
    {'name': '其他', 'icon': CupertinoIcons.ellipsis_circle_fill, 'colors': [const Color(0xFF64748B), const Color(0xFF475569)]},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseProvider.notifier).loadExpenses());
  }

  Map<String, dynamic> _getCategoryInfo(String name) => _categories.firstWhere((c) => c['name'] == name, orElse: () => _categories.last);

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    if (_selectedYear == null && _selectedMonth == null) {
      return expenses;
    }
    return expenses.where((e) {
      if (_selectedYear != null && e.createdAt.year != _selectedYear) return false;
      if (_selectedMonth != null && e.createdAt.month != _selectedMonth) return false;
      return true;
    }).toList();
  }

  double _getFilteredTotal(List<Expense> expenses) {
    return _getFilteredExpenses(expenses).fold(0.0, (sum, e) => sum + e.amount);
  }

  void _showDateFilter() {
    final now = DateTime.now();
    int tempYear = _selectedYear ?? now.year;
    int tempMonth = _selectedMonth ?? now.month;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 380,
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
                Text('筛选日期', style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                )),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text('确定', style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  )),
                  onPressed: () {
                    setState(() {
                      _selectedYear = tempYear;
                      _selectedMonth = tempMonth;
                    });
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedYear = null;
                  _selectedMonth = null;
                });
                Navigator.pop(ctx);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('重置', style: TextStyle(color: colors.orange, fontSize: 13, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 44,
                      scrollController: FixedExtentScrollController(
                        initialItem: tempYear - 2020,
                      ),
                      onSelectedItemChanged: (index) {
                        tempYear = 2020 + index;
                      },
                      children: List.generate(
                        now.year - 2020 + 2,
                        (i) => Center(child: Text('${2020 + i}年', style: TextStyle(color: colors.textPrimary, fontSize: 18))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 44,
                      scrollController: FixedExtentScrollController(
                        initialItem: tempMonth - 1,
                      ),
                      onSelectedItemChanged: (index) {
                        tempMonth = index + 1;
                      },
                      children: List.generate(
                        12,
                        (i) => Center(child: Text('${i + 1}月', style: TextStyle(color: colors.textPrimary, fontSize: 18))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseSheet() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = _categories[0]['name'] as String;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            color: colors.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colors.divider, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('记一笔', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 16),
              Container(
                decoration: colors.cardDecoration(color: colors.cardBgSecondary, radius: 14),
                child: CupertinoTextField(
                  controller: amountController,
                  placeholder: '0.00',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text('¥', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.green)),
                  ),
                  padding: const EdgeInsets.all(16),
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              Text('分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: colors.textSecondary)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  final catColors = cat['colors'] as List<Color>;
                  return GestureDetector(
                    onTap: () => setS(() => selectedCategory = cat['name'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? catColors.first : colors.cardBgSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? null : Border.all(color: colors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData, size: 16, color: isSelected ? Colors.white : catColors.first),
                          const SizedBox(width: 4),
                          Text(cat['name'] as String, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : colors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : null)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: colors.cardDecoration(color: colors.cardBgSecondary, radius: 12),
                child: CupertinoTextField(
                  controller: noteController,
                  placeholder: '添加备注...',
                  placeholderStyle: TextStyle(color: colors.textTertiary),
                  padding: const EdgeInsets.all(14),
                  style: TextStyle(color: colors.textPrimary),
                  decoration: BoxDecoration(color: colors.cardBgSecondary, borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: colors.buttonDecoration(gradient: colors.greenGradient, radius: 14),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      HapticService.mediumImpact();
                      await ref.read(expenseProvider.notifier).createExpense(amount, selectedCategory, noteController.text.isEmpty ? null : noteController.text);
                      if (mounted) Navigator.pop(ctx);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseState = ref.watch(expenseProvider);
    final currencyFormat = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    final dateFormat = DateFormat('MM/dd HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    return FluidBackground(
      isDark: isDark,
      child: CupertinoPageScaffold(
        backgroundColor: Colors.transparent,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // 1. Liquid Header
            SliverPersistentHeader(
              pinned: true,
              delegate: LiquidHeader(
                title: '消费记录',
                isDark: isDark,
                trailing: [
                  // Filter Button (First)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticService.lightImpact();
                      _showDateFilter();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (_selectedYear != null || _selectedMonth != null) 
                            ? colors.green.withOpacity(0.15)
                            : colors.cardBgSecondary.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: (_selectedYear != null || _selectedMonth != null)
                            ? Border.all(color: colors.green, width: 1)
                            : null,
                      ),
                      child: Icon(
                        CupertinoIcons.calendar,
                        size: 20,
                        color: (_selectedYear != null || _selectedMonth != null)
                            ? colors.green
                            : colors.green, // Changed to green as requested
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add Expense Button (Second)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      HapticService.lightImpact();
                      _showAddExpenseSheet();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors.greenGradient),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '记一笔',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.greenGradient,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.greenGradient.first.withOpacity(colors.shadowOpacity),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          (_selectedYear != null && _selectedMonth != null)
                              ? '$_selectedYear年$_selectedMonth月支出'
                              : '总支出',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      currencyFormat.format(
                        (_selectedYear != null || _selectedMonth != null)
                            ? _getFilteredTotal(expenseState.expenses)
                            : expenseState.total
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '共 ${_getFilteredExpenses(expenseState.expenses).length} 笔消费',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Expense List
          if (expenseState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (_getFilteredExpenses(expenseState.expenses).isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.money_dollar, size: 48, color: colors.green.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (_selectedYear != null || _selectedMonth != null)
                          ? '该时间段暂无消费记录'
                          : '暂无消费记录',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final filteredExpenses = _getFilteredExpenses(expenseState.expenses);
                  final expense = filteredExpenses[i];
                  final catColors = colors.categoryColors[expense.category] ?? colors.categoryColors['其他']!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _ExpenseTile(
                      expense: expense,
                      categoryIcon: (_getCategoryInfo(expense.category)['icon'] as IconData),
                      categoryColors: catColors,
                      currencyFormat: currencyFormat,
                      dateFormat: dateFormat,
                      isDark: isDark,
                      colors: colors,
                      onDelete: () => ref.read(expenseProvider.notifier).deleteExpense(expense.id!),
                    ),
                  );
                },
                childCount: _getFilteredExpenses(expenseState.expenses).length,
              ),
            ),

          // 4. Bottom Padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final Expense expense;
  final IconData categoryIcon;
  final List<Color> categoryColors;
  final NumberFormat currencyFormat;
  final DateFormat dateFormat;
  final bool isDark;
  final AppColors colors;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.categoryIcon,
    required this.categoryColors,
    required this.currencyFormat,
    required this.dateFormat,
    required this.isDark,
    required this.colors,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: categoryColors),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: categoryColors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(categoryIcon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        expense.note!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '-${currencyFormat.format(expense.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(expense.createdAt),
                  style: TextStyle(
                    color: colors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
