import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../models/plan.dart';
import '../providers/auth_provider.dart';
import '../providers/plan_provider.dart';
import '../services/haptic_service.dart';
import '../services/notification_service.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(planProvider.notifier).loadPlans();
      _checkAndScheduleReminder();
    });
  }
  
  Future<void> _checkAndScheduleReminder() async {
    final planState = ref.read(planProvider);
    final plans = planState.plans;
    
    if (plans.isEmpty) {
      await _notificationService.cancelPlanReminder();
      return;
    }
    
    final allCompleted = plans.every((p) => p.isCompleted);
    
    if (allCompleted) {
      await _notificationService.cancelPlanReminder();
    } else {
      final user = ref.read(authProvider).user;
      final userName = user?.nickname ?? user?.username;
      await _notificationService.schedulePlanReminder(userName: userName);
    }
  }

  void _showAddPlanSheet() {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20, left: 24, right: 24,
        ),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '添加新计划',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: colors.cardBgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CupertinoTextField(
                controller: controller,
                placeholder: '输入计划内容...',
                placeholderStyle: TextStyle(color: colors.textTertiary),
                padding: const EdgeInsets.all(16),
                maxLines: 3,
                autofocus: true,
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
                decoration: BoxDecoration(
                  color: colors.cardBgSecondary,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: colors.cardBgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    child: Text(
                      '取消',
                      style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: colors.buttonDecoration(radius: 12),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        '添加',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          await ref.read(planProvider.notifier).createPlan(controller.text);
                          if (mounted) {
                            Navigator.pop(ctx);
                            _checkAndScheduleReminder();
                          }
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    final planState = ref.read(planProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    DateTime tempDate = planState.selectedDate;
    
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
                Text('选择日期', style: TextStyle(
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
                    ref.read(planProvider.notifier).setSelectedDate(tempDate);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: planState.selectedDate,
                minimumDate: DateTime.now().subtract(const Duration(days: 365)),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (date) => tempDate = date,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planState = ref.watch(planProvider);
    final dateFormat = DateFormat('M月d日 EEEE', 'zh_CN');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);

    return CupertinoPageScaffold(
      backgroundColor: colors.scaffoldBg,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // 1. Sliver Navigation Bar
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              '每日计划',
              style: TextStyle(color: colors.textPrimary),
            ),
            backgroundColor: colors.scaffoldBg.withOpacity(0.8),
            border: null, // Remove default border for cleaner look
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date Picker Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.cardBgSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.calendar, color: colors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                // Add Plan Button (Moved to top)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showAddPlanSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors.primaryGradient),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withOpacity(0.3),
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
                          '添加',
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

          // 2. Date & Progress Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(CupertinoIcons.calendar_today, color: colors.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateFormat.format(planState.selectedDate),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${planState.plans.length} 个计划 · ${planState.plans.where((p) => p.isCompleted).length} 已完成',
                            style: TextStyle(color: colors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    // Circular Progress
                    _buildCircularProgress(planState.plans, colors),
                  ],
                ),
              ),
            ),
          ),

          // 3. Plan List
          if (planState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CupertinoActivityIndicator()),
            )
          else if (planState.plans.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(colors),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final plan = planState.plans[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _PlanTile(
                      plan: plan,
                      colors: colors,
                      onToggle: () async {
                        HapticService.mediumImpact();
                        await ref.read(planProvider.notifier).togglePlanStatus(plan);
                        _checkAndScheduleReminder();
                      },
                      onDelete: () async {
                        await ref.read(planProvider.notifier).deletePlan(plan.id!);
                        _checkAndScheduleReminder();
                      },
                    ),
                  );
                },
                childCount: planState.plans.length,
              ),
            ),

          // 4. Bottom Padding for scrolling
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(List<Plan> plans, AppColors colors) {
    if (plans.isEmpty) return const SizedBox();
    final completed = plans.where((p) => p.isCompleted).length;
    final progress = completed / plans.length;
    
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: colors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(colors.success),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.doc_text, size: 48, color: colors.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无计划',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 "添加" 按钮开始规划',
            style: TextStyle(color: colors.textTertiary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final Plan plan;
  final AppColors colors;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PlanTile({
    required this.plan,
    required this.colors,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(plan.id.toString()),
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Animated Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: plan.isCompleted ? colors.success : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: plan.isCompleted ? colors.success : colors.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: plan.isCompleted
                        ? const Icon(CupertinoIcons.checkmark, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: plan.isCompleted ? 0.5 : 1.0,
                      child: Text(
                        plan.content,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: colors.textTertiary,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
