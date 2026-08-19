import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../home/data/mock_market_data.dart';
import '../../trading/providers/trading_provider.dart';
import 'widgets/deposit_cash_modal.dart';
import 'widgets/holdings_list.dart';
import 'widgets/order_history_list.dart';
import 'widgets/sector_allocation_pie_chart.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDepositModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DepositCashModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final portfolio = ref.watch(tradingProvider);
    final isProfit = portfolio.totalUnrealizedPnl >= 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Investment Portfolio',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: 'Deposit Demo Cash',
            onPressed: _showDepositModal,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Portfolio Valuation Card
            AppCard(
              backgroundColor: AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Portfolio Value',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Text(
                          'DEMO PORTFOLIO',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Rs. ${currency.format(portfolio.totalPortfolioValue)}',
                    style: AppTypography.financialLarge.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Metrics Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWhiteStat('Invested Capital', 'Rs. ${currency.format(portfolio.totalInvested)}'),
                      _buildWhiteStat('Available Cash', 'Rs. ${currency.format(portfolio.availableCash)}'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: AppSpacing.xs),

                  // Total Unrealized P&L
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Unrealized P&L',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                      Text(
                        '${isProfit ? '+' : ''}Rs. ${currency.format(portfolio.totalUnrealizedPnl)} (${isProfit ? '+' : ''}${portfolio.totalPnlPercent.toStringAsFixed(2)}%)',
                        style: AppTypography.financialSmall.copyWith(
                          color: isProfit ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Quick Actions Bar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDepositModal,
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    label: const Text('Deposit Funds'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/markets'),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                    label: const Text('Trade Stocks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.roundedMd,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Asset & Sector Allocation
            SectionHeader(title: 'Asset Allocation Breakdown'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              child: SectorAllocationPieChart(
                holdings: portfolio.holdings,
                availableCash: portfolio.availableCash,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tab Bar for Holdings & Order History
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.labelLarge,
                tabs: [
                  Tab(text: 'Holdings (${portfolio.holdings.length})'),
                  Tab(text: 'Order History (${portfolio.orders.length})'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Content
            AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return HoldingsList(
                    holdings: portfolio.holdings,
                    onStockTap: (holding) {
                      final quote = MockMarketData.allStocks.firstWhere(
                        (s) => s.symbol == holding.symbol,
                        orElse: () => MockMarketData.allStocks.first,
                      );
                      context.go('/home/stock/${holding.symbol}', extra: quote);
                    },
                  );
                } else {
                  return OrderHistoryList(orders: portfolio.orders);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
