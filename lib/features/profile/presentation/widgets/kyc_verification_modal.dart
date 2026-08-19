import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../providers/account_provider.dart';

class KycVerificationModal extends ConsumerStatefulWidget {
  const KycVerificationModal({super.key});

  @override
  ConsumerState<KycVerificationModal> createState() => _KycVerificationModalState();
}

class _KycVerificationModalState extends ConsumerState<KycVerificationModal> {
  int _currentStep = 0; // 0: Phone/OTP, 1: CNIC, 2: Bank, 3: Success

  // Step 1: Phone & OTP
  final _phoneController = TextEditingController(text: '0300 1234567');
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  bool _otpSent = false;
  int _resendTimerSeconds = 30;
  Timer? _timer;

  // Step 2: CNIC
  final _cnicController = TextEditingController(text: '42101-8492014-3');
  final _fullNameController = TextEditingController(text: 'Syed Ali Raza');
  final _fatherNameController = TextEditingController(text: 'Syed Raza Hussain');
  final _issueDateController = TextEditingController(text: '14/08/2021');

  // Step 3: Bank
  String _selectedBank = 'Meezan Bank Ltd';
  final _ibanController = TextEditingController(text: 'PK42MEZN0001928491028301');
  final _raastIdController = TextEditingController(text: '03001234567');

  bool _isProcessing = false;

