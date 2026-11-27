import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Atmospheric sci-fi space and interdimensional portal background layer.
class PortalBackground extends StatefulWidget {
  const PortalBackground({
    super.key,
    required this.child,
    this.showPortalGlow = true,
  });

  final Widget child;
  final bool showPortalGlow;

  @override
  State<PortalBackground> createState() => _PortalBackgroundState();
}

class _PortalBackgroundState extends State<PortalBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.8),
                radius: 1.4,
                colors: [
                  Color(0xFF102027),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),
        if (widget.showPortalGlow)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _SpaceAtmospherePainter(
                        progress: _controller.value,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _SpaceAtmospherePainter extends CustomPainter {
  _SpaceAtmospherePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle glowing cosmic nebulae
    final greenGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryNeonGreen.withValues(alpha: 0.11),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.15),
          radius: math.max(size.width, size.height) * 0.4,
        ),
      );
    canvas.drawRect(Offset.zero & size, greenGlow);

    final purpleGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.purple.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.82),
          radius: math.max(size.width, size.height) * 0.42,
        ),
      );
    canvas.drawRect(Offset.zero & size, purpleGlow);

    // Subtle procedural starfield
    final starPaint = Paint()..style = PaintingStyle.fill;
    const starCount = 38;
    for (var i = 0; i < starCount; i++) {
      final seedX = ((i * 73 + 19) % 100) / 100.0;
      final seedY = ((i * 137 + 41) % 100) / 100.0;
      final twinkle =
          0.25 + 0.55 * (0.5 + 0.5 * math.sin((progress * 2 * math.pi) + i));
      final color = i % 5 == 0
          ? AppColors.cyan
          : (i % 7 == 0 ? AppColors.primaryNeonGreen : AppColors.mainText);
      starPaint.color = color.withValues(alpha: twinkle * 0.45);
      final radius = (i % 3 == 0) ? 1.6 : 1.0;
      canvas.drawCircle(
        Offset(size.width * seedX, size.height * seedY),
        radius,
        starPaint,
      );
    }

    // Subtle sci-fi lab grid lines
    final gridPaint = Paint()
      ..color = AppColors.cyan.withValues(alpha: 0.028)
      ..strokeWidth = 1;
    const step = 72.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
