import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/models/market_data_models.dart';
import '../../markets/providers/market_provider.dart';
import '../../profile/providers/account_provider.dart';
import '../../stock_details/presentation/widgets/interactive_stock_chart.dart';
import '../../stock_details/presentation/widgets/order_book_widget.dart';
import '../models/trading_models.dart';
import '../providers/trading_provider.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen> with SingleTickerProviderStateMixin {
  String _selectedSymbol = 'OGDC';
  OrderSide _orderSide = OrderSide.buy;
  OrderType _orderType = OrderType.market;

  final _quantityController = TextEditingController(text: '100');
  final _limitPriceController = TextEditingController();

  bool _isExecuting = false;

  final List<String> _popularTickers = [
    'OGDC',
    'LUCK',
    'HUBC',
    'ENGRO',
    'SYS',
    'HBL',
    'PSO',
    'MCB',
    'FFC',
    'TRG',
  ];

  @override
  void dispose() {
    _quantityController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  Future<void> _executeTrade(StockQuote stock, double currentPrice) async {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be greater than 0')),
      );
      return;
    }

    final price = _orderType == OrderType.limit
        ? (double.tryParse(_limitPriceController.text) ?? currentPrice)
        : currentPrice;

    setState(() => _isExecuting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 500));

    final notifier = ref.read(tradingProvider.notifier);
    String? orderId;

    if (_orderSide == OrderSide.buy) {
      orderId = await notifier.placeBuyOrder(
        symbol: stock.symbol,
        stockName: stock.name,
        sector: stock.sector,
        quantity: qty,
        price: price,
        orderType: _orderType,
      );
    } else {
      orderId = await notifier.placeSellOrder(
        symbol: stock.symbol,
        quantity: qty,
        price: price,
        orderType: _orderType,
      );
    }

    if (mounted) {
      setState(() => _isExecuting = false);
      if (orderId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_orderSide == OrderSide.buy ? "Bought" : "Sold"} $qty shares of ${stock.symbol} @ Rs. ${price.toStringAsFixed(2)}',
            ),
            backgroundColor: _orderSide == OrderSide.buy ? AppColors.success : AppColors.danger,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order failed: Insufficient funds or shares available'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final marketState = ref.watch(marketProvider);
    final portfolio = ref.watch(tradingProvider);
    final account = ref.watch(accountProvider);

    // Find current stock from market data or use fallback
    StockQuote? stock;
    for (var g in marketState.overview.topGainers) {
      if (g.symbol == _selectedSymbol) {
        stock = StockQuote(
          symbol: g.symbol,
          name: g.name,
          sector: 'Commercial/Industrial',
          price: g.price,
          change: g.change,
          changePercent: g.changePercent,
          volume: 1200000,
          marketCap: 45.0,
          peRatio: 6.2,
          dividendYield: 7.5,
          sparkline: [g.price * 0.98, g.price * 0.99, g.price],
        );
      }
    }
    for (var l in marketState.overview.topLosers) {
      if (l.symbol == _selectedSymbol) {
        stock = StockQuote(
          symbol: l.symbol,
          name: l.name,
          sector: 'Commercial/Industrial',
          price: l.price,
          change: l.change,
          changePercent: l.changePercent,
          volume: 850000,
          marketCap: 32.0,
          peRatio: 5.8,
          dividendYield: 6.1,
          sparkline: [l.price * 1.02, l.price * 1.01, l.price],
        );
      }
    }

    stock ??= StockQuote(
      symbol: _selectedSymbol,
      name: '$_selectedSymbol Limited',
      sector: 'Commercial/Industrial',
      price: _selectedSymbol == 'OGDC'
          ? 154.20
          : _selectedSymbol == 'LUCK'
              ? 840.50
              : _selectedSymbol == 'HUBC'
                  ? 128.40
                  : 250.00,
      change: 4.80,
      changePercent: 3.21,
      volume: 1250000,
      marketCap: 45.0,
      peRatio: 5.4,
      dividendYield: 8.2,
      sparkline: [150.0, 152.0, 151.0, 153.0, 154.2],
    );

    final currentPrice = stock.price;
    final qty = int.tryParse(_quantityController.text) ?? 100;
    final double targetPrice = _orderType == OrderType.limit
        ? (double.tryParse(_limitPriceController.text) ?? currentPrice)
        : currentPrice;
    final estimatedTotal = qty * targetPrice;
    final brokerageFee = (estimatedTotal * 0.0015).clamp(25.0, double.infinity);
    final grandTotal = _orderSide == OrderSide.buy
        ? estimatedTotal + brokerageFee
        : estimatedTotal - brokerageFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.candlestick_chart_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Trade Terminal',
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: account.isRealMode ? AppColors.successLight : AppColors.warningLight,
                borderRadius: AppRadius.roundedXs,
              ),
              child: Row(
                children: [
                  Icon(
                    account.isRealMode ? Icons.shield_rounded : Icons.code_rounded,
                    color: account.isRealMode ? AppColors.success : AppColors.warning,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    account.isRealMode ? 'Real Mode' : 'Demo Mode',
                    style: AppTypography.labelSmall.copyWith(
                      color: account.isRealMode ? AppColors.success : AppColors.warning,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticker Selector Horizontal List
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _popularTickers.length,
                separatorBuilder: (c, i) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final sym = _popularTickers[index];
                  final isSelected = sym == _selectedSymbol;
                  return ChoiceChip(
                    label: Text(sym, style: const TextStyle(fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedSymbol = sym;
                          _limitPriceController.clear();
                        });
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Stock Header Card with Live Chart
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stock.symbol,
                            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            stock.name,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${currency.format(stock.price)}',
                            style: AppTypography.financialLarge.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          PriceChangeBadge(
                            changeAmount: stock.change,
                            changePercent: stock.changePercent,
                          ),
                        ],
                      ),
                    ],
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

            // Trading Panel Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buy / Sell Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _orderSide = OrderSide.buy),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _orderSide == OrderSide.buy ? AppColors.success : Colors.transparent,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Center(
                                child: Text(
                                  'BUY ${stock.symbol}',
                                  style: TextStyle(
                                    color: _orderSide == OrderSide.buy ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _orderSide = OrderSide.sell),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _orderSide == OrderSide.sell ? AppColors.danger : Colors.transparent,
                                borderRadius: AppRadius.roundedSm,
                              ),
                              child: Center(
                                child: Text(
                                  'SELL ${stock.symbol}',
                                  style: TextStyle(
                                    color: _orderSide == OrderSide.sell ? Colors.white : AppColors.textSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Order Type Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order Type', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Market'),
                            selected: _orderType == OrderType.market,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _orderType == OrderType.market ? Colors.white : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _orderType = OrderType.market);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Limit'),
                            selected: _orderType == OrderType.limit,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: _orderType == OrderType.limit ? Colors.white : AppColors.textPrimary,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _orderType = OrderType.limit);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Quantity Input
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Number of Shares',
                      prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                      border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Quick Quantity Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [50, 100, 500, 1000].map((count) {
                      return ActionChip(
                        label: Text('+$count', style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          final cur = int.tryParse(_quantityController.text) ?? 0;
                          setState(() => _quantityController.text = (cur + count).toString());
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (_orderType == OrderType.limit) ...[
                    TextField(
                      controller: _limitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Limit Price (PKR)',
                        hintText: currentPrice.toStringAsFixed(2),
                        prefixIcon: const Icon(Icons.price_change_outlined),
                        border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Summary Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        _buildRow('Estimated Subtotal', 'Rs. ${currency.format(estimatedTotal)}'),
                        const SizedBox(height: 4),
                        _buildRow('PSX Brokerage (0.15%)', 'Rs. ${currency.format(brokerageFee)}'),
                        const Divider(height: 12),
                        _buildRow(
                          'Estimated Total',
                          'Rs. ${currency.format(grandTotal)}',
                          isBold: true,
                        ),
                        const SizedBox(height: 4),
                        _buildRow(
                          'Available Cash',
                          'Rs. ${currency.format(portfolio.availableCash)}',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  PrimaryButton(
                    label: '${_orderSide == OrderSide.buy ? "BUY" : "SELL"} $qty SHARES',
                    backgroundColor: _orderSide == OrderSide.buy ? AppColors.success : AppColors.danger,
                    isLoading: _isExecuting,
                    onPressed: () => _executeTrade(stock!, currentPrice),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Order Book Widget
            _buildSectionHeader('Live Depth / Order Book'),
            OrderBookWidget(
              symbol: stock.symbol,
              currentPrice: stock.price,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Recent Orders
            _buildSectionHeader('Your Recent Orders'),
            AppCard(
              padding: EdgeInsets.zero,
              child: portfolio.orders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No orders placed yet. Execute your first trade above!',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: portfolio.orders.take(5).length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final ord = portfolio.orders[idx];
                        final isBuy = ord.side == OrderSide.buy;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isBuy ? AppColors.successLight : AppColors.dangerLight,
                            child: Icon(
                              isBuy ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isBuy ? AppColors.success : AppColors.danger,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            '${ord.side.name.toUpperCase()} ${ord.quantity} ${ord.symbol}',
                            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${ord.type.name.toUpperCase()} • Rs. ${currency.format(ord.price)}',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ord.status == OrderStatus.executed ? AppColors.successLight : AppColors.warningLight,
                              borderRadius: AppRadius.roundedXs,
                            ),
                            child: Text(
                              ord.status.name.toUpperCase(),
                              style: TextStyle(
                                color: ord.status == OrderStatus.executed ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
