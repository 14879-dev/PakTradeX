import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/price_change_badge.dart';
import '../../models/market_data_models.dart';

class MarketMoversCard extends StatefulWidget {
  final List<StockQuote> gainers;
  final List<StockQuote> losers;
  final ValueChanged<StockQuote>? onStockTap;

  const MarketMoversCard({
    super.key,
    required this.gainers,
    required this.losers,
    this.onStockTap,
  });

  @override
  State<MarketMoversCard> createState() => _MarketMoversCardState();
}

class _MarketMoversCardState extends State<MarketMoversCard> {
  int _selectedTabIndex = 0; // 0 = Top Gainers, 1 = Top Losers

  @override
  Widget build(BuildContext context) {
    final list = _selectedTabIndex == 0 ? widget.gainers : widget.losers;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Tab bar header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _buildTabButton(0, 'Top Gainers (${widget.gainers.length})'),
                const SizedBox(width: AppSpacing.sm),
                _buildTabButton(1, 'Top Losers (${widget.losers.length})'),
              ],
            ),
          ),
          const Divider(),

          // Stock list items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final stock = list[index];
              return InkWell(
                onTap: () => widget.onStockTap?.call(stock),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Symbol + Name + Sector
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stock.symbol,
                                  style: AppTypography.titleSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: AppRadius.roundedXs,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'P/E ${stock.peRatio}x',
                                    style: AppTypography.labelSmall.copyWith(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stock.name,
                              style: AppTypography.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Price + Change Badge
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${stock.price.toStringAsFixed(2)}',
                            style: AppTypography.financialMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          PriceChangeBadge(
                            changePercent: stock.changePercent,
                            isCompact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        borderRadius: AppRadius.roundedSm,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            borderRadius: AppRadius.roundedSm,
            border: isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.0)
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
