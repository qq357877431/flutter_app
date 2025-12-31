import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../../config/colors.dart';

class LiquidCard extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;

  const LiquidCard({
    super.key,
    required this.child,
    required this.isDark,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(isDark);
    
    Widget content = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: content,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          thickness: 0.5,
          blur: 10,
          refractiveIndex: 1.2,
          glassColor: colors.glassColor.withOpacity(isDark ? 0.1 : 0.25),
          lightIntensity: 0.4,
          lightAngle: -0.5,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedSuperellipse(borderRadius: 24),
          child: Container(
            decoration: BoxDecoration(
              border: borderColor != null 
                  ? Border.all(color: borderColor!, width: 1.5) 
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}
