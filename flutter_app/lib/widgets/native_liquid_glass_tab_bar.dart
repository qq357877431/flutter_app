import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS 26 Native Liquid Glass Tab Bar using overlay window
/// Uses native UIWindow overlay for TRUE transparency
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
  static const _overlayChannel = MethodChannel('liquid_glass_overlay');
  bool _isOverlayShown = false;

  @override
  void initState() {
    super.initState();
    _setupMethodChannel();
    _showOverlay();
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _setupMethodChannel() {
    _overlayChannel.setMethodCallHandler((call) async {
      if (call.method == 'onTabChanged') {
        final args = call.arguments as Map<Object?, Object?>;
        final index = args['index'] as int;
        widget.onTabChanged(index);
      }
    });
  }

  Future<void> _showOverlay() async {
    if (!Platform.isIOS) return;
    
    try {
      await _overlayChannel.invokeMethod('show', {
        'initialTab': widget.currentIndex,
      });
      _isOverlayShown = true;
    } catch (e) {
      debugPrint('Failed to show overlay: $e');
    }
  }

  Future<void> _hideOverlay() async {
    if (!Platform.isIOS || !_isOverlayShown) return;
    
    try {
      await _overlayChannel.invokeMethod('hide');
      _isOverlayShown = false;
    } catch (e) {
      debugPrint('Failed to hide overlay: $e');
    }
  }

  @override
  void didUpdateWidget(NativeLiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Sync tab index from Flutter to native
    if (oldWidget.currentIndex != widget.currentIndex && _isOverlayShown) {
      _overlayChannel.invokeMethod('setTab', {'index': widget.currentIndex});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container - actual tab bar is in native overlay window
    // This widget just handles communication
    if (Platform.isIOS) {
      return SizedBox(height: widget.height);
    }
    
    // Fallback for non-iOS
    return _FallbackTabBar(
      currentIndex: widget.currentIndex,
      onTabChanged: widget.onTabChanged,
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
