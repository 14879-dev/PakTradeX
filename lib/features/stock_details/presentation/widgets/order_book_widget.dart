import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class OrderBookWidget extends StatelessWidget {
  final String symbol;
  final double currentPrice;

  const OrderBookWidget({
    super.key,
    required this.symbol,
    required this.currentPrice,
  });

  List<OrderBookLevel> _generateBids() {
    return [
      OrderBookLevel(price: currentPrice - 0.20, volume: 4500, ordersCount: 8),
      OrderBookLevel(price: currentPrice - 0.50, volume: 8200, ordersCount: 14),
      OrderBookLevel(price: currentPrice - 0.80, volume: 6100, ordersCount: 10),
      OrderBookLevel(price: currentPrice - 1.20, volume: 12400, ordersCount: 19),
      OrderBookLevel(price: currentPrice - 1.80, volume: 9800, ordersCount: 16),
    ];
  }

  List<OrderBookLevel> _generateAsks() {
    return [
      OrderBookLevel(price: currentPrice + 0.20, volume: 3200, ordersCount: 6),
      OrderBookLevel(price: currentPrice + 0.50, volume: 7100, ordersCount: 12),
      OrderBookLevel(price: currentPrice + 0.90, volume: 5400, ordersCount: 9),
      OrderBookLevel(price: currentPrice + 1.30, volume: 10200, ordersCount: 17),
      OrderBookLevel(price: currentPrice + 1.90, volume: 8700, ordersCount: 14),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bids = _generateBids();
    final asks = _generateAsks();
    final maxVolume = [...bids, ...asks]
        .map((e) => e.volume)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bids (Buyers)',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.success),
                ),
                Text(
                  'Price',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Asks (Sellers)',
                  style: AppTypography.labelMedium.copyWith(color: AppColors.danger),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Order Levels
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              final bid = bids[index];
              final ask = asks[index];
              final bidFill = bid.volume / maxVolume;
              final askFill = ask.volume / maxVolume;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  children: [
                    // Bid side
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: FractionallySizedBox(
                                widthFactor: bidFill,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.roundedXs,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            child: Text(
                              '${(bid.volume / 1000).toStringAsFixed(1)}K',
                              style: AppTypography.financialSmall.copyWith(
                                color: AppColors.success,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Center Price
                    Container(
                      width: 72,
                      alignment: Alignment.center,
                      child: Text(
                        bid.price.toStringAsFixed(2),
                        style: AppTypography.financialSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    // Ask side
                    Expanded(
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: askFill,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.1),
                                    borderRadius: AppRadius.roundedXs,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            child: Text(
                              '${(ask.volume / 1000).toStringAsFixed(1)}K',
                              style: AppTypography.financialSmall.copyWith(
                                color: AppColors.danger,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class OrderBookLevel {
  final double price;
  final int volume;
  final int ordersCount;

  const OrderBookLevel({
    required this.price,
    required this.volume,
    required this.ordersCount,
  });
}
