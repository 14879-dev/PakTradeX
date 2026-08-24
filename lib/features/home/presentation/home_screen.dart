import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
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

  void _showSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'PakTradeX 24/7 Support Desk',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Need assistance with PSX trades, Direct Pay transfers, or KYC onboarding? Our dedicated financial desk is here 24/7.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.4),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
              title: const Text('AI Market Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Instant answers powered by Gemini AI'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/ai');
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppColors.primary),
              title: const Text('Email Support', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('support@paktradex.pk'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Notifications (3)',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Dismiss All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildNotificationItem(
              icon: Icons.verified_user_rounded,
              color: AppColors.success,
              title: 'Account Security Active',
              time: '2m ago',
              desc: 'Email 2FA OTP verification is active for mmk521142@gmail.com',
            ),
            _buildNotificationItem(
              icon: Icons.trending_up_rounded,
              color: AppColors.primary,
              title: 'PSX Market Alert',
              time: '1h ago',
              desc: 'KSE-100 Index crossed 78,400 points driven by tech & banking rally.',
            ),
            _buildNotificationItem(
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.warning,
              title: 'Demo Wallet Ready',
              time: 'Today',
              desc: 'Rs. 1,000,000 virtual capital loaded for zero-risk trading.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider);
    final auth = ref.watch(authProvider);
    final displayName = auth.user?.fullName ?? account.userName;
    final initials = displayName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 12,
        leadingWidth: 54,
        // Clickable Left Profile Avatar (Opens Profile Page directly)
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => context.push('/profile'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initials.isNotEmpty ? initials : 'MU',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: account.isKycVerified ? AppColors.success : AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Center: Exchange / Wallet Toggle or Demo Switcher
        title: Container(
          height: 34,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => ref.read(accountProvider.notifier).switchMode(AccountMode.demo),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: account.isDemoMode ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: account.isDemoMode
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Demo 1M',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: account.isDemoMode ? FontWeight.w800 : FontWeight.w600,
                      color: account.isDemoMode ? AppColors.primary : const Color(0xFF718096),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(accountProvider.notifier).switchMode(AccountMode.real),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: account.isRealMode ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: account.isRealMode
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    'Real PSX',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: account.isRealMode ? FontWeight.w800 : FontWeight.w600,
                      color: account.isRealMode ? AppColors.success : const Color(0xFF718096),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        // Right Action Icons: Direct Pay (Scan), Support, Notification
        actions: [
          // Direct Pay / Scan QR
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2D3748), size: 21),
            tooltip: 'Direct Pay / Scan QR',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const P2pTransferModal(),
              );
            },
          ),
          // 24/7 Support
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF2D3748), size: 21),
            tooltip: '24/7 Support Desk',
            onPressed: () => _showSupportModal(context),
          ),
          // Notifications with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2D3748), size: 22),
                tooltip: 'Notifications',
                onPressed: () => _showNotificationsModal(context),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
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
              // Search PSX Stocks Hot Bar
              GestureDetector(
                onTap: () => context.go('/markets'),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search_rounded, size: 18, color: Color(0xFF718096)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🔥 KSE-100 breaks 78,400 · Search PSX Stocks',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF718096),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.qr_code_scanner_rounded, size: 18, color: Color(0xFF718096)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 1. Estimated Total Value Balance Card with Quick "Add Funds"
              Builder(
                builder: (context) {
                  final trading = ref.watch(tradingProvider);
                  final displayCash = account.isRealMode ? account.realBalance : trading.availableCash;
                  final dynamicSummary = PortfolioSummary(
                    totalBalance: account.isRealMode
                        ? displayCash + trading.totalInvested
                        : trading.totalPortfolioValue,
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

              // 2. Clean Shortcuts Grid (No competition or referral)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShortcutItem(
                    context: context,
                    icon: Icons.swap_horiz_rounded,
                    label: 'P2P Pay',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const P2pTransferModal(),
                      );
                    },
                  ),
                  _buildShortcutItem(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Deposit',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const DepositCashModal(),
                      );
                    },
                  ),
                  _buildShortcutItem(
                    context: context,
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Copilot',
                    onTap: () => context.push('/ai'),
                  ),
                  _buildShortcutItem(
                    context: context,
                    icon: Icons.verified_rounded,
                    label: 'Shariah (KMI)',
                    onTap: () => context.go('/markets'),
                  ),
                  _buildShortcutItem(
                    context: context,
                    icon: Icons.candlestick_chart_rounded,
                    label: 'Trade',
                    onTap: () => context.go('/trade'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // 3. Market Overview (KSE-100)
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

              // 4. AI Market Brief
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

              // 5. Market Movers (Gainers / Losers with Live Real-Time Data)
              SectionHeader(
                title: 'Market Movers',
                actionLabel: 'View All',
                onActionTap: () => context.go('/markets'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Builder(
                builder: (context) {
                  final marketState = ref.watch(marketProvider);
                  final gainers = marketState.overview.topGainers.isNotEmpty
                      ? marketState.overview.topGainers
                      : MockMarketData.topGainers;
                  final losers = marketState.overview.topLosers.isNotEmpty
                      ? marketState.overview.topLosers
                      : MockMarketData.topLosers;

                  return MarketMoversCard(
                    gainers: gainers,
                    losers: losers,
                    onStockTap: (stock) {
                      context.go('/home/stock/${stock.symbol}', extra: stock);
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // 6. Recent Financial News
              SectionHeader(
                title: 'PSX Market News',
                actionLabel: 'More News',
                onActionTap: () => context.push('/news'),
              ),
              const SizedBox(height: AppSpacing.sm),
              RecentNewsCard(
                newsList: MockMarketData.latestNews,
                onNewsTap: (news) => context.push('/news'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}
