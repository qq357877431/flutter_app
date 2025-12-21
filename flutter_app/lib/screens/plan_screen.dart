import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/colors.dart';
import '../models/plan.dart';
import '../providers/plan_provider.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(planProvider.notifier).loadPlans());
  }

  void _showAddPlanSheet() {
    final controller = TextEditingController();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FF), Color(0xFFF0F4FF)],
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
              shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]).createShader(b),
              child: const Text('添加新计划', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: CupertinoTextField(
                controller: controller,
                placeholder: '输入计划内容...',
                padding: const EdgeInsets.all(16),
                maxLines: 3,
                autofocus: true,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF667EEA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text('取消', style: TextStyle(color: Color(0xFF667EEA))),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: const Color(0xFF667EEA).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const Text('添加', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          await ref.read(planProvider.notifier).createPlan(controller.text);
                          if (mounted) Navigator.pop(ctx);
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
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: CupertinoColors.separator.resolveFrom(ctx)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
                  CupertinoButton(child: const Text('确定'), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: planState.selectedDate,
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (date) => ref.read(planProvider.notifier).setSelectedDate(date),
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
    final bgColors = isDark 
        ? [const Color(0xFF1C1C1E), const Color(0xFF1C1C1E), const Color(0xFF1C1C1E)]
        : [const Color(0xFFF0F4FF), const Color(0xFFFAFBFF), Colors.white];
    final textColor = isDark ? Colors.white : Colors.grey[800];

    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 自定义导航栏
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (b) => LinearGradient(colors: colors.primaryGradient).createShader(b),
                      child: const Text('每日计划', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Container(
                      decoration: colors.gradientDecoration(colors.primaryGradient, radius: 12),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(10),
                        minSize: 0,
                        child: const Icon(CupertinoIcons.calendar, color: Colors.white, size: 20),
                        onPressed: _showDatePicker,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 日期卡片
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: colors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: colors.primaryGradient.first.withOpacity(colors.shadowOpacity), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(CupertinoIcons.calendar_today, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateFormat.format(planState.selectedDate), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('${planState.plans.length} 个计划', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 计划列表
              Expanded(
                child: planState.isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : planState.plans.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [colors.primaryGradient.first.withOpacity(0.1), colors.primaryGradient.last.withOpacity(0.1)]),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: ShaderMask(
                                    shaderCallback: (b) => LinearGradient(colors: colors.primaryGradient).createShader(b),
                                    child: const Icon(CupertinoIcons.doc_text, size: 48, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ShaderMask(
                                  shaderCallback: (b) => LinearGradient(colors: colors.primaryGradient).createShader(b),
                                  child: const Text('暂无计划', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                                ),
                                const SizedBox(height: 6),
                                Text('点击下方按钮添加', style: TextStyle(color: isDark ? const Color(0xFF8E8E93) : Colors.grey[500], fontSize: 14)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: planState.plans.length,
                            itemBuilder: (ctx, i) {
                              final plan = planState.plans[i];
                              return _PlanTile(
                                plan: plan,
                                isDark: isDark,
                                colors: colors,
                                onToggle: () => ref.read(planProvider.notifier).togglePlanStatus(plan),
                                onDelete: () => ref.read(planProvider.notifier).deletePlan(plan.id!),
                              );
                            },
                          ),
              ),
              // 添加按钮
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: colors.gradientDecoration(colors.primaryGradient),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: _showAddPlanSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.add, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('添加计划', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
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

class _PlanTile extends StatelessWidget {
  final Plan plan;
  final bool isDark;
  final AppColors colors;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PlanTile({required this.plan, required this.isDark, required this.colors, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cardBgColors = isDark
        ? (plan.isCompleted 
            ? [const Color(0xFF1E3A2F), const Color(0xFF1E3A2F)]
            : [const Color(0xFF2C2C2E), const Color(0xFF2C2C2E)])
        : (plan.isCompleted
            ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
            : [Colors.white, const Color(0xFFF8FAFF)]);
    final textColor = isDark 
        ? (plan.isCompleted ? const Color(0xFF8E8E93) : Colors.white)
        : (plan.isCompleted ? Colors.grey[500] : Colors.grey[800]);
    final checkGradient = colors.greenGradient;
    final borderColor = colors.primary;
    
    return Dismissible(
      key: Key(plan.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors.redGradient),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(CupertinoIcons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardBgColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (plan.isCompleted ? colors.green : colors.primary).withOpacity(colors.shadowOpacity * 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        gradient: plan.isCompleted ? LinearGradient(colors: checkGradient) : null,
                        color: plan.isCompleted ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: plan.isCompleted ? Colors.transparent : borderColor, width: 2),
                        boxShadow: plan.isCompleted ? [BoxShadow(color: checkGradient.first.withOpacity(colors.shadowOpacity), blurRadius: 8, offset: const Offset(0, 3))] : null,
                      ),
                      child: plan.isCompleted ? const Icon(CupertinoIcons.checkmark, size: 18, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      plan.content,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                        color: textColor,
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
