import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';
import '../../markets/providers/market_provider.dart';
import '../../portfolio/presentation/widgets/deposit_cash_modal.dart';
import '../../trading/providers/trading_provider.dart';
import '../data/mock_market_data.dart';
import '../models/market_data_models.dart';
import 'widgets/ai_market_brief_card.dart';
import 'widgets/market_movers_card.dart';
import 'widgets/market_overview_card.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/recent_news_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.roundedSm,
              ),
              child: const Center(
                child: Text(
                  'PX',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'PakTrade',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: 'X',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'PSX Simulation Mode',
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 10,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () => context.go('/markets'),
            tooltip: 'Search Stocks',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assalam-o-Alaikum, Trader 👋',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Pakistan Stock Exchange is currently active',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 1. Portfolio Summary Card (Live Reactive)
              Builder(
                builder: (context) {
                  final trading = ref.watch(tradingProvider);
                  final dynamicSummary = PortfolioSummary(
                    totalBalance: trading.totalPortfolioValue,
                    investedAmount: trading.totalInvested,
                    cashBalance: trading.availableCash,
                    todaysPnl: trading.totalUnrealizedPnl,
                    todaysPnlPercent: trading.totalPnlPercent,
                    totalPnl: trading.totalUnrealizedPnl,
                    totalPnlPercent: trading.totalPnlPercent,
                  );

                  return PortfolioSummaryCard(
                    summary: dynamicSummary,
                    onDepositTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const DepositCashModal(),
                      );
                    },
                    onWithdrawTap: () => context.go('/portfolio'),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Quick Action Chips
              Row(
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.explore_outlined,
                    label: 'Markets',
                    onTap: () => context.go('/markets'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.auto_awesome_outlined,
                    label: 'AI Copilot',
                    onTap: () => context.go('/ai'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.pie_chart_outline_rounded,
                    label: 'Portfolio',
                    onTap: () => context.go('/portfolio'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 2. Market Overview (KSE-100)
              SectionHeader(
                title: 'Market Overview',
                actionLabel: 'All Indices',
                onActionTap: () => context.go('/markets'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Builder(
                builder: (context) {
                  final marketState = ref.watch(marketProvider);
                  final liveKse = MarketIndex(
                    symbol: 'KSE-100',
                    name: 'PSX Benchmark Index',
                    currentPoints: marketState.overview.kse100Level,
                    changePoints: marketState.overview.kse100Change,
                    changePercent: marketState.overview.kse100ChangePercent,
                    high: marketState.overview.kse100Level * 1.004,
                    low: marketState.overview.kse100Level * 0.994,
                    volume: 245.8,
                    status: 'Market Open',
                    sparkline: MockMarketData.kse100.sparkline,
                  );

                  return MarketOverviewCard(
                    index: liveKse,
                    onTap: () => context.go('/markets'),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. AI Market Brief
              SectionHeader(
                title: 'AI Intelligence',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.aiAccentLight,
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Text(
                    'Updated 10m ago',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.aiAccent,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AiMarketBriefCard(
                brief: MockMarketData.dailyAiBrief,
                onAskCopilotTap: () => context.go('/ai'),
              ),
              const SizedBox(height: AppSpacing.xl),

              // 4. Market Movers
              SectionHeader(
                title: 'Market Movers',
                actionLabel: 'View Screener',
                onActionTap: () => context.go('/markets'),
              ),
              const SizedBox(height: AppSpacing.sm),
              MarketMoversCard(
                gainers: MockMarketData.topGainers,
                losers: MockMarketData.topLosers,
                onStockTap: (stock) {
                  _showStockBottomSheet(context, stock);
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 5. Financial News
              SectionHeader(
                title: 'Market News & Catalysts',
                actionLabel: 'More News',
                onActionTap: () => context.push('/news'),
              ),
              const SizedBox(height: AppSpacing.sm),
              RecentNewsCard(
                newsList: MockMarketData.latestNews,
                onNewsTap: (news) => context.push('/news'),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Compliance & Regulatory Notice Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.roundedMd,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'PakTradeX Simulation & Safety Notice',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'This environment runs in sandbox simulation mode. PakTradeX is a modern investment platform connecting users to authorized brokerage channels. No real-money trades are executed in demo mode.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedMd,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStockBottomSheet(BuildContext context, dynamic stock) {
    context.go('/home/stock/${stock.symbol}', extra: stock);
  }

}
