import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS 26 Native Liquid Glass Tab Bar
/// Uses native SwiftUI TabView with glassEffect on iOS 26+
/// Falls back to Flutter implementation on other platforms
class NativeLiquidGlassTabBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final double height;

  const NativeLiquidGlassTabBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    this.height = 80,
  });

  @override
  State<NativeLiquidGlassTabBar> createState() => _NativeLiquidGlassTabBarState();
}

class _NativeLiquidGlassTabBarState extends State<NativeLiquidGlassTabBar> {
  MethodChannel? _channel;
  int _viewId = 0;

  @override
  void didUpdateWidget(NativeLiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync tab index from Flutter to native
    if (oldWidget.currentIndex != widget.currentIndex && _channel != null) {
      _channel!.invokeMethod('setTab', {'index': widget.currentIndex});
    }
  }

  void _onPlatformViewCreated(int viewId) {
    _viewId = viewId;
    _channel = MethodChannel('liquid_glass_tab_bar_$viewId');
    
    _channel!.setMethodCallHandler((call) async {
      if (call.method == 'onTabChanged') {
        final args = call.arguments as Map<Object?, Object?>;
        final index = args['index'] as int;
        widget.onTabChanged(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Only use native view on iOS
    if (!Platform.isIOS) {
      return _FallbackTabBar(
        currentIndex: widget.currentIndex,
        onTabChanged: widget.onTabChanged,
      );
    }

    return SizedBox(
      height: widget.height,
      child: UiKitView(
        viewType: 'liquid_glass_tab_bar',
        creationParams: {
          'initialTab': widget.currentIndex,
        },
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}

/// Fallback tab bar for non-iOS platforms
class _FallbackTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const _FallbackTabBar({
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 72,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTab(0, Icons.calendar_today, '计划'),
          _buildTab(1, Icons.attach_money, '记账'),
          _buildTab(2, Icons.water_drop, '喝水'),
          _buildTab(3, Icons.settings, '设置'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTabChanged(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: isSelected ? 24 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
