import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../profile/providers/account_provider.dart';

class P2pTransferModal extends ConsumerStatefulWidget {
  const P2pTransferModal({super.key});

  @override
  ConsumerState<P2pTransferModal> createState() => _P2pTransferModalState();
}

class _P2pTransferModalState extends ConsumerState<P2pTransferModal> {
  final _idController = TextEditingController(text: 'PTX-');
  final _amountController = TextEditingController(text: '5000');
  final _noteController = TextEditingController();

  bool _isSearching = false;
  Map<String, String>? _foundRecipient;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _txnId = '';

  final Map<String, String> _knownUsers = {
    'PTX-948201': 'Fatima Khan (Verified Trader)',
    'PTX-829104': 'Hamza Tariq (Pro Investor)',
    'PTX-551920': 'Ayesha Siddiqui (PSX Analyst)',
    'PTX-112233': 'Zain Ahmed (Verified Trader)',
  };

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onIdChanged);
  }

  @override
  void dispose() {
    _idController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onIdChanged() {
    final query = _idController.text.trim().toUpperCase();
    if (query.length >= 8) {
      setState(() => _isSearching = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _isSearching = false;
            if (_knownUsers.containsKey(query)) {
              _foundRecipient = {'id': query, 'name': _knownUsers[query]!};
            } else if (query.startsWith('PTX-')) {
              _foundRecipient = {'id': query, 'name': 'PakTrade Trader (Verified)'};
            } else {
              _foundRecipient = null;
            }
          });
        }
      });
    } else {
      if (_foundRecipient != null) {
        setState(() => _foundRecipient = null);
      }
    }
  }

  Future<void> _executeTransfer() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final account = ref.read(accountProvider);
    if (account.activeBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Insufficient ${account.isRealMode ? "Real" : "Demo"} balance. Available: Rs. ${NumberFormat("#,##0").format(account.activeBalance)}',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    final success = ref.read(accountProvider.notifier).sendP2pTransfer(
          recipientId: _foundRecipient?['id'] ?? _idController.text.trim().toUpperCase(),
          recipientName: _foundRecipient?['name'] ?? 'PakTrade Trader',
          amount: amount,
          note: _noteController.text.trim(),
        );

    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (success) {
          _isSuccess = true;
          _txnId = 'PTX-TX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final account = ref.watch(accountProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PakTrade ID Transfer',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Instant zero-fee peer-to-peer transfer',
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

          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: _isSuccess ? _buildSuccessView(account, currency) : _buildFormView(account, currency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(AccountState account, NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source Wallet Selector & Balance
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    account.isRealMode ? Icons.shield_rounded : Icons.code_rounded,
                    color: account.isRealMode ? AppColors.success : AppColors.warning,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.isRealMode ? 'Real Wallet Transfer' : 'Demo Wallet Transfer',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Available: Rs. ${currency.format(account.activeBalance)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  ref.read(accountProvider.notifier).toggleMode();
                },
                child: Text(account.isRealMode ? 'Switch Demo' : 'Switch Real'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Recipient PakTrade ID
        Text(
          "Recipient's PakTrade ID",
          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _idController,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. PTX-948201',
            prefixIcon: const Icon(Icons.person_pin_rounded),
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.qr_code_scanner_rounded),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),

        // Verified Recipient Chip
        if (_foundRecipient != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: AppRadius.roundedSm,
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _foundRecipient!['name']!,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Transfer Amount
        Text(
          'Transfer Amount (PKR)',
          style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            prefixText: 'Rs. ',
            prefixStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Quick amount chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1000, 5000, 10000, 25000].map((amt) {
            return ActionChip(
              label: Text('+Rs. ${NumberFormat("#,##0").format(amt)}', style: const TextStyle(fontSize: 11)),
              onPressed: () {
                setState(() => _amountController.text = amt.toString());
              },
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Optional Note
        TextField(
          controller: _noteController,
          decoration: InputDecoration(
            labelText: 'Purpose / Note (Optional)',
            hintText: 'e.g. Investment pool share',
            prefixIcon: const Icon(Icons.note_alt_outlined),
            border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
          ),
        ),

        const SizedBox(height: AppSpacing.xl),

        PrimaryButton(
          label: 'Send Instant Transfer',
          isLoading: _isProcessing,
          onPressed: _executeTransfer,
        ),
      ],
    );
  }

  Widget _buildSuccessView(AccountState account, NumberFormat currency) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: AppColors.success, size: 48),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Transfer Successful!',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rs. ${currency.format(amount)}',
          style: AppTypography.financialLarge.copyWith(fontSize: 26, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Transferred to ${_foundRecipient?['name'] ?? _idController.text}',
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
              _buildReceiptRow('Transaction ID', _txnId),
              const Divider(height: 14),
              _buildReceiptRow('Recipient ID', _idController.text.toUpperCase()),
              const Divider(height: 14),
              _buildReceiptRow('Sender ID', account.pakTradeId),
              const Divider(height: 14),
              _buildReceiptRow('Transfer Fee', 'Rs. 0.00 (Zero Fee)'),
              const Divider(height: 14),
              _buildReceiptRow('Remaining Balance', 'Rs. ${currency.format(account.activeBalance)}'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Done',
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
        Text(value, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
