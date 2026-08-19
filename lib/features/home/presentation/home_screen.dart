import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';
import '../../markets/providers/market_provider.dart';
import '../../portfolio/presentation/widgets/deposit_cash_modal.dart';
import '../../portfolio/presentation/widgets/p2p_transfer_modal.dart';
import '../../profile/providers/account_provider.dart';
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
    final account = ref.watch(accountProvider);

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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: account.isRealMode ? AppColors.successLight : AppColors.warningLight,
                    borderRadius: AppRadius.roundedXs,
                  ),
                  child: Text(
                    account.isRealMode ? '💎 Real Account Active' : '🟢 Demo Mode (Rs. 1M)',
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 9,
                      color: account.isRealMode ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w800,
                    ),
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
          // Profile Avatar Action Button with KYC badge
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      'AR',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (account.isKycVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1.5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: AppColors.success,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
                        'Assalam-o-Alaikum, ${account.userName.split(" ").first} 👋',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ID: ${account.pakTradeId} • Pakistan Stock Exchange',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                  final displayCash = account.isRealMode ? account.realBalance : trading.availableCash;
                  final dynamicSummary = PortfolioSummary(
                    totalBalance: account.isRealMode ? displayCash + trading.totalInvested : trading.totalPortfolioValue,
                    investedAmount: trading.totalInvested,
                    cashBalance: displayCash,
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

              // Quick Action Chips (Markets, Trade Terminal, Send P2P, Portfolio)
              Row(
                children: [
                  _buildQuickAction(
                    context,
                    icon: Icons.candlestick_chart_rounded,
                    label: 'Trade',
                    onTap: () => context.go('/trade'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const P2pTransferModal(),
                      );
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.show_chart_rounded,
                    label: 'Markets',
                    onTap: () => context.go('/markets'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildQuickAction(
                    context,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Assets',
                    onTap: () => context.go('/portfolio'),
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
                    'Live Gemini AI',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.aiAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AiMarketBriefCard(
                brief: MockMarketData.dailyAiBrief,
                onAskCopilotTap: () => context.push('/ai'),
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

              // Compliance & Safety Notice
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
                          'PakTradeX SECP & PSX Compliance Notice',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real mode orders are routed via SECP-licensed CDC brokers. Demo mode orders are executed with virtual funds for educational simulation.',
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
