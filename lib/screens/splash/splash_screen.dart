import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
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
  String? _networkErrorMessage;
  bool _isChecking = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _portalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bootstrapSession();
      }
    });
  }

  Future<void> _bootstrapSession() async {
    if (_isChecking || _hasNavigated) return;

    setState(() {
      _isChecking = true;
      _networkErrorMessage = null;
      _statusText = 'Initializing portal coordinates...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted || _hasNavigated) return;

    setState(() => _statusText = 'Checking Citadel credentials...');

    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.verifySession();
    if (!mounted || _hasNavigated) return;

    switch (result) {
      case SessionCheckResult.authenticated:
        setState(() => _statusText = 'Access granted. Opening multiverse...');
        await Future<void>.delayed(const Duration(milliseconds: 350));
        _navigateOnce(AppRoutes.home);
      case SessionCheckResult.noToken:
        setState(() => _statusText = 'No active key. Opening login terminal...');
        await Future<void>.delayed(const Duration(milliseconds: 350));
        _navigateOnce(AppRoutes.login);
      case SessionCheckResult.invalidToken:
        setState(() => _statusText = 'Session expired. Re-authentication needed...');
        await Future<void>.delayed(const Duration(milliseconds: 450));
        _navigateOnce(AppRoutes.login);
      case SessionCheckResult.networkError:
        setState(() {
          _isChecking = false;
          _statusText = 'Unable to reach Citadel server';
          _networkErrorMessage =
              authProvider.errorMessage ??
              'Connection interrupted while verifying your session.';
        });
    }
  }

  void _navigateOnce(String routeName) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _isChecking = false;
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void _goToLoginFromError() {
    context.read<AuthProvider>().clearError();
    _navigateOnce(AppRoutes.login);
  }

  @override
  void dispose() {
    _portalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasError = _networkErrorMessage != null;

    return Scaffold(
      body: PortalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
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
                              hasError: hasError,
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
                                color: hasError
                                    ? AppColors.error
                                    : AppColors.primaryNeonGreen,
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (hasError
                                          ? AppColors.error
                                          : AppColors.primaryNeonGreen)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                            child: Icon(
                              hasError
                                  ? Icons.wifi_off_rounded
                                  : Icons.science_rounded,
                              color: hasError
                                  ? AppColors.error
                                  : AppColors.primaryNeonGreen,
                              size: 32,
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
                    const SizedBox(height: 38),
                    if (!hasError) ...[
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
                    ] else
                      _buildNetworkErrorCard(textTheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkErrorCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.1),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.error,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _statusText,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.mainText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _networkErrorMessage!,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'RETRY CONNECTION',
            icon: Icons.refresh_rounded,
            onPressed: _bootstrapSession,
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'GO TO LOGIN',
            icon: Icons.login_rounded,
            variant: AppButtonVariant.outline,
            onPressed: _goToLoginFromError,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 280.ms);
  }
}

class _PortalVortexPainter extends CustomPainter {
  _PortalVortexPainter({
    required this.progress,
    this.hasError = false,
  });

  final double progress;
  final bool hasError;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final primaryGlowColor =
        hasError ? AppColors.error : AppColors.primaryNeonGreen;
    final secondaryArcColor = hasError ? AppColors.purple : AppColors.cyan;

    // Outer ambient glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryGlowColor.withValues(alpha: 0.36),
          secondaryArcColor.withValues(alpha: 0.14),
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
        ..color = (i.isEven ? primaryGlowColor : secondaryArcColor)
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
    return oldDelegate.progress != progress || oldDelegate.hasError != hasError;
  }
}
