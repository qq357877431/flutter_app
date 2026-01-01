import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
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
  
  // 玻璃指示器的动画位置（连续值，用于流畅过渡）
  late AnimationController _indicatorController;
  late Animation<double> _indicatorAnimation;
  double _indicatorPosition = 0;
  
  bool _isDragging = false;
  double _dragStartX = 0;

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
    
    // 指示器动画控制器
    _indicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _indicatorAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  void _animateIndicatorTo(int index) {
    final start = _indicatorPosition;
    final end = index.toDouble();
    
    _indicatorAnimation = Tween<double>(begin: start, end: end).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOutCubic),
    );
    
    _indicatorController.reset();
    _indicatorController.forward();
    
    _indicatorAnimation.addListener(() {
      setState(() {
        _indicatorPosition = _indicatorAnimation.value;
      });
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      HapticService.lightImpact();
      _animateIndicatorTo(index);
      
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
    if (!_isDragging) {
      _animateIndicatorTo(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.localPosition.dx;
    _isDragging = true;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double navWidth) {
    if (!_isDragging) return;
    
    final itemWidth = navWidth / 4;
    final dx = details.localPosition.dx - _dragStartX;
    
    // 拖动时实时更新指示器位置
    final newPosition = (_currentIndex + dx / itemWidth).clamp(0.0, 3.0);
    
    setState(() {
      _indicatorPosition = newPosition;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    
    // 根据指示器位置确定目标索引（超过50%就跳到下一个）
    final targetIndex = _indicatorPosition.round().clamp(0, 3);
    
    if (targetIndex != _currentIndex) {
      HapticService.lightImpact();
      _animateIndicatorTo(targetIndex);
      
      setState(() {
        _currentIndex = targetIndex;
      });
      
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    } else {
      // 回弹到当前位置
      _animateIndicatorTo(_currentIndex);
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
          // iOS 26 风格的 Liquid Glass 导航栏
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding + 12,
            child: _iOS26LiquidGlassNavBar(
              currentIndex: _currentIndex,
              indicatorPosition: _indicatorPosition,
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

/// iOS 26 风格的 Liquid Glass 导航栏
class _iOS26LiquidGlassNavBar extends StatefulWidget {
  final int currentIndex;
  final double indicatorPosition;  // 连续动画值
  final List<_NavItemData> navItems;
  final List<Color> tabColors;
  final AppColors colors;
  final bool isDark;
  final Function(int) onTabTapped;
  final Function(DragStartDetails) onHorizontalDragStart;
  final Function(DragUpdateDetails, double) onHorizontalDragUpdate;
  final Function(DragEndDetails) onHorizontalDragEnd;

  const _iOS26LiquidGlassNavBar({
    required this.currentIndex,
    required this.indicatorPosition,
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
  State<_iOS26LiquidGlassNavBar> createState() => _iOS26LiquidGlassNavBarState();
}

class _iOS26LiquidGlassNavBarState extends State<_iOS26LiquidGlassNavBar> {
  // 当前按下的索引
  int? _pressedIndex;
  // 整个导航栏是否被按下
  bool _isNavBarPressed = false;
  
  // 根据指示器位置计算当前应该高亮的索引
  int get _highlightedIndex => widget.indicatorPosition.round().clamp(0, 3);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final navWidth = constraints.maxWidth;
        final itemWidth = navWidth / 4;
        
        // 整个导航栏按下时放大
        final navBarScale = _isNavBarPressed ? 1.02 : 1.0;
        
        return GestureDetector(
          onHorizontalDragStart: widget.onHorizontalDragStart,
          onHorizontalDragUpdate: (details) => widget.onHorizontalDragUpdate(details, navWidth),
          onHorizontalDragEnd: widget.onHorizontalDragEnd,
          child: AnimatedScale(
            scale: navBarScale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              height: 72,
              child: LiquidGlassLayer(
                settings: LiquidGlassSettings(
                  thickness: 0.8,
                  refractiveIndex: 1.5,
                  blur: 5.0,
                  glassColor: widget.isDark 
                      ? const Color(0x30000000)
                      : const Color(0x28FFFFFF),
                  lightAngle: -0.7,
                  lightIntensity: 0.7,
                ),
                child: LiquidGlassBlendGroup(
                  blend: 18.0,  // 增大融合程度，让过渡更流畅
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: LiquidGlass.grouped(
                          shape: LiquidRoundedSuperellipse(borderRadius: 36),  // 加大圆角
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.isDark 
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(36),
                            ),
                          ),
                        ),
                      ),
                      // 液态滑动指示器（像水滴一样滑动）
                      Positioned(
                        left: widget.indicatorPosition * itemWidth + 8,
                        top: 8,
                        bottom: 8,
                        child: LiquidStretch(
                          stretch: _isNavBarPressed ? 0.7 : 0.35,  // 按下时更多拉伸
                          interactionScale: _isNavBarPressed ? 1.1 : 1.0,  // 按下时向外扩散
                          child: SizedBox(
                            width: itemWidth - 16,
                            child: LiquidGlass.grouped(
                              shape: LiquidRoundedSuperellipse(borderRadius: 26),  // 加大圆角
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      widget.tabColors[_highlightedIndex].withOpacity(widget.isDark ? 0.5 : 0.4),
                                      widget.tabColors[_highlightedIndex].withOpacity(widget.isDark ? 0.3 : 0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(26),
                                ),
                                // 顶部高光
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      height: 14,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(widget.isDark ? 0.18 : 0.45),
                                            Colors.white.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 导航项
                      Positioned.fill(
                        child: Row(
                          children: List.generate(4, (index) {
                            // 判断是否高亮
                            final isHighlighted = _highlightedIndex == index;
                            final item = widget.navItems[index];
                            final color = widget.tabColors[index];
                            
                            return Expanded(
                              child: GestureDetector(
                                onTapDown: (_) {
                                  HapticService.selectionClick();
                                  setState(() {
                                    _pressedIndex = index;
                                    _isNavBarPressed = true;
                                  });
                                },
                                onTapUp: (_) {
                                  setState(() {
                                    _pressedIndex = null;
                                    _isNavBarPressed = false;
                                  });
                                  widget.onTabTapped(index);
                                },
                                onTapCancel: () {
                                  setState(() {
                                    _pressedIndex = null;
                                    _isNavBarPressed = false;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  height: 72,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // 图标
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          isHighlighted ? item.activeIcon : item.icon,
                                          key: ValueKey(isHighlighted),
                                          color: isHighlighted ? color : widget.colors.textTertiary,
                                          size: isHighlighted ? 24 : 22,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // 标签
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          fontSize: isHighlighted ? 10 : 9,
                                          color: isHighlighted ? color : widget.colors.textTertiary,
                                          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                        child: Text(item.label),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
