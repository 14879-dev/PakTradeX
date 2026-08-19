import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../trading/models/trading_models.dart';

class HoldingsList extends StatelessWidget {
  final List<HoldingPosition> holdings;
  final Function(HoldingPosition position)? onStockTap;

  const HoldingsList({
    super.key,
    required this.holdings,
    this.onStockTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');

    if (holdings.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.sm),
                Text('No Holdings Yet', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Explore PSX stocks in Markets and execute your first trade.',
                  style: AppTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: holdings.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final item = holdings[index];
        final isProfit = item.unrealizedPnl >= 0;
        final pnlColor = isProfit ? AppColors.success : AppColors.danger;

        return AppCard(
          padding: const EdgeInsets.all(14),
          onTap: () => onStockTap?.call(item),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.symbol,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppRadius.roundedXs,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              item.sector,
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(item.name, style: AppTypography.bodySmall),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${currency.format(item.totalCurrentValue)}',
                        style: AppTypography.financialMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${item.shares} shares @ Rs. ${item.currentPrice.toStringAsFixed(1)}',
                        style: AppTypography.labelSmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Avg Buy: Rs. ${item.avgBuyPrice.toStringAsFixed(2)}',
                    style: AppTypography.labelSmall.copyWith(fontSize: 11),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.1),
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Text(
                      '${isProfit ? '+' : ''}Rs. ${currency.format(item.unrealizedPnl)} (${isProfit ? '+' : ''}${item.pnlPercentage.toStringAsFixed(2)}%)',
                      style: AppTypography.financialSmall.copyWith(
                        color: pnlColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
