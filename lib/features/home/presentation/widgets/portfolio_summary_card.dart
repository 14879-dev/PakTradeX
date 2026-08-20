import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../models/market_data_models.dart';

class PortfolioSummaryCard extends StatefulWidget {
  final PortfolioSummary summary;
  final VoidCallback? onDepositTap;
  final VoidCallback? onWithdrawTap;

  const PortfolioSummaryCard({
    super.key,
    required this.summary,
    this.onDepositTap,
    this.onWithdrawTap,
  });

  @override
  State<PortfolioSummaryCard> createState() => _PortfolioSummaryCardState();
}

class _PortfolioSummaryCardState extends State<PortfolioSummaryCard> {
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##0.00', 'en_US');

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy,
            Color(0xFF0F2B52),
          ],
        ),
        borderRadius: AppRadius.roundedLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag + Privacy Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  'PSX INVESTMENT ACCOUNT',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.8,
                    fontSize: 10,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _hideBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.7),
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _hideBalance = !_hideBalance;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Total Balance Label & Amount (Fitted to never overflow)
          Text(
            'Total Portfolio Value',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _hideBalance ? 'PKR ••••••••' : 'Rs. ${currencyFormat.format(widget.summary.totalBalance)}',
              style: AppTypography.displayMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // PnL Stats in row with safe layout
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Return",
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: PriceChangeBadge(
                        changePercent: widget.summary.todaysPnlPercent,
                        changeAmount: widget.summary.todaysPnl,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Return',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: PriceChangeBadge(
                        changePercent: widget.summary.totalPnlPercent,
                        changeAmount: widget.summary.totalPnl,
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action Buttons: Quick Deposit & Quick Withdraw (Demo)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onDepositTap,
                  icon: const Icon(Icons.arrow_downward_rounded, size: 15),
                  label: const Text('Deposit Funds', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedMd,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onWithdrawTap,
                  icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                  label: const Text('Withdraw', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedMd,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
