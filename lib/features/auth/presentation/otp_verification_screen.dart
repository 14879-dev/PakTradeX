import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String target;

  const OtpVerificationScreen({super.key, required this.target});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Security Code',
                style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  text: 'We sent a 6-digit authentication code to\n',
                  style: AppTypography.bodyMedium,
                  children: [
                    TextSpan(
                      text: widget.target.isEmpty ? 'your registered email/phone' : widget.target,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Demo / Dev Helper Card
              Consumer(
                builder: (context, ref, child) {
                  final devOtp = ref.watch(authProvider).pendingDevOtp;
                  final displayCode = devOtp ?? '123456';
                  return Column(
                    children: [
                      AppCard(
                        backgroundColor: AppColors.primaryLight,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                devOtp != null
                                    ? 'Security Code Sent: Enter $devOtp to complete verification.'
                                    : 'Demo Mode: Enter 123456 or tap autofill to verify immediately.',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // 6 PIN Input boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 46,
                            height: 54,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: AppTypography.financialLarge.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: AppColors.background,
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.roundedMd,
                                  borderSide: const BorderSide(color: AppColors.border),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppRadius.roundedMd,
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Autofill shortcut
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            for (int i = 0; i < 6 && i < displayCode.length; i++) {
                              _controllers[i].text = displayCode[i];
                            }
                          },
                          icon: const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.primary),
                          label: Text(
                            'Autofill Code ($displayCode)',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Verify Button
              PrimaryButton(
                label: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: () async {
                  if (_otpCode.length == 6) {
                    setState(() => _isLoading = true);
                    final success = await ref.read(authProvider.notifier).verifyOtp(_otpCode);
                    if (!context.mounted) return;
                    setState(() => _isLoading = false);

                    if (success) {
                      context.go('/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid code. Try entering 123456')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter all 6 digits of the code')),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Resend Timer
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in ${_secondsRemaining}s',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: Text(
                          'Resend Code via SMS / Email',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
