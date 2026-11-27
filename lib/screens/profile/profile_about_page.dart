import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_routing.dart';

/// Profile and developer identity screen connected to GET /user and POST /logout.
class ProfileAboutPage extends StatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  State<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends State<ProfileAboutPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().refreshUser();
      }
    });
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Close Portal Session?'),
        content: const Text(
          'You will be signed out of your Citadel account and returned to the login terminal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Stay'),
          ),
          AppButton(
            label: 'Logout',
            variant: AppButtonVariant.danger,
            isFullWidth: false,
            height: 42,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final auth = context.read<AuthProvider>();
    await auth.logout();

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 860 ? 32.0 : 16.0;

          return RefreshIndicator(
            color: AppColors.primaryNeonGreen,
            backgroundColor: AppColors.surface,
            onRefresh: () => auth.refreshUser(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.purple,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'RESEARCHER CREDENTIALS',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.purple,
                              letterSpacing: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Profile & About',
                        style: textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: AppColors.spaceSurfaceGradient,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.primaryNeonGreen.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryNeonGreen.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.portalGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryNeonGreen
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (user?.name.isNotEmpty ?? false)
                                      ? user!.name.substring(0, 1).toUpperCase()
                                      : 'R',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryNeonGreen
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'ACTIVE SANCTUM SESSION',
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        color: AppColors.primaryNeonGreen,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user?.name ?? 'Loading Researcher...',
                                    style: textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'Fetching user telemetry...',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.cyan,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 320.ms),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.badge_outlined,
                                  color: AppColors.cyan,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Developer Identity',
                                  style: textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _IdentityRow(
                              label: 'Nama',
                              value: 'Rehan Ramadhan',
                              accent: AppColors.primaryNeonGreen,
                            ),
                            const SizedBox(height: 10),
                            const _IdentityRow(
                              label: 'Kelas',
                              value: 'XII RPL',
                              accent: AppColors.cyan,
                            ),
                            const SizedBox(height: 10),
                            const _IdentityRow(
                              label: 'Aplikasi',
                              value: 'Rick & Morty Log',
                              accent: AppColors.purple,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 90.ms, duration: 320.ms),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primaryNeonGreen,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'About Application',
                                  style: textTheme.titleLarge,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Rick & Morty Log is a personal interdimensional character archive built for UAS Pemrograman Mobile. '
                              'Explore characters from the Rick and Morty multiverse API, organize them into custom dimensions, '
                              'and record field observations synced securely with a Laravel Sanctum backend.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.mainText.withValues(alpha: 0.88),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 160.ms, duration: 320.ms),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'TERMINATE PORTAL SESSION (LOGOUT)',
                        icon: Icons.logout_rounded,
                        variant: AppButtonVariant.danger,
                        isLoading: auth.isLoading,
                        onPressed: _confirmLogout,
                      ).animate().fadeIn(delay: 220.ms, duration: 320.ms),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
