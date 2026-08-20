import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../features/home/models/market_data_models.dart';
import '../../../features/watchlist/providers/watchlist_provider.dart';
import 'widgets/interactive_stock_chart.dart';
import 'widgets/order_book_widget.dart';
import '../../trading/presentation/order_sheet.dart';

class StockDetailScreen extends ConsumerWidget {
  final StockQuote stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlist = ref.watch(watchlistProvider);
    final isWatchlisted = watchlist.contains(stock.symbol);
    final currency = NumberFormat('#,##0.00', 'en_US');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.symbol,
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              stock.sector,
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWatchlisted ? Icons.star_rounded : Icons.star_border_rounded,
              color: isWatchlisted ? AppColors.warning : AppColors.textSecondary,
              size: 26,
            ),
            tooltip: isWatchlisted ? 'Remove from Watchlist' : 'Add to Watchlist',
            onPressed: () {
              ref.read(watchlistProvider.notifier).toggle(stock.symbol);
              final msg = isWatchlisted
                  ? '${stock.symbol} removed from Watchlist'
                  : '${stock.symbol} added to Watchlist';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Header Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rs. ${currency.format(stock.price)}',
                            style: AppTypography.financialLarge.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          PriceChangeBadge(
                            changePercent: stock.changePercent,
                            changeAmount: stock.change,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Text(
                          'LIVE PSX',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Interactive Chart
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price History',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InteractiveStockChart(
                    symbol: stock.symbol,
                    currentPrice: stock.price,
                    changePercent: stock.changePercent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Key Statistics
            SectionHeader(title: 'Key Market Statistics'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStat('Volume', '${stock.volume.toStringAsFixed(1)}M shares')),
                      Expanded(child: _buildStat('Market Cap', 'Rs. ${stock.marketCap}B')),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: _buildStat('52W High', 'Rs. ${(stock.price * 1.28).toStringAsFixed(2)}')),
                      Expanded(child: _buildStat('52W Low', 'Rs. ${(stock.price * 0.72).toStringAsFixed(2)}')),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: _buildStat('Day High', 'Rs. ${(stock.price * 1.015).toStringAsFixed(2)}')),
                      Expanded(child: _buildStat('Day Low', 'Rs. ${(stock.price * 0.988).toStringAsFixed(2)}')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Fundamentals
            SectionHeader(title: 'Financial Fundamentals'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStat('P/E Ratio', '${stock.peRatio}x')),
                      Expanded(child: _buildStat('Dividend Yield', '${stock.dividendYield}%')),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(child: _buildStat('EPS (TTM)', 'Rs. ${(stock.price / stock.peRatio).toStringAsFixed(2)}')),
                      Expanded(child: _buildStat('Beta', '0.92')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Order Book
            SectionHeader(title: 'Market Depth (Order Book)'),
            const SizedBox(height: AppSpacing.sm),
            OrderBookWidget(
              symbol: stock.symbol,
              currentPrice: stock.price,
            ),
            const SizedBox(height: AppSpacing.md),

            // AI Analysis Banner
            AppCard(
              backgroundColor: AppColors.surface,
              border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.3)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.aiAccentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Analysis: ${stock.symbol}',
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Ask the AI Copilot to explain ${stock.name} fundamentals, risks, and investment thesis.',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for sticky bar
          ],
        ),
      ),

      // Sticky Buy / Sell Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showOrderSheet(context, ref, isBuy: true),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Buy Stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedMd,
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showOrderSheet(context, ref, isBuy: false),
                icon: const Icon(Icons.remove_rounded, size: 18),
                label: const Text('Sell Stock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedMd,
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: 3),
          Text(value, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context, WidgetRef ref, {required bool isBuy}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderSheet(
        stock: stock,
        initialBuy: isBuy,
      ),
    );
  }
}
