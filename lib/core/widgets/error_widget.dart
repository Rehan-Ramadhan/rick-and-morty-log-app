import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_button.dart';

/// Reusable sci-fi error and empty state card with optional retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry Scan',
    this.icon = Icons.warning_amber_rounded,
    this.isEmptyState = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;
  final bool isEmptyState;

  @override
  Widget build(BuildContext context) {
    final accent = isEmptyState ? AppColors.cyan : AppColors.error;

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                  ),
                  child: Icon(icon, color: accent, size: 30),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  AppButton(
                    label: retryLabel,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                    isFullWidth: false,
                    variant: isEmptyState
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
