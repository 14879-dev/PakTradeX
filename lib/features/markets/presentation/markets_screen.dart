import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../home/data/mock_market_data.dart';
import '../../home/models/market_data_models.dart';
import '../../profile/providers/account_provider.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key});

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';
  String _selectedSector = 'All';
  int _insightPage = 1;

  final List<String> _tabs = [
    'Insights',
    'Favorites',
    'PSX Stocks 🔥',
    'Top Gainers',
    'Shariah (KMI)',
    'Sectors',
  ];

  final List<String> _sectors = [
    'All',
    'Commercial Banks',
    'Technology & Comm.',
    'Fertilizer',
    'Oil & Gas Exploration',
    'Oil & Gas Marketing',
    'Cement',
    'Power Generation',
    'Automobiles',
    'Pharmaceuticals',
    'Textile',
    'Insurance',
  ];

  final Set<String> _favorites = {'MCB', 'SYS', 'OGDC', 'ENGRO', 'LUCK'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StockQuote> _getFilteredStocks(int tabIndex) {
    List<StockQuote> base;
    switch (tabIndex) {
      case 1: // Favorites
        base = MockMarketData.allPsxStocks
            .where((s) => _favorites.contains(s.symbol))
            .toList();
      case 2: // PSX Stocks
        base = MockMarketData.allPsxStocks;
      case 3: // Top Gainers
        base = MockMarketData.topGainers;
      case 4: // Shariah
        base = MockMarketData.allPsxStocks
            .where((s) => [
                  'SYS',
                  'ENGRO',
                  'OGDC',
                  'LUCK',
                  'MARI',
                  'HUBC',
                  'FFC',
                  'MEBL',
                  'SEARL'
                ].contains(s.symbol))
            .toList();
      case 5: // Sectors
      default:
        base = MockMarketData.allPsxStocks;
    }

    return base.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.symbol.toLowerCase().contains(q) ||
          s.name.toLowerCase().contains(q) ||
          s.sector.toLowerCase().contains(q);
      final matchesSector =
          _selectedSector == 'All' || s.sector == _selectedSector;
      return matchesSearch && matchesSector;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Top Search Bar Header
            _buildTopSearchBar(),

            // Horizontal Category Navigation Tabs
            _buildCategoryTabs(),

            const Divider(height: 1, color: Color(0xFFE8EEF5)),

            // Tab View Body
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInsightsTab(),
                  _buildStocksListTab(1),
                  _buildStocksListTab(2),
                  _buildStocksListTab(3),
                  _buildStocksListTab(4),
                  _buildStocksListTab(5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Search Bar (Matching Screenshot 1) ──────────────────────
  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: '🔥 KSE-100 breaks 78,400 · Search PSX Stocks',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF718096)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: Color(0xFF718096)),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF2D3748)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Scanner ready for PakTrade ID quick payments')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal Category Tabs ──────────────────────────────────
  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.transparent,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: const Color(0xFF1A202C),
        unselectedLabelColor: const Color(0xFF718096),
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tabs: _tabs.map((title) => Tab(text: title)).toList(),
      ),
    );
  }

  // ── Tab 0: Insights View (Exact Replica of Screenshot 1) ─────────
  Widget _buildInsightsTab() {
    final featuredStock = MockMarketData.allPsxStocks.firstWhere(
      (s) => s.symbol == 'OGDC',
      orElse: () => MockMarketData.allPsxStocks.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Fear & Greed / 24H Volume / Bulls vs Bears Card
          _buildMarketSentimentCard(),

          const SizedBox(height: 18),

          // 2. Market Trend Section Header
          Text(
            'Market Trend',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Featured Stock Card (OGDC with Sparkline + Sub-Ticker Pills)
          _buildFeaturedStockCard(featuredStock),

          const SizedBox(height: 12),

          // 4. Category Grid Row (Banks, Tech, Energy)
          _buildCategoryMiniCardsRow(),

          const SizedBox(height: 18),

          // 5. AI For You Banner
          _buildAiForYouCard(),

          const SizedBox(height: 14),

          // 6. $1,000,000 Trading Gala Promotional Card
          _buildTradingGalaBanner(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── 1. Fear & Greed + 24H Liquidation + L/S Sentiment Card ───────
  Widget _buildMarketSentimentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row of 3 Metrics: Fear&Greed Meter, 24H PSX Volume, Bulls vs Bears
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fear & Greed Meter
              Column(
                children: [
                  const Text(
                    'Fear & Greed',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF718096), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 76,
                    height: 46,
                    child: CustomPaint(
                      painter: _FearGreedGaugePainter(value: 61),
                      child: const Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          '61',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Greed',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38A169)),
                  ),
                ],
              ),

              // 24H PSX Volume
              Column(
                children: [
                  const Text(
                    '24H Volume',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF718096), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '48.2B',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '+8.96%',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF38A169)),
                  ),
                ],
              ),

              // Bulls vs Bears (L/S)
              Column(
                children: [
                  const Text(
                    'PSX Bulls / Bears',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF718096), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      Text(
                        '70.0',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A202C)),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '30.0',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF718096)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Green / Red ratio bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Row(
                      children: [
                        Container(width: 44, height: 4, color: const Color(0xFF38A169)),
                        Container(width: 20, height: 4, color: const Color(0xFFE53E3E)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFEDF2F7)),
          ),

          // Flash Summary Headline
          Text(
            'Foreign institutional buying and banking dividend payouts drive PSX benchmark past 78,400 points.',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Ticker Pill + Pagination Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Text('🟢 MCB ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    Text('+2.14%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF38A169))),
                  ],
                ),
              ),
              Text(
                '$_insightPage/4',
                style: const TextStyle(fontSize: 11, color: Color(0xFFA0AEC0), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Featured Stock Card (OGDC + Sparkline + Pills) ─────────────
  Widget _buildFeaturedStockCard(StockQuote stock) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stock.sector,
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096), fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFA0AEC0)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Logo Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF3182CE).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    stock.symbol.length > 4 ? stock.symbol.substring(0, 4) : stock.symbol,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF3182CE)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Rs. ${stock.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${stock.changePercent >= 0 ? "+" : ""}${stock.changePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: stock.changePercent >= 0 ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Sparkline on the right
              SizedBox(
                width: 100,
                height: 36,
                child: CustomPaint(
                  painter: _MiniSparklinePainter(
                    points: stock.sparkline,
                    isPositive: stock.changePercent >= 0,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sub-Ticker Row (Quick movers)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubTickerChip('SYS', '+3.23%', true),
                _buildSubTickerChip('LUCK', '+0.42%', true),
                _buildSubTickerChip('ENGRO', '+1.22%', true),
                _buildSubTickerChip('HUBC', '-0.82%', false),
                _buildSubTickerChip('PSO', '-1.53%', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTickerChip(String symbol, String change, bool isPos) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Text(
            '$symbol ',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
          ),
          Text(
            change,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Category Mini Cards Row (Banks, Tech, Energy) ────────────
  Widget _buildCategoryMiniCardsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCategoryCard('Banks', 'MCB', '+2.14%', true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryCard('Tech', 'SYS', '+3.23%', true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCategoryCard('Energy', 'MARI', '+1.23%', true),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, String ticker, String change, bool isPos) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF718096), fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFFA0AEC0)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ticker,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
          ),
          const SizedBox(height: 2),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. AI For You Banner ─────────────────────────────────────────
  Widget _buildAiForYouCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF3182CE)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'SYS quarterly export growth: buy or hold?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => context.push('/ai'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF3182CE).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text(
                    'Ask AI',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3182CE)),
                  ),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_rounded, size: 12, color: Color(0xFF3182CE)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. $1,000,000 Trading Gala Promotional Card ──────────────────
  Widget _buildTradingGalaBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A365D), Color(0xFF2B6CB0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B6CB0).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🏆', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Rs. 1,000,000 Trading Gala',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                SizedBox(height: 2),
                Text(
                  'Trade PSX stocks risk-free in Demo Sandbox',
                  style: TextStyle(fontSize: 11, color: Color(0xFFE2E8F0)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(accountProvider.notifier).switchMode(AccountMode.demo);
              context.go('/trade');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3182CE),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('Join Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ── Stock Lists Tab (Used for PSX Stocks, Gainers, Shariah, etc.) ─
  Widget _buildStocksListTab(int tabIndex) {
    final filtered = _getFilteredStocks(tabIndex);

    return Column(
      children: [
        // Sector Filter Chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      color: isSelected ? AppColors.primary : const Color(0xFF4A5568),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary.withOpacity(0.4) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const Divider(height: 1, color: Color(0xFFE8EEF5)),

        // Stocks List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text('No stocks found for "$_searchQuery"', style: AppTypography.bodyMedium),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final stock = filtered[index];
                    final isPos = stock.changePercent >= 0;
                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => context.go('/markets/stock/${stock.symbol}', extra: stock),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isPos
                                  ? const Color(0xFF38A169).withOpacity(0.1)
                                  : const Color(0xFFE53E3E).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                stock.symbol.length > 4 ? stock.symbol.substring(0, 4) : stock.symbol,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isPos ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      stock.symbol,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        stock.sector,
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  stock.name,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. ${stock.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              PriceChangeBadge(changePercent: stock.changePercent, isCompact: true),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ── Custom Painters ────────────────────────────────────────────────
class _FearGreedGaugePainter extends CustomPainter {
  final double value; // 0 to 100
  _FearGreedGaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE2E8F0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Gradient Arc (Red to Orange to Green)
    final gradient = const SweepGradient(
      colors: [Color(0xFFE53E3E), Color(0xFFDD6B20), Color(0xFF38A169)],
      stops: [0.0, 0.5, 1.0],
      startAngle: math.pi,
      endAngle: math.pi * 2,
    );

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );

    // Indicator Dot on Arc
    final angle = math.pi + (math.pi * (value / 100));
    final dotX = center.dx + radius * math.cos(angle);
    final dotY = center.dy + radius * math.sin(angle);

    final dotPaint = Paint()
      ..color = const Color(0xFF2D3748)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 4.5, dotPaint);
    canvas.drawCircle(Offset(dotX, dotY), 2.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> points;
  final bool isPositive;

  _MiniSparklinePainter({required this.points, required this.isPositive});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final minVal = points.reduce(math.min);
    final maxVal = points.reduce(math.max);
    final range = maxVal == minVal ? 1.0 : maxVal - minVal;

    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (int i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range * (size.height - 8)) - 4;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final linePaint = Paint()
      ..color = isPositive ? const Color(0xFF38A169) : const Color(0xFFE53E3E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw glowing end dot
    final lastX = size.width;
    final lastY = size.height - ((points.last - minVal) / range * (size.height - 8)) - 4;
    canvas.drawCircle(
      Offset(lastX, lastY),
      3.5,
      Paint()..color = (isPositive ? const Color(0xFF38A169) : const Color(0xFFE53E3E)).withOpacity(0.3),
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      2.0,
      Paint()..color = isPositive ? const Color(0xFF38A169) : const Color(0xFFE53E3E),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
