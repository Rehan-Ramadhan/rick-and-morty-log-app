import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_routing.dart';
import '../../widgets/portal_background.dart';

/// Animated interdimensional portal splash screen validating stored Sanctum session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _portalController;
  String _statusText = 'Initializing portal coordinates...';

  @override
  void initState() {
    super.initState();
    _portalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _bootstrapSession();
  }

  Future<void> _bootstrapSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _statusText = 'Verifying Citadel access token...');

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.checkAuthStatus();

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      isAuthenticated ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _portalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: PortalBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 176,
                    height: 176,
                    child: AnimatedBuilder(
                      animation: _portalController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _PortalVortexPainter(
                            progress: _portalController.value,
                          ),
                          child: child,
                        );
                      },
                      child: Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background.withValues(alpha: 0.72),
                            border: Border.all(
                              color: AppColors.primaryNeonGreen,
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryNeonGreen.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: AppColors.primaryNeonGreen,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.75, 0.75),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 450.ms),
                  const SizedBox(height: 32),
                  Text(
                    'RICK & MORTY LOG',
                    textAlign: TextAlign.center,
                    style: textTheme.displayMedium?.copyWith(
                      color: AppColors.mainText,
                      letterSpacing: 2.2,
                      shadows: [
                        Shadow(
                          color: AppColors.primaryNeonGreen.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 180.ms, duration: 450.ms),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cyan.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'INTERDIMENSIONAL CHARACTER ARCHIVE',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.cyan,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ).animate().fadeIn(delay: 280.ms, duration: 450.ms),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: AppColors.elevatedSurface,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryNeonGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _statusText,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PortalVortexPainter extends CustomPainter {
  _PortalVortexPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer ambient glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primaryNeonGreen.withValues(alpha: 0.38),
          AppColors.cyan.withValues(alpha: 0.14),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, glowPaint);

    // Concentric rotating portal arcs
    for (var i = 0; i < 4; i++) {
      final radius = maxRadius * (0.48 + i * 0.13);
      final startAngle =
          (progress * 2 * math.pi * (i.isEven ? 1 : -1.3)) + (i * 0.9);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 3 ? 2.5 : 3.2
        ..strokeCap = StrokeCap.round
        ..color = (i.isEven ? AppColors.primaryNeonGreen : AppColors.cyan)
            .withValues(alpha: 0.85 - i * 0.14);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        math.pi * 1.25,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PortalVortexPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
