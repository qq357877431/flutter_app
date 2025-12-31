import '../config/colors.dart'; // Add import

// ...

    final colors = AppColors(isDark); // Get colors

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: 24),
        settings: LiquidGlassSettings(
          thickness: 0.5,
          blur: 10,
          refractiveIndex: 1.2,
          glassColor: colors.glassColor.withOpacity(isDark ? 0.1 : 0.25),
          lightIntensity: 0.4,
          lightAngle: -0.5,
        ),
        child: content,
      ),
    );
  }
}
