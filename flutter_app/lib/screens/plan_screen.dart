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
  
  // 检查并设置计划提醒
  Future<void> _checkAndScheduleReminder() async {
    final planState = ref.read(planProvider);
    final plans = planState.plans;
    
    if (plans.isEmpty) {
      await _notificationService.cancelPlanReminder();
      return;
    }
    
    final allCompleted = plans.every((p) => p.isCompleted);
    
    if (allCompleted) {
      // 全部完成，取消提醒
      await _notificationService.cancelPlanReminder();
    } else {
      // 还有未完成的，设置提醒 - 从 authProvider 获取用户名
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
      child: Container(
        color: colors.scaffoldBg,
        child: SafeArea(
          child: Column(
            children: [
              // 顶部导航
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '每日计划',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      decoration: colors.circleButtonDecoration(shadowColor: colors.primary),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(12),
                        minSize: 0,
                        child: Icon(CupertinoIcons.calendar, color: colors.primary, size: 22),
                        onPressed: _showDatePicker,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 日期卡片
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: colors.specialCardDecoration(color: colors.cardBg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(CupertinoIcons.calendar_today, color: colors.primary, size: 26),
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
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${planState.plans.length} 个计划',
                              style: TextStyle(color: colors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // 完成进度
                      _buildProgressIndicator(planState.plans, colors),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 计划列表
              Expanded(
                child: planState.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : planState.plans.isEmpty
                        ? _buildEmptyState(colors)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: planState.plans.length,
                            itemBuilder: (ctx, i) {
                              final plan = planState.plans[i];
                              return _PlanTile(
                                plan: plan,
                                colors: colors,
                                onToggle: () async {
                                  HapticService.mediumImpact(); // 完成任务时触觉反馈
                                  await ref.read(planProvider.notifier).togglePlanStatus(plan);
                                  _checkAndScheduleReminder();
                                },
                                onDelete: () async {
                                  await ref.read(planProvider.notifier).deletePlan(plan.id!);
                                  _checkAndScheduleReminder();
                                },
                              );
                            },
                          ),
              ),
              // 添加按钮
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  decoration: colors.buttonDecoration(radius: 12),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: _showAddPlanSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '添加计划',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                        ),
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

  Widget _buildProgressIndicator(List<Plan> plans, AppColors colors) {
    if (plans.isEmpty) return const SizedBox();
    final completed = plans.where((p) => p.isCompleted).length;
    final progress = completed / plans.length;
    
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor: colors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(colors.success),
            ),
          ),
          Text(
            '$completed/${plans.length}',
            style: TextStyle(
              fontSize: 13,
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
              color: colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(CupertinoIcons.doc_text, size: 48, color: colors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            '暂无计划',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加新计划',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: colors.cardDecoration(radius: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 复选框
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: plan.isCompleted ? colors.success : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: plan.isCompleted ? colors.success : colors.textTertiary,
                          width: 2,
                        ),
                      ),
                      child: plan.isCompleted
                          ? const Icon(CupertinoIcons.checkmark, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 内容
                  Expanded(
                    child: Text(
                      plan.content,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                        color: plan.isCompleted ? colors.textTertiary : colors.textPrimary,
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
