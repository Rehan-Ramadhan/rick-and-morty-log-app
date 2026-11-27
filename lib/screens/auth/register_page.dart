import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../routing/app_routing.dart';
import '../../widgets/portal_background.dart';

/// Registration page integrated with Laravel POST /register.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final outcome = await auth.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );

    if (!mounted) return;
    if (outcome.success) {
      if (outcome.hasToken) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portal credentials calibrated. Welcome aboard!'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              outcome.message ?? 'Registration successful. Please sign in.',
            ),
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton.outlined(
                        onPressed: auth.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          side: const BorderSide(color: AppColors.borderSubtle),
                          foregroundColor: AppColors.mainText,
                        ),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withValues(
                                      alpha: 0.14,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.cyan.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.badge_outlined,
                                    color: AppColors.cyan,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Register Researcher',
                                        style: textTheme.headlineMedium,
                                      ),
                                      Text(
                                        'Create your Citadel archive ID',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.cyan,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                              controller: _nameController,
                              label: 'FULL NAME',
                              hint: 'Morty Smith',
                              prefixIcon: Icons.person_outline_rounded,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => auth.clearError(),
                              validator: (value) {
                                if ((value?.trim() ?? '').isEmpty) {
                                  return 'Name is required.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _emailController,
                              label: 'EMAIL ADDRESS',
                              hint: 'morty@earth-c137.io',
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
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _passwordController,
                              label: 'PASSWORD',
                              hint: 'Minimum 8 characters',
                              prefixIcon: Icons.lock_outline_rounded,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => auth.clearError(),
                              validator: (value) {
                                final v = value ?? '';
                                if (v.isEmpty) return 'Password is required.';
                                if (v.length < 8) {
                                  return 'Use at least 8 characters.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _confirmController,
                              label: 'CONFIRM PASSWORD',
                              hint: 'Repeat password',
                              prefixIcon: Icons.verified_user_outlined,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => auth.clearError(),
                              onFieldSubmitted: (_) => _submit(),
                              validator: (value) {
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              label: 'INITIALIZE ACCOUNT',
                              icon: Icons.rocket_launch_rounded,
                              isLoading: auth.isLoading,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already registered? ',
                                  style: textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          auth.clearError();
                                          Navigator.of(context).pop();
                                        },
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.05),
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
