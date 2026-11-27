import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

/// Futuristic control-panel button with subtle glow and loading state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final AppButtonVariant variant;
  final double height;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;
    final colors = _resolveColors();

    final buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: colors.foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: variant == AppButtonVariant.primary && effectiveOnPressed != null
              ? AppColors.portalGradient
              : null,
          color: variant == AppButtonVariant.primary ? null : colors.background,
          border: Border.all(
            color: effectiveOnPressed == null
                ? AppColors.borderSubtle
                : colors.border,
            width: 1.2,
          ),
          boxShadow: variant == AppButtonVariant.primary && effectiveOnPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primaryNeonGreen.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(child: buttonChild),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonColors _resolveColors() {
    switch (variant) {
      case AppButtonVariant.primary:
        return const _ButtonColors(
          background: AppColors.primaryNeonGreen,
          foreground: AppColors.background,
          border: AppColors.primaryNeonGreen,
        );
      case AppButtonVariant.secondary:
        return const _ButtonColors(
          background: AppColors.elevatedSurface,
          foreground: AppColors.cyan,
          border: AppColors.cyan,
        );
      case AppButtonVariant.outline:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.mainText,
          border: AppColors.borderSubtle,
        );
      case AppButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.error.withValues(alpha: 0.14),
          foreground: AppColors.error,
          border: AppColors.error.withValues(alpha: 0.6),
        );
    }
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}
