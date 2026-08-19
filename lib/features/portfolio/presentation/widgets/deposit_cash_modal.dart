import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../trading/providers/trading_provider.dart';

class DepositCashModal extends ConsumerStatefulWidget {
  const DepositCashModal({super.key});

  @override
  ConsumerState<DepositCashModal> createState() => _DepositCashModalState();
}

class _DepositCashModalState extends ConsumerState<DepositCashModal> {
  final TextEditingController _amountController = TextEditingController(text: '50000');
  String _selectedMethod = 'Raast (Instant)';
  bool _isSuccess = false;

  final List<double> _quickAmounts = [10000, 25000, 50000, 100000, 250000];

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
      child: _isSuccess
          ? _buildSuccessState(currency)
          : Column(
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
                    Text('Deposit Demo Funds', style: AppTypography.titleLarge),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Text(
                        'SIMULATION',
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
                  'Add simulated PKR funds to practice trading risk-free on PSX.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),

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
                const SizedBox(height: AppSpacing.lg),

                // Payment Method
                Text('Simulated Transfer Gateway', style: AppTypography.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMethod,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'Raast (Instant)',
                          child: Text('⚡ Raast Fast Payment (Free, Instant)'),
                        ),
                        DropdownMenuItem(
                          value: '1Link 1Bill',
                          child: Text('🏦 1Link / 1Bill Voucher'),
                        ),
                        DropdownMenuItem(
                          value: 'Nayapay / Sadapay',
                          child: Text('💳 NayaPay / SadaPay Wallet'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMethod = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Confirm Deposit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_amountController.text) ?? 0.0;
                      if (amount > 0) {
                        ref.read(tradingProvider.notifier).depositCash(amount);
                        setState(() => _isSuccess = true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                    child: const Text('Confirm Simulated Deposit'),
                  ),
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
        const SizedBox(height: AppSpacing.lg),
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
          'Rs. ${currency.format(amount)} has been credited to your simulated trading wallet via $_selectedMethod.',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Return to Portfolio'),
          ),
        ),
      ],
    );
  }
}
