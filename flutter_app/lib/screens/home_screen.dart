import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'plan_screen.dart';
import 'expense_screen.dart';
import 'water_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final unselectedColor = isDark ? const Color(0xFF8E8E93) : Colors.grey;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          PlanScreen(),
          ExpenseScreen(),
          WaterScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, CupertinoIcons.calendar, CupertinoIcons.calendar_today, '计划', const Color(0xFF667EEA), unselectedColor, isDark),
                _buildNavItem(1, CupertinoIcons.money_dollar_circle, CupertinoIcons.money_dollar_circle_fill, '记账', const Color(0xFF34C759), unselectedColor, isDark),
                _buildNavItem(2, CupertinoIcons.drop, CupertinoIcons.drop_fill, '喝水', const Color(0xFF007AFF), unselectedColor, isDark),
                _buildNavItem(3, CupertinoIcons.gear, CupertinoIcons.gear_solid, '设置', const Color(0xFFFF9500), unselectedColor, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, Color color, Color unselectedColor, bool isDark) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(isDark ? 0.2 : 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? color : unselectedColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? color : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
