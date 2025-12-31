import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../config/colors.dart';

class LiquidHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final bool isDark;
  final List<Widget>? trailing;
  final double expandedHeight;

  LiquidHeader({
    required this.title,
    required this.isDark,
    this.trailing,
    this.expandedHeight = 120.0,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = shrinkOffset / maxExtent;
    final isCollapsed = progress > 0.5;
    final colors = AppColors(isDark);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Glass Background
        LiquidGlassLayer(
          settings: LiquidGlassSettings(
            thickness: 0.5,
            blur: 15 + (progress * 10), // Increase blur on scroll
            refractiveIndex: 1.2,
            glassColor: colors.glassColor.withOpacity(progress * 0.8),
            lightIntensity: 0.2,
          ),
          child: LiquidGlass(
            shape: LiquidRoundedSuperellipse(borderRadius: 0), // Rectangle
            child: Container(),
          ),
        ),

        // Title
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20 + (progress * 0), // Keep left alignment or animate
              bottom: 16,
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isCollapsed ? 20 : 34,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
              child: Text(title),
            ),
          ),
        ),

        // Trailing Actions
        if (trailing != null)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: trailing!,
              ),
            ),
          ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top;

  @override
  bool shouldRebuild(covariant LiquidHeader oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.isDark != isDark ||
        oldDelegate.trailing != trailing;
  }
}
