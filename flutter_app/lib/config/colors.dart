import 'package:flutter/material.dart';

/// App 颜色配置 - 支持深色模式
class AppColors {
  final bool isDark;
  
  AppColors(this.isDark);
  
  // 马兰花色渐变 (计划页面)
  List<Color> get primaryGradient => isDark
      ? [const Color(0xFF4A5899), const Color(0xFF5A3D7A)]  // 暗色调
      : [const Color(0xFF667EEA), const Color(0xFF764BA2)]; // 亮色调
  
  // 绿色渐变 (记账页面)
  List<Color> get greenGradient => isDark
      ? [const Color(0xFF2D8B57), const Color(0xFF2A9D8F)]  // 暗色调
      : [const Color(0xFF43E97B), const Color(0xFF38F9D7)]; // 亮色调
  
  // 蓝色渐变 (喝水页面)
  List<Color> get blueGradient => isDark
      ? [const Color(0xFF0055AA), const Color(0xFF3A8FBF)]  // 暗色调
      : [const Color(0xFF007AFF), const Color(0xFF5AC8FA)]; // 亮色调
  
  // 红色渐变 (删除/错误)
  List<Color> get redGradient => isDark
      ? [const Color(0xFFCC4444), const Color(0xFFBB5555)]  // 暗色调
      : [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]; // 亮色调
  
  // 橙色渐变
  List<Color> get orangeGradient => isDark
      ? [const Color(0xFFCC7700), const Color(0xFFBB8833)]  // 暗色调
      : [const Color(0xFFFF9500), const Color(0xFFFFB347)]; // 亮色调
  
  // 分类颜色
  Map<String, List<Color>> get categoryColors => {
    '餐饮': isDark 
        ? [const Color(0xFFCC7700), const Color(0xFFBB8833)]
        : [const Color(0xFFFF9500), const Color(0xFFFFB347)],
    '交通': isDark
        ? [const Color(0xFF3388CC), const Color(0xFF00AAAA)]
        : [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    '购物': isDark
        ? [const Color(0xFFCC5577), const Color(0xFFBBAA33)]
        : [const Color(0xFFFA709A), const Color(0xFFFEE140)],
    '娱乐': isDark
        ? [const Color(0xFF4A5899), const Color(0xFF5A3D7A)]
        : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    '其他': isDark
        ? [const Color(0xFF666666), const Color(0xFF777777)]
        : [const Color(0xFF8E8E93), const Color(0xFFAEAEB2)],
  };
  
  // 单色
  Color get primary => isDark ? const Color(0xFF5A6FCC) : const Color(0xFF667EEA);
  Color get green => isDark ? const Color(0xFF2D8B57) : const Color(0xFF43E97B);
  Color get blue => isDark ? const Color(0xFF0055AA) : const Color(0xFF007AFF);
  Color get red => isDark ? const Color(0xFFCC4444) : const Color(0xFFFF6B6B);
  Color get orange => isDark ? const Color(0xFFCC7700) : const Color(0xFFFF9500);
  
  // 阴影透明度
  double get shadowOpacity => isDark ? 0.15 : 0.4;
  
  // 获取渐变装饰
  BoxDecoration gradientDecoration(List<Color> colors, {double radius = 14}) {
    return BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(shadowOpacity),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
