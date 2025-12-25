import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/colors.dart';
import '../services/haptic_service.dart';
import 'plan_screen.dart';
import 'expense_screen.dart';
import 'water_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  
  double _dragStartX = 0;
  double _liquidPosition = 0;
  bool _isDragging = false;

  final List<_NavItemData> _navItems = [
    _NavItemData('计划', CupertinoIcons.calendar, CupertinoIcons.calendar_today),
    _NavItemData('记账', CupertinoIcons.money_dollar_circle, CupertinoIcons.money_dollar_circle_fill),
    _NavItemData('喝水', CupertinoIcons.drop, CupertinoIcons.drop_fill),
    _NavItemData('设置', CupertinoIcons.gear, CupertinoIcons.gear_solid),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _liquidPosition = _currentIndex.toDouble();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticService.lightImpact(); // 切换菜单时触觉反馈
      setState(() {
        _currentIndex = index;
        _liquidPosition = index.toDouble();
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _liquidPosition = index.toDouble();
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _isDragging = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double navWidth) {
    if (!_isDragging) return;
    
    final itemWidth = navWidth / 4;
    final dx = details.localPosition.dx - _dragStartX;
    final newPosition = (_currentIndex + dx / itemWidth).clamp(0.0, 3.0);
    
    setState(() {
      _liquidPosition = newPosition;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final targetIndex = _liquidPosition.round().clamp(0, 3);
    
    if (targetIndex != _currentIndex) {
      _onTabTapped(targetIndex);
    } else {
      setState(() {
        _liquidPosition = _currentIndex.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = AppColors(isDark);
    final tabColors = [colors.primary, colors.green, colors.blue, colors.orange];
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
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
          // 浮动导航栏
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPadding + 16,
            child: _LiquidGlassNavBar(
              currentIndex: _currentIndex,
              liquidPosition: _liquidPosition,
              navItems: _navItems,
              tabColors: tabColors,
              colors: colors,
              isDark: isDark,
              onTabTapped: _onTabTapped,
              onHorizontalDragStart: _onHorizontalDragStart,
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  
  _NavItemData(this.label, this.icon, this.activeIcon);
}

class _LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final double liquidPosition;
  final List<_NavItemData> navItems;
  final List<Color> tabColors;
  final AppColors colors;
  final bool isDark;
  final Function(int) onTabTapped;
  final Function(DragStartDetails) onHorizontalDragStart;
  final Function(DragUpdateDetails, double) onHorizontalDragUpdate;
  final Function(DragEndDetails) onHorizontalDragEnd;

  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.liquidPosition,
    required this.navItems,
    required this.tabColors,
    required this.colors,
    required this.isDark,
    required this.onTabTapped,
    required this.onHorizontalDragStart,
    required this.onHorizontalDragUpdate,
    required this.onHorizontalDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            // 毛玻璃效果：半透明背景
            color: isDark 
                ? Colors.black.withOpacity(0.4)
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withOpacity(0.15)
                  : Colors.white.withOpacity(0.8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final navWidth = constraints.maxWidth;
              final itemWidth = navWidth / 4;
              
              return GestureDetector(
                onHorizontalDragStart: onHorizontalDragStart,
                onHorizontalDragUpdate: (details) => onHorizontalDragUpdate(details, navWidth),
                onHorizontalDragEnd: onHorizontalDragEnd,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 液态玻璃指示器 - 包裹整个菜单项
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: liquidPosition * itemWidth + 6,
                      top: 6,
                      bottom: 6,
                      child: _LiquidIndicator(
                        width: itemWidth - 12,
                        color: tabColors[liquidPosition.round().clamp(0, 3)],
                        isDark: isDark,
                      ),
                    ),
                    // 导航项
                    Row(
                      children: List.generate(4, (index) {
                        final isSelected = currentIndex == index;
                        final item = navItems[index];
                        final color = tabColors[index];
                        
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => onTabTapped(index),
                            behavior: HitTestBehavior.opaque,
                            child: _NavItem(
                              icon: item.icon,
                              activeIcon: item.activeIcon,
                              label: item.label,
                              isSelected: isSelected,
                              color: color,
                              colors: colors,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LiquidIndicator extends StatelessWidget {
  final double width;
  final Color color;
  final bool isDark;

  const _LiquidIndicator({
    required this.width,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(isDark ? 0.35 : 0.25),
            color.withOpacity(isDark ? 0.2 : 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.5 : 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(isDark ? 0.15 : 0.5),
                  Colors.white.withOpacity(isDark ? 0.05 : 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color color;
  final AppColors colors;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            isSelected ? activeIcon : icon,
            key: ValueKey(isSelected),
            color: isSelected ? color : colors.textTertiary,
            size: isSelected ? 26 : 22,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: isSelected ? 11 : 10,
            color: isSelected ? color : colors.textTertiary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
