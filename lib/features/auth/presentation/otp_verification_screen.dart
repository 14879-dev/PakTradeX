import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String target;

  const OtpVerificationScreen({super.key, required this.target});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-focus first box after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes[0].requestFocus();
    });
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

  String get _otpCode => _controllers.map((c) => c.text.trim()).join();

  void _fillFromCode(String code) {
    final cleanDigits = code.replaceAll(RegExp(r'\D'), '');
    for (int i = 0; i < 6; i++) {
      if (i < cleanDigits.length) {
        _controllers[i].text = cleanDigits[i];
      } else {
        _controllers[i].clear();
      }
    }
    setState(() {});
    if (cleanDigits.length >= 6) {
      _focusNodes[5].unfocus();
      _handleVerify();
    } else if (cleanDigits.isNotEmpty) {
      final nextIndex = cleanDigits.length.clamp(0, 5);
      _focusNodes[nextIndex].requestFocus();
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      _fillFromCode(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pasted code: ${_otpCode.padRight(6, '•')}'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clipboard is empty')),
        );
      }
    }
  }

  Future<void> _handleVerify() async {
    final code = _otpCode;
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the code')),
      );
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).verifyOtp(code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorMsg = ref.read(authProvider).errorMessage ??
          'Invalid verification code. Please check and try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emailTarget = widget.target.isEmpty
        ? (ref.watch(authProvider).pendingEmailOrPhone ?? 'your registered email')
        : widget.target;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _pasteFromClipboard,
            icon: const Icon(Icons.content_paste_rounded, size: 16, color: AppColors.primary),
            label: const Text(
              'Paste',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
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
              Text(
                'Verify Security Code',
                style: AppTypography.displayMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              RichText(
                text: TextSpan(
                  text: 'We sent a 6-digit authentication code to\n',
                  style: AppTypography.bodyMedium,
                  children: [
                    TextSpan(
                      text: emailTarget,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // 6 PIN Input boxes with multi-digit paste interceptor
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTypography.financialLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        fontSize: 22,
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: BorderSide(
                            color: _controllers[index].text.isNotEmpty
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        // If pasted multiple digits into any single box
                        if (value.length > 1) {
                          _fillFromCode(value);
                          return;
                        }

                        if (value.isNotEmpty) {
                          if (index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            _focusNodes[index].unfocus();
                            // All 6 filled -> AUTO-VERIFY IMMEDIATELY
                            if (_otpCode.length == 6) {
                              _handleVerify();
                            }
                          }
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // Quick Paste Shortcut Bar
              InkWell(
                onTap: _pasteFromClipboard,
                borderRadius: AppRadius.roundedSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: AppRadius.roundedSm,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.content_paste_rounded, size: 14, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'Tap here to paste full 6-digit code',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Verify Button
              PrimaryButton(
                label: 'Verify & Continue',
                isLoading: _isLoading,
                onPressed: _handleVerify,
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
                          'Resend Code via Email',
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

