import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../trading/providers/trading_provider.dart';

enum DepositStep { form, processing, success }

class DepositCashModal extends ConsumerStatefulWidget {
  const DepositCashModal({super.key});

  @override
  ConsumerState<DepositCashModal> createState() => _DepositCashModalState();
}

class _DepositCashModalState extends ConsumerState<DepositCashModal> {
  final TextEditingController _amountController = TextEditingController(text: '50000');
  String _selectedMethod = 'Raast (Instant)';
  DepositStep _currentStep = DepositStep.form;

  final List<double> _quickAmounts = [10000, 25000, 50000, 100000, 250000];

  final List<Map<String, dynamic>> _channels = [
    {
      'id': 'Raast (Instant)',
      'title': 'Raast Fast Payment',
      'subtitle': 'State Bank of Pakistan · 0% Fee · Instant',
      'icon': Icons.bolt_rounded,
      'color': const Color(0xFF00897B),
    },
    {
      'id': 'EasyPaisa',
      'title': 'EasyPaisa Wallet',
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
    {
      'id': '1Link 1Bill',
      'title': '1Link / 1Bill Voucher',
      'subtitle': 'All Pakistani Commercial Banks (IBFT)',
      'icon': Icons.account_balance_rounded,
      'color': const Color(0xFF1565C0),
    },
  ];

  Future<void> _handleDeposit() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _currentStep = DepositStep.processing);

    // Simulate 1.5s gateway handshake & ledger settlement
    await Future.delayed(const Duration(milliseconds: 1500));

    ref.read(tradingProvider.notifier).depositCash(amount);

    if (mounted) {
      setState(() => _currentStep = DepositStep.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: switch (_currentStep) {
        DepositStep.form => _buildFormState(),
        DepositStep.processing => _buildProcessingState(),
        DepositStep.success => _buildSuccessState(currency),
      },
    );
  }

  Widget _buildFormState() {
    return Column(
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
            Text('Deposit Funds (Gateway)', style: AppTypography.titleLarge),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.roundedSm,
              ),
              child: Text(
                'LIVE GATEWAY',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Instant demo balance top-up via Pakistan financial rails.',
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
                          Text(
                            ch['title'] as String,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ch['subtitle'] as String,
                            style: AppTypography.bodySmall.copyWith(fontSize: 10),
                          ),
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

        // Confirm Deposit Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleDeposit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedMd,
              ),
              elevation: 0,
            ),
            child: const Text('Proceed to Instant Deposit', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Connecting to $_selectedMethod...', style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Securely processing transaction via State Bank 1Link/Raast rails.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(NumberFormat currency) {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    return Column(
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
        Text('Deposit Confirmed!', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Rs. ${currency.format(amount)} has been credited to your trading wallet via $_selectedMethod.',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Settlement Status', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Row(
                children: [
                  Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text('Settled (100%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navy,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.roundedMd,
              ),
            ),
            child: const Text('Return to Portfolio'),
          ),
        ),
      ],
    );
  }
}
