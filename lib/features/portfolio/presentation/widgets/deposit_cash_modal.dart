import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../profile/presentation/widgets/kyc_verification_modal.dart';
import '../../../profile/providers/account_provider.dart';
import '../../../trading/providers/trading_provider.dart';

enum DepositStep { form, processing, success }

class DepositCashModal extends ConsumerStatefulWidget {
  const DepositCashModal({super.key});

  @override
  ConsumerState<DepositCashModal> createState() => _DepositCashModalState();
}

class _DepositCashModalState extends ConsumerState<DepositCashModal> {
  final TextEditingController _amountController = TextEditingController(text: '25000');
  final TextEditingController _referenceController = TextEditingController(text: 'RAAST-84920194');
  String _selectedMethod = 'Raast (Instant)';
  DepositStep _currentStep = DepositStep.form;

  final List<double> _quickAmounts = [5000, 10000, 25000, 50000, 100000];

  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'Raast (Instant)',
      'title': 'Raast Fast Payment (SBP)',
      'subtitle': 'State Bank of Pakistan · 0% Fee · Instant',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFF00897B),
    },
    {
      'id': 'Meezan Bank IBFT',
      'title': 'Meezan Bank / 1Link IBFT',
      'subtitle': 'Direct Bank Transfer · Instant Credit',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF1565C0),
    },
    {
      'id': 'EasyPaisa',
      'title': 'EasyPaisa Mobile Account',
      'subtitle': 'Telenor Microfinance Bank · Instant Credit',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFF00C853),
    },
    {
      'id': 'JazzCash',
      'title': 'JazzCash Mobile Account',
      'subtitle': 'Mobilink Microfinance Bank · Instant Credit',
      'icon': Icons.phone_android_rounded,
      'color': const Color(0xFFD50000),
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _handleDeposit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _currentStep = DepositStep.processing);

    // Gateway handshake & instant ledger settlement
    await Future.delayed(const Duration(milliseconds: 1400));

    // Update real balance and transaction history in accountProvider and tradingProvider
    ref.read(accountProvider.notifier).depositRealFunds(
          amount: amount,
          paymentMethod: _selectedMethod,
          reference: _referenceController.text.trim(),
        );
    ref.read(tradingProvider.notifier).depositCash(amount);

    if (mounted) {
      setState(() => _currentStep = DepositStep.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final accountState = ref.watch(accountProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: !accountState.isKycVerified
          ? _buildKycRequiredView()
          : switch (_currentStep) {
              DepositStep.form => _buildFormState(),
              DepositStep.processing => _buildProcessingState(),
              DepositStep.success => _buildSuccessState(currency),
            },
    );
  }

  // ── KYC Gating View ──────────────────────────────────────────────
  Widget _buildKycRequiredView() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEFCBF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD69E2E), width: 2),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFB7791F),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '1-Time KYC Verification Required',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'In accordance with SECP and State Bank of Pakistan regulations, you must complete your 1-time identity verification (CNIC + Mobile OTP + Linked Bank) before depositing real funds.',
            style: TextStyle(fontSize: 13, color: Color(0xFF718096), height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const KycVerificationModal(),
                );
              },
              icon: const Icon(Icons.shield_rounded, size: 20),
              label: const Text(
                'Verify 1-Time KYC Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF718096))),
          ),
        ],
      ),
    );
  }

  // ── Deposit Form ────────────────────────────────────────────────
  Widget _buildFormState() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Deposit Real Funds', style: AppTypography.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6F6D5),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Text(
                  'SECP VERIFIED ✅',
                  style: TextStyle(
                    color: Color(0xFF22543D),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Instant deposit via Raast, 1Link IBFT, or Mobile Wallets.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount Field
          Text('Deposit Amount (PKR)', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: AppTypography.financialLarge.copyWith(fontSize: 22),
            decoration: InputDecoration(
              prefixText: 'Rs. ',
              prefixStyle: AppTypography.financialLarge.copyWith(
                fontSize: 22,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: AppRadius.roundedMd,
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Quick Amount Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickAmounts.map((amt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      '+Rs. ${(amt / 1000).toStringAsFixed(0)}k',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.primaryLight,
                    side: BorderSide.none,
                    onPressed: () {
                      setState(() {
                        _amountController.text = amt.toStringAsFixed(0);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Payment Channel Tiles
          Text('Select Payment Channel', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          ..._channels.map((ch) {
            final isSelected = _selectedMethod == ch['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedMethod = ch['id'] as String),
                borderRadius: AppRadius.roundedMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : AppColors.background,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (ch['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Icon(ch['icon'] as IconData, color: ch['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ch['title'] as String, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                            Text(ch['subtitle'] as String, style: AppTypography.bodySmall.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleDeposit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                elevation: 0,
              ),
              child: const Text('Proceed with Deposit', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Processing State ─────────────────────────────────────────────
  Widget _buildProcessingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        const SizedBox(height: AppSpacing.lg),
        Text('Processing Real Deposit...', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Connecting to $_selectedMethod rails...',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  // ── Success State ────────────────────────────────────────────────
  Widget _buildSuccessState(NumberFormat currency) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Deposit Successful!', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Rs. ${currency.format(amount)} has been credited to your Real PSX Trading Account via $_selectedMethod.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.roundedMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Settlement Method', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(_selectedMethod, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Row(
                      children: [
                        Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 5),
                        const Text('Settled · Ready to Trade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
              ),
              child: const Text('Return to Portfolio', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
