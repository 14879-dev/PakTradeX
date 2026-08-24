import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../profile/providers/account_provider.dart';
import '../../../trading/providers/trading_provider.dart';

enum WithdrawStep { form, processing, success }

class WithdrawCashModal extends ConsumerStatefulWidget {
  const WithdrawCashModal({super.key});

  @override
  ConsumerState<WithdrawCashModal> createState() => _WithdrawCashModalState();
}

class _WithdrawCashModalState extends ConsumerState<WithdrawCashModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController(text: '1234');
  WithdrawStep _currentStep = WithdrawStep.form;
  String _selectedDestination = 'Linked Bank (Meezan)';

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleWithdraw() async {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final account = ref.read(accountProvider);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid withdrawal amount')),
      );
      return;
    }

    if (amount > account.realBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient real cash balance. Available: Rs. ${account.realBalance.toStringAsFixed(2)}'),
          backgroundColor: const Color(0xFFE53E3E),
        ),
      );
      return;
    }

    setState(() => _currentStep = WithdrawStep.processing);

    // 1.5s simulated Raast IBFT transfer to user's bank
    await Future.delayed(const Duration(milliseconds: 1500));

    final success = ref.read(accountProvider.notifier).withdrawRealFunds(
          amount: amount,
          destinationBank: account.bankName.isNotEmpty ? account.bankName : 'Meezan Bank Ltd',
          iban: account.accountNumber.isNotEmpty ? account.accountNumber : 'PK42MEZN0001928491028301',
        );

    if (success) {
      ref.read(tradingProvider.notifier).withdrawCash(amount);
      if (mounted) {
        setState(() => _currentStep = WithdrawStep.success);
      }
    } else {
      if (mounted) {
        setState(() => _currentStep = WithdrawStep.form);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal failed: Insufficient funds')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final account = ref.watch(accountProvider);

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
      child: switch (_currentStep) {
        WithdrawStep.form => _buildFormState(account, currency),
        WithdrawStep.processing => _buildProcessingState(),
        WithdrawStep.success => _buildSuccessState(currency),
      },
    );
  }

  Widget _buildFormState(AccountState account, NumberFormat currency) {
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
              Text('Withdraw Funds', style: AppTypography.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFC6F6D5),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Text(
                  'RAAST FAST PAY',
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
            'Transfer funds directly to your verified Pakistani bank account or Raast ID.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Balance Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available for Withdrawal', style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
                    const SizedBox(height: 2),
                    Text(
                      'Rs. ${currency.format(account.realBalance)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _amountController.text = account.realBalance.toStringAsFixed(0);
                    });
                  },
                  child: const Text('Withdraw All (Max)', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Amount Field
          Text('Withdrawal Amount (PKR)', style: AppTypography.labelMedium),
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
          const SizedBox(height: AppSpacing.md),

          // Beneficiary Account
          Text('Destination Account', style: AppTypography.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.bankName.isNotEmpty ? account.bankName : 'Meezan Bank Limited',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        account.accountNumber.isNotEmpty ? account.accountNumber : 'PK42MEZN0001928491028301',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Fee & Settlement Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF2F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Withdrawal Fee', style: TextStyle(fontSize: 12, color: Color(0xFF4A5568))),
                Text('Rs. 0.00 (Free SBP Raast)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF22543D))),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                elevation: 0,
              ),
              child: const Text('Confirm & Withdraw Cash', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.xl),
        const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
        const SizedBox(height: AppSpacing.lg),
        Text('Executing Raast Withdrawal...', style: AppTypography.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Connecting to State Bank of Pakistan 1Link / Raast settlement network...',
          style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

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
          Text('Withdrawal Dispatched!', style: AppTypography.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Rs. ${currency.format(amount)} has been sent via Raast Instant Settlement to your linked bank account.',
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Settlement Channel', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('SBP Raast IBFT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                        const Text('Completed · Instant Credit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.success)),
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
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
