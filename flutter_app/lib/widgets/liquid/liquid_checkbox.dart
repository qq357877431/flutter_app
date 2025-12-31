import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color activeColor;

  const LiquidCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: 24,
        height: 24,
        child: LiquidStretch(
          stretch: value ? 0.2 : 0.0,
          interactionScale: value ? 1.1 : 1.0,
          child: LiquidGlassLayer(
            settings: LiquidGlassSettings(
              thickness: 0.3,
              blur: 2,
              refractiveIndex: 1.1,
              glassColor: value ? activeColor.withOpacity(0.8) : Colors.transparent,
              lightIntensity: 0.3,
            ),
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: value ? activeColor : Colors.grey.withOpacity(0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: value
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
