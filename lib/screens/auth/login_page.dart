import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_routing.dart';
import '../../widgets/portal_background.dart';

/// Sci-fi terminal login page integrated with Laravel POST /login.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: PortalBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.portalGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryNeonGreen.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: AppColors.background,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'RICK & MORTY LOG',
                                style: textTheme.titleLarge?.copyWith(
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'LAB TERMINAL // C-137',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.cyan,
                                  letterSpacing: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 380.ms).slideY(begin: -0.1),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 30,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: AppColors.primaryNeonGreen.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Portal Access',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Authenticate to access your personal interdimensional character archive.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 22),
                            if (auth.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.error.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        auth.errorMessage!,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                            AppTextField(
                              controller: _emailController,
                              label: 'SCIENTIST EMAIL',
                              hint: 'rick@citadel.org',
                              prefixIcon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => auth.clearError(),
                              validator: (value) {
                                final v = value?.trim() ?? '';
                                if (v.isEmpty) return 'Email is required.';
                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'Enter a valid email address.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _passwordController,
                              label: 'ACCESS KEY',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => auth.clearError(),
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if ((value ?? '').isEmpty) {
                                  return 'Password is required.';
                                }
                                if ((value ?? '').length < 6) {
                                  return 'Minimum 6 characters required.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'ACTIVATE PORTAL',
                              icon: Icons.bolt_rounded,
                              isLoading: auth.isLoading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New researcher? ',
                                  style: textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          auth.clearError();
                                          Navigator.of(context).pushNamed(
                                            AppRoutes.register,
                                          );
                                        },
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: AppColors.primaryNeonGreen,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 120.ms, duration: 420.ms).slideY(
                          begin: 0.06,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
