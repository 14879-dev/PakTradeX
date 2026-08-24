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
import '../../profile/providers/account_provider.dart';
import '../../trading/providers/trading_provider.dart';
import 'widgets/deposit_cash_modal.dart';
import 'widgets/holdings_list.dart';
import 'widgets/order_history_list.dart';
import 'widgets/sector_allocation_pie_chart.dart';
import 'widgets/withdraw_cash_modal.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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

  void _showWithdrawModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawCashModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final portfolio = ref.watch(tradingProvider);
    final account = ref.watch(accountProvider);
    final isProfit = portfolio.totalUnrealizedPnl >= 0;

    final isReal = account.isRealMode;
    final totalValue = isReal ? (account.realBalance + portfolio.totalInvested) : (account.demoBalance + portfolio.totalInvested);
    final availableCash = isReal ? account.realBalance : account.demoBalance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Investment Assets',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isReal ? const Color(0xFFC6F6D5) : const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isReal ? 'REAL PSX' : 'DEMO SANDBOX',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isReal ? const Color(0xFF22543D) : const Color(0xFF2B6CB0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            tooltip: 'Deposit Funds',
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
              backgroundColor: isReal ? const Color(0xFF1A365D) : AppColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isReal ? 'Real Portfolio Value (PKR)' : 'Demo Portfolio Value (PKR)',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: Text(
                          isReal ? (account.isKycVerified ? 'SECP VERIFIED ✅' : 'KYC REQUIRED ⚠️') : '1M VIRTUAL FUNDS',
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
                    'Rs. ${currency.format(totalValue)}',
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
                      _buildWhiteStat('Invested Equities', 'Rs. ${currency.format(portfolio.totalInvested)}'),
                      _buildWhiteStat('Available Cash', 'Rs. ${currency.format(availableCash)}'),
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

            // Quick Actions Bar (Deposit & Withdraw)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showDepositModal,
                    icon: const Icon(Icons.add_card_rounded, size: 18),
                    label: const Text('Deposit Funds'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showWithdrawModal,
                    icon: const Icon(Icons.account_balance_rounded, size: 18),
                    label: const Text('Withdraw Cash'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
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
                availableCash: availableCash,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Tab Bar for Holdings, Order History, Transactions
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
                  Tab(text: 'Orders (${portfolio.orders.length})'),
                  Tab(text: 'Ledger (${account.transactionHistory.length})'),
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
                } else if (_tabController.index == 1) {
                  return OrderHistoryList(orders: portfolio.orders);
                } else {
                  return _buildTransactionLedgerList(account, currency);
                }
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionLedgerList(AccountState account, NumberFormat currency) {
    if (account.transactionHistory.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFFA0AEC0)),
              SizedBox(height: 8),
              Text(
                'No deposit or withdrawal transactions yet.',
                style: TextStyle(color: Color(0xFF718096), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: account.transactionHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final txn = account.transactionHistory[index];
        final isDeposit = txn.type == 'deposit';

        return AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDeposit
                      ? const Color(0xFF38A169).withValues(alpha: 0.12)
                      : const Color(0xFFE53E3E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isDeposit ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${txn.timestamp.hour.toString().padLeft(2, '0')}:${txn.timestamp.minute.toString().padLeft(2, '0')} · ${txn.status}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                    ),
                  ],
                ),
              ),
              Text(
                '${isDeposit ? '+' : '-'}Rs. ${currency.format(txn.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDeposit ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                ),
              ),
            ],
          ),
        );
      },
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
