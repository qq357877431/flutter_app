import 'dart:ui';
import 'package:flutter/material.dart';

class FluidBackground extends StatefulWidget {
  final Widget? child;
  final bool isDark;

  const FluidBackground({
    super.key,
    this.child,
    required this.isDark,
  });

  @override
  State<FluidBackground> createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<FluidBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 定义流体颜色
    final colors = widget.isDark
        ? [
            const Color(0xFF1A237E), // Deep Indigo
            const Color(0xFF311B92), // Deep Purple
            const Color(0xFF006064), // Cyan Dark
          ]
        : [
            const Color(0xFFE3F2FD), // Blue 50
            const Color(0xFFF3E5F5), // Purple 50
            const Color(0xFFE0F7FA), // Cyan 50
          ];

    return Stack(
      children: [
        // 基础背景色
        Container(color: widget.isDark ? const Color(0xFF050505) : const Color(0xFFFAFAFA)),
        
        // 动态光斑 1
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: -100 + 50 * _controller.value,
              left: -100 + 30 * _controller.value,
              child: _buildBlob(colors[0], 400),
            );
          },
        ),

        // 动态光斑 2
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: 200 - 40 * _controller.value,
              right: -150 + 40 * _controller.value,
              child: _buildBlob(colors[1], 350),
            );
          },
        ),

        // 动态光斑 3
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              bottom: -100 + 60 * _controller.value,
              left: 50 - 20 * _controller.value,
              child: _buildBlob(colors[2], 450),
            );
          },
        ),

        // 全局高斯模糊，融合光斑
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent),
        ),

        // 内容
        if (widget.child != null) widget.child!,
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.4),
      ),
    );
  }
}
