import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../home/data/mock_market_data.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final portfolio = MockMarketData.demoPortfolio;

    final holdings = [
      {'symbol': 'MCB', 'name': 'MCB Bank Ltd', 'shares': 1200, 'avgBuy': 290.00, 'currentPrice': 322.40, 'sector': 'Banking'},
      {'symbol': 'ENGRO', 'name': 'Engro Corporation', 'shares': 800, 'avgBuy': 440.00, 'currentPrice': 481.20, 'sector': 'Fertilizer'},
      {'symbol': 'OGDC', 'name': 'Oil & Gas Dev Co', 'shares': 1500, 'avgBuy': 295.00, 'currentPrice': 287.50, 'sector': 'Oil & Gas'},
      {'symbol': 'SYS', 'name': 'Systems Limited', 'shares': 350, 'avgBuy': 420.00, 'currentPrice': 462.90, 'sector': 'Technology'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Investment Portfolio',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Portfolio Card
            AppCard(
              backgroundColor: AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Balance',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Text(
                          'DEMO MODE',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${currency.format(portfolio.totalBalance)}',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildWhiteStat('Invested', 'Rs. ${currency.format(portfolio.investedAmount)}'),
                      _buildWhiteStat('Available Cash', 'Rs. ${currency.format(portfolio.cashBalance)}'),
                      _buildWhiteStat('Total Return', '+${portfolio.totalPnlPercent}%'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // AI Portfolio Health
            AppCard(
              border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'AI Portfolio Health & Risk Analysis',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Health Score: 78/100 (Well Diversified)',
                    style: AppTypography.labelLarge.copyWith(color: AppColors.success),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your portfolio holds healthy high-dividend banking assets (MCB) and growth technology (SYS). Energy sector exposure (OGDC) currently faces short-term commodity pullback.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Holdings List Header
            Text(
              'Your Holdings (${holdings.length})',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Holdings List
            ...holdings.map((h) {
              final shares = h['shares'] as int;
              final currentPrice = h['currentPrice'] as double;
              final avgBuy = h['avgBuy'] as double;
              final totalVal = shares * currentPrice;
              final pnl = (currentPrice - avgBuy) * shares;
              final pnlPercent = ((currentPrice - avgBuy) / avgBuy) * 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h['symbol'] as String,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '$shares shares @ Rs. ${avgBuy.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${currency.format(totalVal)}',
                            style: AppTypography.financialMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          PriceChangeBadge(
                            changePercent: pnlPercent,
                            changeAmount: pnl,
                            isCompact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWhiteStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: Colors.white60)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
