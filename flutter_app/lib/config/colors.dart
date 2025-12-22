import 'package:flutter/material.dart';

/// App 颜色配置 - 参考 OKX 设计风格
class AppColors {
  final bool isDark;
  
  AppColors(this.isDark);
  
  // 主色调 - 金色/黄色 (OKX 风格)
  static const Color okxYellow = Color(0xFFF7931A);
  static const Color okxGold = Color(0xFFFFD700);
  
  // 背景色
  Color get scaffoldBg => isDark 
      ? const Color(0xFF0D0D0D)  // 纯黑背景
      : const Color(0xFFF5F5F7);
  
  Color get cardBg => isDark 
      ? const Color(0xFF1A1A1A)  // 深灰卡片
      : Colors.white;
  
  Color get cardBgSecondary => isDark 
      ? const Color(0xFF242424)  // 次级卡片
      : const Color(0xFFF8F8F8);
  
  // 文字颜色
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get textSecondary => isDark ? const Color(0xFF8E8E93) : const Color(0xFF666666);
  Color get textTertiary => isDark ? const Color(0xFF5C5C5C) : const Color(0xFF999999);
  
  // 分割线
  Color get divider => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE5E5E5);
  
  // 马兰花色渐变 (计划页面)
  List<Color> get primaryGradient => isDark
      ? [const Color(0xFF5A6FCC), const Color(0xFF7C5BAD)]
      : [const Color(0xFF667EEA), const Color(0xFF764BA2)];
  
  // 绿色渐变 (记账页面) - 更鲜艳
  List<Color> get greenGradient => isDark
      ? [const Color(0xFF00C853), const Color(0xFF00BFA5)]
      : [const Color(0xFF00E676), const Color(0xFF1DE9B6)];
  
  // 蓝色渐变 (喝水页面)
  List<Color> get blueGradient => isDark
      ? [const Color(0xFF2196F3), const Color(0xFF00BCD4)]
      : [const Color(0xFF42A5F5), const Color(0xFF26C6DA)];
  
  // 红色渐变 (删除/支出)
  List<Color> get redGradient => isDark
      ? [const Color(0xFFE53935), const Color(0xFFFF5252)]
      : [const Color(0xFFFF5252), const Color(0xFFFF8A80)];
  
  // 橙色/金色渐变 (OKX 风格)
  List<Color> get goldGradient => isDark
      ? [const Color(0xFFF7931A), const Color(0xFFFFB74D)]
      : [const Color(0xFFFF9800), const Color(0xFFFFCA28)];
  
  // 紫色渐变
  List<Color> get purpleGradient => isDark
      ? [const Color(0xFF7C4DFF), const Color(0xFFB388FF)]
      : [const Color(0xFF9C27B0), const Color(0xFFE040FB)];
  
  // 分类颜色 - 更现代的配色
  Map<String, List<Color>> get categoryColors => {
    '餐饮': isDark 
        ? [const Color(0xFFFF9800), const Color(0xFFFFB74D)]
        : [const Color(0xFFFF9800), const Color(0xFFFFCA28)],
    '交通': isDark
        ? [const Color(0xFF2196F3), const Color(0xFF64B5F6)]
        : [const Color(0xFF42A5F5), const Color(0xFF90CAF9)],
    '购物': isDark
        ? [const Color(0xFFE91E63), const Color(0xFFF48FB1)]
        : [const Color(0xFFEC407A), const Color(0xFFF8BBD9)],
    '娱乐': isDark
        ? [const Color(0xFF7C4DFF), const Color(0xFFB388FF)]
        : [const Color(0xFF9C27B0), const Color(0xFFCE93D8)],
    '其他': isDark
        ? [const Color(0xFF607D8B), const Color(0xFF90A4AE)]
        : [const Color(0xFF78909C), const Color(0xFFB0BEC5)],
  };
  
  // 单色
  Color get primary => isDark ? const Color(0xFF667EEA) : const Color(0xFF5C6BC0);
  Color get green => isDark ? const Color(0xFF00C853) : const Color(0xFF00E676);
  Color get blue => isDark ? const Color(0xFF2196F3) : const Color(0xFF42A5F5);
  Color get red => isDark ? const Color(0xFFE53935) : const Color(0xFFFF5252);
  Color get orange => isDark ? const Color(0xFFF7931A) : const Color(0xFFFF9800);
  Color get gold => const Color(0xFFF7931A);
  
  // 成功/警告/错误
  Color get success => const Color(0xFF00C853);
  Color get warning => const Color(0xFFFFB300);
  Color get error => const Color(0xFFFF5252);
  
  // 阴影透明度
  double get shadowOpacity => isDark ? 0.3 : 0.15;
  
  // 获取渐变装饰
  BoxDecoration gradientDecoration(List<Color> colors, {double radius = 16}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: colors.first.withOpacity(shadowOpacity),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
  
  // 玻璃态效果装饰
  BoxDecoration glassDecoration({double radius = 16}) {
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withOpacity(0.05)
          : Colors.white.withOpacity(0.7),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark 
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.5),
      ),
    );
  }
  
  // 卡片装饰
  BoxDecoration cardDecoration({double radius = 16, Color? color}) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: BorderRadius.circular(radius),
      border: isDark ? Border.all(color: const Color(0xFF2C2C2C), width: 1) : null,
      boxShadow: isDark ? null : [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
