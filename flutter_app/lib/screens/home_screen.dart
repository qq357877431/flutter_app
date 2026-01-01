import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../services/haptic_service.dart';
import '../widgets/native_liquid_glass_tab_bar.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticService.lightImpact();
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Check if we're on iOS and can use native tab bar
    final useNativeTabBar = Platform.isIOS;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      extendBody: true,
      body: Stack(
        children: [
          // 页面内容
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              PlanScreen(),
              ExpenseScreen(),
              WaterScreen(),
              SettingsScreen(),
            ],
          ),
          
          // iOS 26 原生 Liquid Glass 导航栏
          if (useNativeTabBar)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NativeLiquidGlassTabBar(
                currentIndex: _currentIndex,
                onTabChanged: _onTabTapped,
                height: 80 + bottomPadding,
              ),
            )
          else
            // 非 iOS 平台使用 Flutter 实现的导航栏
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPadding + 12,
              child: _FlutterLiquidGlassNavBar(
                currentIndex: _currentIndex,
                colors: colors,
                isDark: isDark,
                onTabTapped: _onTabTapped,
              ),
            ),
        ],
      ),
    );
  }
}

/// Flutter 实现的 Liquid Glass 导航栏（用于非 iOS 平台）
class _FlutterLiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final AppColors colors;
  final bool isDark;
  final Function(int) onTabTapped;

  const _FlutterLiquidGlassNavBar({
    required this.currentIndex,
    required this.colors,
    required this.isDark,
    required this.onTabTapped,
  });

  static const _navItems = [
    ('计划', CupertinoIcons.calendar, CupertinoIcons.calendar_today),
    ('记账', CupertinoIcons.money_dollar_circle, CupertinoIcons.money_dollar_circle_fill),
    ('喝水', CupertinoIcons.drop, CupertinoIcons.drop_fill),
    ('设置', CupertinoIcons.gear, CupertinoIcons.gear_solid),
  ];

  @override
  Widget build(BuildContext context) {
    final tabColors = [colors.primary, colors.green, colors.blue, colors.orange];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withOpacity(0.4)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            children: List.generate(4, (index) {
              final isSelected = currentIndex == index;
              final item = _navItems[index];
              final color = tabColors[index];

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTabTapped(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 72,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.$3 : item.$2,
                          color: isSelected ? color : colors.textTertiary,
                          size: isSelected ? 24 : 22,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$1,
                          style: TextStyle(
                            fontSize: isSelected ? 10 : 9,
                            color: isSelected ? color : colors.textTertiary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
