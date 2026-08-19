import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../trading/models/trading_models.dart';

class OrderHistoryList extends StatelessWidget {
  final List<TradeOrder> orders;

  const OrderHistoryList({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final dateFormat = DateFormat('MMM dd, hh:mm a');

    if (orders.isEmpty) {
      return AppCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: AppSpacing.sm),
                Text('No Trade Orders Yet', style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your simulated order executions will appear here in chronological order.',
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
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final order = orders[index];
        final isBuy = order.side == OrderSide.buy;
        final sideColor = isBuy ? AppColors.success : AppColors.danger;

        return AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sideColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: sideColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            order.symbol,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: sideColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.roundedXs,
                            ),
                            child: Text(
                              isBuy ? 'BUY' : 'SELL',
                              style: AppTypography.labelSmall.copyWith(
                                color: sideColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        dateFormat.format(order.createdAt),
                        style: AppTypography.bodySmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs. ${currency.format(order.totalValue)}',
                    style: AppTypography.financialMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${order.quantity} @ Rs. ${order.price.toStringAsFixed(1)} (Fee: Rs. ${order.fee.toStringAsFixed(0)})',
                    style: AppTypography.bodySmall.copyWith(fontSize: 10),
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
