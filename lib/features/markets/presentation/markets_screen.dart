import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../home/data/mock_market_data.dart';
import '../../home/models/market_data_models.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  String _searchQuery = '';
  String _selectedSector = 'All';

  final List<String> _sectors = [
    'All',
    'Commercial Banks',
    'Fertilizer',
    'Technology',
    'Oil & Gas',
    'Cement',
    'Power',
  ];

  @override
  Widget build(BuildContext context) {
    final allStocks = [...MockMarketData.topGainers, ...MockMarketData.topLosers];
    final filtered = allStocks.where((s) {
      final matchesSearch = s.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSector = _selectedSector == 'All' || s.sector.toLowerCase().contains(_selectedSector.toLowerCase());
      return matchesSearch && matchesSector;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Pakistan Capital Markets',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search PSX Stocks (e.g. MCB, ENGRO, OGDC)...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Sector filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sectors.map((sector) {
                      final isSelected = _selectedSector == sector;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(sector),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedSector = sector);
                          },
                          selectedColor: AppColors.primaryLight,
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedSm,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stocks List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No stocks match "$_searchQuery"', style: AppTypography.bodyMedium),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final stock = filtered[index];
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          _showStockDetails(context, stock);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      stock.symbol,
                                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '• ${stock.sector}',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  stock.name,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs. ${stock.price.toStringAsFixed(2)}',
                                  style: AppTypography.financialMedium.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                PriceChangeBadge(
                                  changePercent: stock.changePercent,
                                  isCompact: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showStockDetails(BuildContext context, StockQuote stock) {
    context.go('/markets/stock/${stock.symbol}', extra: stock);
  }
}
