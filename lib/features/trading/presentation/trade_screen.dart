import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/data/mock_market_data.dart';
import '../../home/models/market_data_models.dart';
import '../../markets/providers/market_provider.dart';
import '../../portfolio/presentation/widgets/deposit_cash_modal.dart';
import '../../profile/presentation/widgets/kyc_verification_modal.dart';
import '../../profile/providers/account_provider.dart';
import '../../stock_details/presentation/widgets/interactive_stock_chart.dart';
import '../models/trading_models.dart';
import '../providers/trading_provider.dart';

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _subTabController;
  String _selectedSymbol = 'SYS';
  OrderSide _orderSide = OrderSide.buy;
  OrderType _orderType = OrderType.market;
  bool _isTotalMode = true; // Total (PKR) or Amount (Shares)

  final _amountController = TextEditingController(text: '10000');
  final _limitPriceController = TextEditingController(text: '462.90');

  double _sliderPercent = 0.25; // 0, 0.25, 0.50, 0.75, 1.0
  bool _isExecuting = false;
  bool _showPromoBanner = true;
  bool _showBottomChart = false;
  int _orderManagementTab = 0; // 0: Open Orders, 1: Positions, 2: Strategies

  final List<String> _subTabs = [
    'RealStocks',
    'Spot',
    'Futures',
    'Predictions',
  ];

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: _subTabs.length, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _amountController.dispose();
    _limitPriceController.dispose();
    super.dispose();
  }

  StockQuote _getStock(MarketState marketState) {
    final list = marketState.overview.allStocks.isNotEmpty
        ? marketState.overview.allStocks
        : MockMarketData.allPsxStocks;
    return list.firstWhere(
      (s) => s.symbol == _selectedSymbol,
      orElse: () => list.first,
    );
  }

  void _openStockPickerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select PSX Stock',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: MockMarketData.allPsxStocks.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final stock = MockMarketData.allPsxStocks[index];
                    final isSelected = stock.symbol == _selectedSymbol;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      title: Text(
                        '${stock.symbol}/PKR',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? AppColors.primary : const Color(0xFF1A202C),
                        ),
                      ),
                      subtitle: Text(
                        stock.name,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Rs. ${stock.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${stock.changePercent >= 0 ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: stock.changePercent >= 0 ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSymbol = stock.symbol;
                          _limitPriceController.text = stock.price.toStringAsFixed(2);
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSliderChanged(double val, double maxBudget, double stockPrice) {
    setState(() {
      _sliderPercent = val;
      final allocated = maxBudget * val;
      if (_isTotalMode) {
        _amountController.text = allocated.toStringAsFixed(0);
      } else {
        final shares = (allocated / (stockPrice > 0 ? stockPrice : 100)).floor();
        _amountController.text = shares.toString();
      }
    });
  }

  Future<void> _handleExecuteTrade(StockQuote stock) async {
    final account = ref.read(accountProvider);
    final numVal = double.tryParse(_amountController.text) ?? 0;
    if (numVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount or shares quantity')),
      );
      return;
    }

    final int quantity = _isTotalMode
        ? (numVal / (stock.price > 0 ? stock.price : 100)).floor().clamp(1, 999999)
        : numVal.toInt();

    final price = _orderType == OrderType.limit
        ? (double.tryParse(_limitPriceController.text) ?? stock.price)
        : stock.price;

    final totalCost = price * quantity;

    // Real Mode KYC & Balance Protection
    if (account.isRealMode) {
      if (!account.isKycVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFD69E2E),
            content: Text('1-Time SECP KYC Verification Required before trading in Real mode.'),
          ),
        );
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const KycVerificationModal(),
        );
        return;
      }

      if (_orderSide == OrderSide.buy && account.realBalance < totalCost) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE53E3E),
            content: Text('Insufficient real balance (Rs. ${account.realBalance.toStringAsFixed(2)}). Please deposit funds.'),
          ),
        );
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const DepositCashModal(),
        );
        return;
      }
    }

    setState(() => _isExecuting = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    final notifier = ref.read(tradingProvider.notifier);
    String? orderId;

    if (_orderSide == OrderSide.buy) {
      orderId = await notifier.placeBuyOrder(
        symbol: stock.symbol,
        stockName: stock.name,
        sector: stock.sector,
        quantity: quantity,
        price: price,
        orderType: _orderType,
      );
    } else {
      orderId = await notifier.placeSellOrder(
        symbol: stock.symbol,
        quantity: quantity,
        price: price,
        orderType: _orderType,
      );
    }

    if (mounted) {
      setState(() => _isExecuting = false);
      if (orderId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _orderSide == OrderSide.buy ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
            content: Text(
              '${_orderSide == OrderSide.buy ? "Buy" : "Sell"} Order Executed: $quantity shares of ${stock.symbol} at Rs. ${price.toStringAsFixed(2)}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0.00', 'en_US');
    final marketState = ref.watch(marketProvider);
    final account = ref.watch(accountProvider);
    final stock = _getStock(marketState);
    final portfolio = ref.watch(tradingProvider);
    final isBuy = _orderSide == OrderSide.buy;
    final availableCash = account.isRealMode ? account.realBalance : account.demoBalance;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Sub-Navigation Tabs Bar
            _buildTopSubTabsBar(account),

            // 2. Asset Header
            _buildAssetHeader(stock),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // 3. Scrollable Trade Grid & Order Management
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Main 2-Column Split (Left: Trade Inputs / Right: Live Order Book)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Buy/Sell, Order Type, Price, Amount, Slider, Buy Button
                          Expanded(
                            flex: 56,
                            child: _buildLeftTradingControls(stock, portfolio, availableCash, currency),
                          ),

                          const SizedBox(width: 14),

                          // Right Column: Live Order Book with Red/Green Depth Rows
                          Expanded(
                            flex: 44,
                            child: _buildRightOrderBook(stock),
                          ),
                        ],
                      ),
                    ),

                    // 4. Promo Banner
                    if (_showPromoBanner) _buildGalaPromoBanner(),

                    const SizedBox(height: 8),

                    // 5. Bottom Order Management
                    _buildOrderManagementSection(portfolio, currency),

                    const SizedBox(height: 14),

                    // 6. Expandable Live Candlestick Chart Bar at Bottom
                    _buildCollapsibleChartBar(stock),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Top Sub-Tabs Bar with Live Real / Demo Account Mode Badge ───
  Widget _buildTopSubTabsBar(AccountState account) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Mode Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: account.isRealMode ? const Color(0xFFC6F6D5) : const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                account.isRealMode ? 'REAL PSX' : 'DEMO 1M',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: account.isRealMode ? const Color(0xFF22543D) : const Color(0xFF2B6CB0),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // RealStocks with blue NEW badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Text(
                  'RealStocks',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF718096)),
                ),
                Positioned(
                  top: -7,
                  right: -22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3182CE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 28),
            const Text(
              'Spot',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
            ),
            const SizedBox(width: 18),
            const Text(
              'Futures',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: Color(0xFF718096)),
            ),
            const SizedBox(width: 18),
            const Text(
              'Predictions',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: Color(0xFF718096)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Asset Header (LINK/USDT style) ────────────────────────────
  Widget _buildAssetHeader(StockQuote stock) {
    final isPos = stock.changePercent >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          // Symbol Selector with Down Arrow
          InkWell(
            onTap: _openStockPickerModal,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Text(
                  '${stock.symbol}/PKR',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down_rounded, size: 24, color: Color(0xFF1A202C)),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Price Change Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${isPos ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
              ),
            ),
          ),

          const Spacer(),

          // 300X / Leverage Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF8FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Text(
                  'MTS 3X',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Color(0xFF3182CE)),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_right_rounded, size: 14, color: Color(0xFF3182CE)),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Candlestick Icon (Toggles Chart)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.candlestick_chart_rounded,
              size: 22,
              color: _showBottomChart ? const Color(0xFF3182CE) : const Color(0xFF718096),
            ),
            onPressed: () => setState(() => _showBottomChart = !_showBottomChart),
          ),
          const SizedBox(width: 12),

          // More options menu
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.more_horiz_rounded, size: 22, color: Color(0xFF718096)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PSX Order Options & Quick Alerts menu')),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── 3. Left Column: Trade Inputs ─────────────────────────────────
  Widget _buildLeftTradingControls(StockQuote stock, dynamic portfolio, double availableCash, NumberFormat currency) {
    final isBuy = _orderSide == OrderSide.buy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buy / Sell Tabs Switcher
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _orderSide = OrderSide.buy),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isBuy ? const Color(0xFF38A169) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Buy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isBuy ? Colors.white : const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _orderSide = OrderSide.sell),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !isBuy ? const Color(0xFFE53E3E) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sell',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: !isBuy ? Colors.white : const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Order Type Dropdown (Market / Limit)
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFA0AEC0)),
              DropdownButton<OrderType>(
                value: _orderType,
                underline: const SizedBox(),
                isDense: true,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF1A202C)),
                items: const [
                  DropdownMenuItem(value: OrderType.market, child: Text('Market Order')),
                  DropdownMenuItem(value: OrderType.limit, child: Text('Limit Order')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _orderType = val);
                },
              ),
              const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF718096)),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Price Input Field
        Container(
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF2F7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: _orderType == OrderType.market
              ? Text(
                  'Market Price ≈ Rs. ${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4A5568)),
                )
              : TextField(
                  controller: _limitPriceController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
        ),
        const SizedBox(height: 8),

        // Amount / Total Tab Toggle
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isTotalMode = false),
                child: Text(
                  'Amount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: !_isTotalMode ? FontWeight.w800 : FontWeight.w500,
                    color: !_isTotalMode ? const Color(0xFF1A202C) : const Color(0xFF718096),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isTotalMode = true),
                child: Text(
                  'Total',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: _isTotalMode ? FontWeight.w800 : FontWeight.w500,
                    color: _isTotalMode ? const Color(0xFF1A202C) : const Color(0xFF718096),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Stepper Input Box: [—] Total (PKR) [+]
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.remove, size: 16, color: Color(0xFF718096)),
                onPressed: () {
                  final cur = double.tryParse(_amountController.text) ?? 0;
                  final step = _isTotalMode ? 1000 : 10;
                  if (cur > step) {
                    setState(() => _amountController.text = (cur - step).toStringAsFixed(0));
                  }
                },
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: _isTotalMode ? 'Total (PKR)' : 'Shares',
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF718096)),
                onPressed: () {
                  final cur = double.tryParse(_amountController.text) ?? 0;
                  final step = _isTotalMode ? 1000 : 10;
                  setState(() => _amountController.text = (cur + step).toStringAsFixed(0));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Slider (0% - 25% - 50% - 75% - 100%)
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: const Color(0xFFCBD5E0),
            inactiveTrackColor: const Color(0xFFEDF2F7),
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: _sliderPercent,
            divisions: 4,
            onChanged: (val) => _onSliderChanged(val, availableCash, stock.price),
          ),
        ),
        const SizedBox(height: 6),

        // Available Balance Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Text(
                  'Avail.',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF718096), fontWeight: FontWeight.w500),
                ),
                Icon(Icons.arrow_drop_down, size: 14, color: Color(0xFF718096)),
              ],
            ),
            Row(
              children: [
                Text(
                  '${currency.format(availableCash)} PKR',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const DepositCashModal(),
                    );
                  },
                  child: const Icon(Icons.add_circle_outline_rounded, size: 14, color: Color(0xFF3182CE)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Huge Action Button: Buy / Sell Stock
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _isExecuting ? null : () => _handleExecuteTrade(stock),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBuy ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isExecuting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    '${isBuy ? "Buy" : "Sell"} ${stock.symbol}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ],
    );
  }

  // ── 4. Right Column: Pro Live Order Book ─────────────────────────
  Widget _buildRightOrderBook(StockQuote stock) {
    final asks = [
      {'price': stock.price + 0.35, 'amount': 626.34, 'depth': 0.85},
      {'price': stock.price + 0.25, 'amount': 73.32, 'depth': 0.25},
      {'price': stock.price + 0.15, 'amount': 66.63, 'depth': 0.22},
      {'price': stock.price + 0.10, 'amount': 97.55, 'depth': 0.35},
      {'price': stock.price + 0.05, 'amount': 7.15, 'depth': 0.08},
    ];

    final bids = [
      {'price': stock.price - 0.05, 'amount': 36.24, 'depth': 0.18},
      {'price': stock.price - 0.10, 'amount': 58.53, 'depth': 0.30},
      {'price': stock.price - 0.20, 'amount': 279.34, 'depth': 0.70},
      {'price': stock.price - 0.30, 'amount': 368.02, 'depth': 0.88},
      {'price': stock.price - 0.45, 'amount': 147.90, 'depth': 0.50},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column Headers: Price (PKR) | Amount (Shares)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Price\n(PKR)',
              style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600, height: 1.1),
            ),
            Text(
              'Amount\n(Shares)',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w600, height: 1.1),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 5 Red Ask Rows (Sellers)
        ...asks.map((ask) {
          final p = ask['price'] as double;
          final a = ask['amount'] as double;
          final depth = ask['depth'] as double;
          return _buildOrderBookRow(
            price: p.toStringAsFixed(2),
            amount: a.toStringAsFixed(2),
            color: const Color(0xFFE53E3E),
            bgColor: const Color(0xFFE53E3E).withOpacity(0.08),
            depth: depth,
          );
        }),

        const SizedBox(height: 6),

        // Live Center Spread Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock.price.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: stock.changePercent >= 0 ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
              ),
            ),
            Text(
              '≈ Rs. ${stock.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF718096), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 5 Green Bid Rows (Buyers)
        ...bids.map((bid) {
          final p = bid['price'] as double;
          final a = bid['amount'] as double;
          final depth = bid['depth'] as double;
          return _buildOrderBookRow(
            price: p.toStringAsFixed(2),
            amount: a.toStringAsFixed(2),
            color: const Color(0xFF38A169),
            bgColor: const Color(0xFF38A169).withOpacity(0.08),
            depth: depth,
          );
        }),

        const SizedBox(height: 8),

        // Precision & Layout Switcher (0.001 ▼, icon)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Text('0.01', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                  Icon(Icons.arrow_drop_down, size: 14),
                ],
              ),
            ),
            Row(
              children: const [
                Icon(Icons.format_align_justify, size: 14, color: Color(0xFF718096)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderBookRow({
    required String price,
    required String amount,
    required Color color,
    required Color bgColor,
    required double depth,
  }) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Horizontal depth fill bar
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: depth,
            child: Container(
              height: 18,
              color: bgColor,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
              ),
              Text(
                amount,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 5. $1,000,000 Trading Gala Banner ────────────────────────────
  Widget _buildGalaPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Rs. 1,000,000 PSX Trading Challenge',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
                ),
                Text(
                  'Win cash prizes, zero-fee CDC perks & top PSX equities',
                  style: TextStyle(fontSize: 10, color: Color(0xFF718096)),
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFA0AEC0)),
            onPressed: () => setState(() => _showPromoBanner = false),
          ),
        ],
      ),
    );
  }

  // ── 6. Bottom Order Management Section ───────────────────────────
  Widget _buildOrderManagementSection(dynamic portfolio, NumberFormat currency) {
    final holdings = portfolio.holdings as List<HoldingPosition>;
    final orders = portfolio.orders as List<TradeOrder>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs: Open Orders (0), Positions (1), Strategies (0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildManagementTab(0, 'Open Orders (${orders.length})'),
                  const SizedBox(width: 16),
                  _buildManagementTab(1, 'Positions (${holdings.length})'),
                  const SizedBox(width: 16),
                  _buildManagementTab(2, 'Strategies (0)'),
                ],
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.receipt_long_rounded, size: 18, color: Color(0xFF718096)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Filter row: Checkbox 'Hide other pairs' + Sub-filters
          Row(
            children: [
              const Icon(Icons.check_box_outline_blank_rounded, size: 16, color: Color(0xFFA0AEC0)),
              const SizedBox(width: 6),
              const Text(
                'Hide other pairs',
                style: TextStyle(fontSize: 11, color: Color(0xFF718096), fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              _buildSubFilterChip('Limit | Market (${orders.length})', true),
              const SizedBox(width: 6),
              _buildSubFilterChip('Stop Loss (0)', false),
            ],
          ),
          const SizedBox(height: 12),

          // Positions / Orders List Body
          if (_orderManagementTab == 1) ...[
            if (holdings.isEmpty)
              _buildEmptyOrdersState('No open positions')
            else
              ...holdings.map((h) => _buildPositionCard(h, currency)),
          ] else ...[
            if (orders.isEmpty)
              _buildEmptyOrdersState('No active open orders')
            else
              ...orders.map((o) => _buildOrderTile(o, currency)),
          ],
        ],
      ),
    );
  }

  Widget _buildManagementTab(int index, String title) {
    final isSelected = _orderManagementTab == index;
    return GestureDetector(
      onTap: () => setState(() => _orderManagementTab = index),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected ? const Color(0xFF1A202C) : const Color(0xFF718096),
        ),
      ),
    );
  }

  Widget _buildSubFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEDF2F7) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isSelected ? const Color(0xFF2D3748) : const Color(0xFFA0AEC0),
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 36, color: Color(0xFFCBD5E0)),
            const SizedBox(height: 6),
            Text(msg, style: const TextStyle(fontSize: 12, color: Color(0xFF718096))),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionCard(HoldingPosition h, NumberFormat currency) {
    final stock = MockMarketData.allPsxStocks.firstWhere(
      (s) => s.symbol == h.symbol,
      orElse: () => MockMarketData.allPsxStocks.first,
    );
    final pnl = (stock.price - h.avgBuyPrice) * h.shares;
    final pnlPct = h.avgBuyPrice > 0 ? (stock.price - h.avgBuyPrice) / h.avgBuyPrice * 100 : 0.0;
    final isPos = pnl >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${h.symbol} • ${h.shares} Shares', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Avg: Rs. ${currency.format(h.avgBuyPrice)}', style: const TextStyle(fontSize: 11, color: Color(0xFF718096))),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPos ? "+" : ""}Rs. ${currency.format(pnl)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E)),
              ),
              Text(
                '${isPos ? "+" : ""}${pnlPct.toStringAsFixed(2)}%',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(TradeOrder o, NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: o.side == OrderSide.buy ? const Color(0xFF38A169).withOpacity(0.12) : const Color(0xFFE53E3E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  o.side == OrderSide.buy ? 'BUY' : 'SELL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: o.side == OrderSide.buy ? const Color(0xFF38A169) : const Color(0xFFE53E3E)),
                ),
              ),
              const SizedBox(width: 8),
              Text(o.symbol, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          Text('${o.quantity} shares @ Rs. ${currency.format(o.price)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── 7. Expandable Candlestick Chart Bar at Bottom ────────────────
  Widget _buildCollapsibleChartBar(StockQuote stock) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _showBottomChart = !_showBottomChart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFF7FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stock.symbol}/PKR Live Chart',
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF2D3748)),
                ),
                Row(
                  children: [
                    Text(
                      _showBottomChart ? 'Hide' : 'Show',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF3182CE)),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showBottomChart ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: const Color(0xFF3182CE),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_showBottomChart)
          Container(
            height: 280,
            padding: const EdgeInsets.all(12),
            child: InteractiveStockChart(
              symbol: stock.symbol,
              currentPrice: stock.price,
              changePercent: stock.changePercent,
            ),
          ),
      ],
    );
  }
}