  final List<String> _pakistanBanks = [
    'Meezan Bank Ltd',
    'Habib Bank Limited (HBL)',
    'Bank Alfalah',
    'United Bank Limited (UBL)',
    'MCB Bank',
    'Standard Chartered Pakistan',
    'EasyPaisa (Telenor Microfinance)',
    'JazzCash (Mobilink Microfinance)',
    'SadaPay',
    'NayaPay',
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    _cnicController.dispose();
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _issueDateController.dispose();
    _ibanController.dispose();
    _raastIdController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimerSeconds = 30;
      _otpSent = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimerSeconds > 0) {
        setState(() => _resendTimerSeconds--);
      } else {
        t.cancel();
      }
    });

    // Auto-fill simulated OTP after 1.5 seconds for instant delightful demo
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _otpSent) {
        final sampleOtp = '749218';
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = sampleOtp[i];
        }
        setState(() {});
      }
    });
  }

  void _submitStep1() {
    final enteredOtp = _otpControllers.map((c) => c.text).join();
    if (enteredOtp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits of the OTP')),
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  void _submitStep2() {
    if (_cnicController.text.trim().length < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 13-digit CNIC number')),
      );
      return;
    }
    setState(() => _currentStep = 2);
  }

  Future<void> _submitStep3() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    ref.read(accountProvider.notifier).completeKyc(
          phone: _phoneController.text.trim(),
          cnic: _cnicController.text.trim(),
          bank: _selectedBank,
          accountNum: _ibanController.text.trim(),
        );

    // Switch to Real mode automatically upon verification
    ref.read(accountProvider.notifier).switchMode(AccountMode.real);

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _currentStep = 3;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: const Icon(Icons.verified_user_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Real Account KYC',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'SECP & CDC Verified Onboarding',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Step Progress Bar
          if (_currentStep < 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Mobile OTP', _currentStep >= 0),
                  _buildStepDivider(_currentStep >= 1),
                  _buildStepIndicator(1, 'CNIC ID', _currentStep >= 1),
                  _buildStepDivider(_currentStep >= 2),
                  _buildStepIndicator(2, 'Bank / Raast', _currentStep >= 2),
                ],
              ),
            ),

          // Body Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _buildCurrentStepView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title, bool isCompleted) {
    final isActive = _currentStep == stepIndex;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary
                  : AppColors.background,
              border: Border.all(
                color: isCompleted ? AppColors.primary : AppColors.border,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted && _currentStep > stepIndex
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isCompleted ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider(bool isCompleted) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isCompleted ? AppColors.primary : AppColors.border,
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildPhoneOtpStep();
      case 1:
        return _buildCnicStep();
      case 2:
        return _buildBankStep();
      case 3:
      default:
        return _buildSuccessStep();
    }
  }

  // ── Step 0: Phone & OTP ──────────────────────────────────────────
  Widget _buildPhoneOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Mobile Number Verification',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'We will send a 6-digit one-time passcode to verify your phone number.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Pakistan Mobile Number',
            prefixIcon: const Icon(Icons.phone_android_rounded),
            suffixIcon: TextButton(
              onPressed: _startTimer,
              child: Text(_otpSent ? 'Resend' : 'Send Code'),
            ),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        if (_otpSent) ...[
          Text(
            'Enter 6-Digit OTP Code',
            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 44,
                height: 52,
                child: TextField(
                  controller: _otpControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.roundedSm,
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  onChanged: (val) {
                    if (val.isNotEmpty && index < 5) {
                      FocusScope.of(context).nextFocus();
                    } else if (val.isEmpty && index > 0) {
                      FocusScope.of(context).previousFocus();
                    }
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _resendTimerSeconds > 0
                    ? 'Resend code in ${_resendTimerSeconds}s'
                    : 'Code expired',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
              if (_resendTimerSeconds == 0)
                GestureDetector(
                  onTap: _startTimer,
                  child: Text(
                    'Resend OTP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Verify Phone & Proceed',
          onPressed: _otpSent ? _submitStep1 : _startTimer,
        ),
      ],
    );
  }

  // ── Step 1: CNIC ────────────────────────────────────────────────
  Widget _buildCnicStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 2: NADRA Identity Verification',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide your 13-digit National Identity Card details for CDC sub-account creation.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        TextField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name (as on CNIC)',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _cnicController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'CNIC Number (42101-XXXXXXX-X)',
            prefixIcon: const Icon(Icons.badge_outlined),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(
                  labelText: "Father's / Husband's Name",
                  border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _issueDateController,
                decoration: InputDecoration(
                  labelText: 'CNIC Issue Date',
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.roundedSm,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.security_rounded, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Encrypted NADRA Verisys check will be performed automatically.',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Save & Continue',
                onPressed: _submitStep2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 2: Bank / Raast ─────────────────────────────────────────
  Widget _buildBankStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 3: Bank Account / Raast Settlement',
          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Link your Pakistani bank or Raast ID for instant deposits and 24/7 withdrawals.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        DropdownButtonFormField<String>(
          value: _selectedBank,
          decoration: InputDecoration(
            labelText: 'Select Bank / Financial Institution',
            prefixIcon: const Icon(Icons.account_balance_rounded),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
          items: _pakistanBanks.map((bank) {
            return DropdownMenuItem(value: bank, child: Text(bank, style: const TextStyle(fontSize: 13)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedBank = val);
          },
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _ibanController,
          decoration: InputDecoration(
            labelText: 'IBAN (24 Characters)',
            hintText: 'PK42MEZN0001928491028301',
            prefixIcon: const Icon(Icons.credit_card_rounded),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        TextField(
          controller: _raastIdController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Raast ID (Registered Mobile Number)',
            hintText: '03001234567',
            prefixIcon: const Icon(Icons.flash_on_rounded, color: AppColors.warning),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
                ),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                label: 'Complete Verification',
                isLoading: _isProcessing,
                onPressed: _submitStep3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Success Celebration ──────────────────────────────────
  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Account Verified!',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your PakTradeX Real Trading Account is now active.\nYou can now trade live PSX equities and transfer funds instantly.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildReceiptRow('PakTrade ID', 'PTX-148790'),
              const Divider(height: 16),
              _buildReceiptRow('Account Tier', 'Verified Real Trader (SECP/CDC)'),
              const Divider(height: 16),
              _buildReceiptRow('Bank Linked', _selectedBank),
              const Divider(height: 16),
              _buildReceiptRow('Raast ID', _raastIdController.text),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Start Real Trading',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
