import 'package:flutter/material.dart';

/// App 颜色配置 - 参考 Best Flutter UI Templates 风格
class AppColors {
  final bool isDark;
  
  AppColors(this.isDark);
  
  // 主色调
  static const Color primaryBlue = Color(0xFF2633C5);
  static const Color accentBlue = Color(0xFF00B6F0);
  
  // 背景色
  Color get scaffoldBg => isDark 
      ? const Color(0xFF1A1A2E)
      : const Color(0xFFF2F3F8);
  
  Color get cardBg => isDark 
      ? const Color(0xFF252542)
      : Colors.white;
  
  Color get cardBgSecondary => isDark 
      ? const Color(0xFF2D2D4A)
      : const Color(0xFFF8F9FC);
  
  // 文字颜色
  Color get textPrimary => isDark 
      ? const Color(0xFFFAFAFA) 
      : const Color(0xFF253840);
  
  Color get textSecondary => isDark 
      ? const Color(0xFF8E8E93) 
      : const Color(0xFF4A6572);
  
  Color get textTertiary => isDark 
      ? const Color(0xFF636366) 
      : const Color(0xFF767676);
  
  // 分割线
  Color get divider => isDark 
      ? const Color(0xFF3A3A5C) 
      : const Color(0xFFE8E8E8);
  
  // 主色 - 深色模式下变暗
  Color get primary => isDark 
      ? const Color(0xFF4A5A9E) 
      : const Color(0xFF5B6FD6);
  
  Color get accent => isDark 
      ? const Color(0xFF4A9AC8) 
      : const Color(0xFF5AC8FA);
  
  // 功能色
  Color get success => const Color(0xFF34C759);
  Color get warning => const Color(0xFFFF9500);
  Color get error => const Color(0xFFFF3B30);
  
  // 绿色（记账）- 深色模式下变暗
  Color get green => isDark 
      ? const Color(0xFF2E8B4A) 
      : const Color(0xFF52D96A);
  
  // 蓝色（喝水）- 深色模式下变暗
  Color get blue => isDark 
      ? const Color(0xFF3A8AB8) 
      : const Color(0xFF5AC8FA);
  
  // 红色（删除/支出）- 深色模式下变暗
  Color get red => isDark 
      ? const Color(0xFFB84A4A) 
      : const Color(0xFFFF6B6B);
  
  // 橙色 - 深色模式下变暗
  Color get orange => isDark 
      ? const Color(0xFFCC7A00) 
      : const Color(0xFFFF9500);
  
  // 阴影透明度
  double get shadowOpacity => isDark ? 0.3 : 0.15;

  // 玻璃拟态颜色
  Color get glassColor => isDark 
      ? const Color(0xCC000000) 
      : const Color(0xCCFFFFFF);
      
  Color get glassBorder => isDark 
      ? Colors.white.withOpacity(0.1) 
      : Colors.black.withOpacity(0.08);
  
  // 渐变色 - 深色模式下颜色变暗
  List<Color> get primaryGradient => isDark 
      ? [const Color(0xFF4A5A9E), const Color(0xFF5A7AB8)]
      : [const Color(0xFF6B7FE6), const Color(0xFF8BB8F8)];
  
  List<Color> get greenGradient => isDark 
      ? [const Color(0xFF2E8B4A), const Color(0xFF3DA85E)]
      : [const Color(0xFF52D96A), const Color(0xFF7AE8A0)];
  
  List<Color> get blueGradient => isDark 
      ? [const Color(0xFF3A8AB8), const Color(0xFF4A9AC8)]
      : [const Color(0xFF5AC8FA), const Color(0xFF8DD8FF)];
  
  List<Color> get redGradient => isDark 
      ? [const Color(0xFFB84A4A), const Color(0xFFC85A5A)]
      : [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)];
  
  // 分类颜色
  Map<String, List<Color>> get categoryColors => {
    '餐饮': [const Color(0xFFFF9500), const Color(0xFFFF9F0A)],
    '交通': [const Color(0xFF00B6F0), const Color(0xFF5AC8FA)],
    '购物': [const Color(0xFFFF2D55), const Color(0xFFFF375F)],
    '娱乐': [const Color(0xFFAF52DE), const Color(0xFFBF5AF2)],
    '其他': [const Color(0xFF8E8E93), const Color(0xFFA8A8AD)],
  };
  
  // 阴影
  List<BoxShadow> get cardShadow => isDark ? [] : [
    BoxShadow(
      color: const Color(0xFF3A5160).withOpacity(0.1),
      offset: const Offset(1.1, 1.1),
      blurRadius: 10.0,
    ),
  ];
  
  // 卡片装饰
  BoxDecoration cardDecoration({double radius = 8, Color? color}) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
  }
  
  // 统一圆角卡片（四周圆角）
  BoxDecoration specialCardDecoration({Color? color, double radius = 16}) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: cardShadow,
    );
  }
  
  // 按钮装饰 - 使用渐变
  BoxDecoration buttonDecoration({Color? color, double radius = 8, List<Color>? gradient}) {
    final gradientColors = gradient ?? primaryGradient;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: color != null ? [color, color.withOpacity(0.8)] : gradientColors,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: (color ?? gradientColors.first).withOpacity(0.25),
          offset: const Offset(0, 4),
          blurRadius: 8.0,
        ),
      ],
    );
  }
  
  // 圆形按钮装饰
  BoxDecoration circleButtonDecoration({Color? bgColor, Color? shadowColor}) {
    return BoxDecoration(
      color: bgColor ?? (isDark ? const Color(0xFF252542) : const Color(0xFFFAFAFA)),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? primary).withOpacity(0.3),
          offset: const Offset(4.0, 4.0),
          blurRadius: 8.0,
        ),
      ],
    );
  }
  
  // 渐变装饰
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
}
