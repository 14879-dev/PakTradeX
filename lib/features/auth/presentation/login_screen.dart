import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'investor@paktradex.pk');
  final _passwordController = TextEditingController(text: 'demo1234');
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).loginAsGuest();
              context.go('/home');
            },
            child: Text(
              'Guest Mode',
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.roundedMd,
                ),
                child: const Center(
                  child: Text(
                    'PX',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Welcome Back',
                style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Sign in to your PakTradeX account to manage your PSX investments.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Email / CNIC
              AppTextField(
                label: 'Email Address / CNIC',
                hintText: 'investor@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: AppSpacing.md),

              // Password
              AppTextField(
                label: 'Password',
                hintText: '••••••••',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Forgot Password link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Sign In Button
              PrimaryButton(
                label: 'Sign In with 2FA',
                isLoading: _isLoading,
                onPressed: () async {
                  if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter your email and password')),
                    );
                    return;
                  }

                  setState(() => _isLoading = true);
                  await ref.read(authProvider.notifier).login(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                  if (!context.mounted) return;
                  setState(() => _isLoading = false);

                  final authState = ref.read(authProvider);
                  if (authState.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authState.errorMessage!),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                    return;
                  }

                  context.push('/otp?target=${Uri.encodeComponent(_emailController.text.trim())}');
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Biometric Shortcut Button
              OutlinedButton.icon(
                onPressed: () async {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(milliseconds: 400));
                  ref.read(authProvider.notifier).loginAsGuest();
                  if (!context.mounted) return;
                  setState(() => _isLoading = false);
                  context.go('/home');
                },
                icon: const Icon(Icons.fingerprint_rounded, color: AppColors.primary, size: 22),
                label: const Text('Unlock with Biometrics (Touch ID / Face)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.border, width: 1.2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Register CTA
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Register Now',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
