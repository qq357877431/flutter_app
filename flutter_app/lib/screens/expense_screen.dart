import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  final _categories = [
    {'name': '餐饮', 'icon': CupertinoIcons.cart_fill, 'colors': [const Color(0xFFFF9500), const Color(0xFFFFB347)]},
    {'name': '交通', 'icon': CupertinoIcons.car_fill, 'colors': [const Color(0xFF4FACFE), const Color(0xFF00F2FE)]},
    {'name': '购物', 'icon': CupertinoIcons.bag_fill, 'colors': [const Color(0xFFFA709A), const Color(0xFFFEE140)]},
    {'name': '娱乐', 'icon': CupertinoIcons.game_controller_solid, 'colors': [const Color(0xFF667EEA), const Color(0xFF764BA2)]},
    {'name': '其他', 'icon': CupertinoIcons.ellipsis_circle_fill, 'colors': [const Color(0xFF8E8E93), const Color(0xFFAEAEB2)]},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseProvider.notifier).loadExpenses());
  }

  Map<String, dynamic> _getCategoryInfo(String name) => _categories.firstWhere((c) => c['name'] == name, orElse: () => _categories.last);

  void _showAddExpenseSheet() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String selectedCategory = _categories[0]['name'] as String;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF0FFF4), Color(0xFFE8F5E9)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                child: const Text('记一笔', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: CupertinoTextField(
                  controller: amountController,
                  placeholder: '0.00',
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                      child: const Text('¥', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 16),
              Text('分类', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[600])),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = selectedCategory == cat['name'];
                  final colors = cat['colors'] as List<Color>;
                  return GestureDetector(
                    onTap: () => setS(() => selectedCategory = cat['name'] as String),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? LinearGradient(colors: colors) : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [BoxShadow(color: colors.first.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))] : null,
                        border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(cat['icon'] as IconData, size: 18, color: isSelected ? Colors.white : colors.first),
                          const SizedBox(width: 6),
                          Text(cat['name'] as String, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: isSelected ? FontWeight.w600 : null)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: CupertinoTextField(
                  controller: noteController,
                  placeholder: '添加备注...',
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: const Text('保存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17)),
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
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

    return CupertinoPageScaffold(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E9), Color(0xFFF0FFF4), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义导航栏
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                      child: const Text('消费记录', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 总支出卡片
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(CupertinoIcons.money_dollar_circle_fill, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('总支出', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(currencyFormat.format(expenseState.total), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: -1)),
                    const SizedBox(height: 6),
                    Text('共 ${expenseState.expenses.length} 笔消费', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 消费明细标题
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                      child: const Text('消费明细', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // 消费列表
              Expanded(
                child: expenseState.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : expenseState.expenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [const Color(0xFF43E97B).withOpacity(0.1), const Color(0xFF38F9D7).withOpacity(0.1)]),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                                    child: const Icon(CupertinoIcons.money_dollar, size: 48, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ShaderMask(
                                  shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]).createShader(b),
                                  child: const Text('暂无消费记录', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: expenseState.expenses.length,
                            itemBuilder: (ctx, i) {
                              final expense = expenseState.expenses[i];
                              final catInfo = _getCategoryInfo(expense.category);
                              return _ExpenseTile(
                                expense: expense,
                                categoryIcon: catInfo['icon'] as IconData,
                                categoryColors: catInfo['colors'] as List<Color>,
                                currencyFormat: currencyFormat,
                                dateFormat: dateFormat,
                                onDelete: () => ref.read(expenseProvider.notifier).deleteExpense(expense.id!),
                              );
                            },
                          ),
              ),
              // 添加按钮
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: const Color(0xFF43E97B).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: _showAddExpenseSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('记一笔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.categoryIcon,
    required this.categoryColors,
    required this.currencyFormat,
    required this.dateFormat,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF8FAFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: categoryColors.first.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: categoryColors),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [BoxShadow(color: categoryColors.first.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(categoryIcon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.category, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  if (expense.note != null && expense.note!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(expense.note!, style: TextStyle(color: Colors.grey[500], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)]).createShader(b),
                  child: Text('-${currencyFormat.format(expense.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 3),
                Text(dateFormat.format(expense.createdAt), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
