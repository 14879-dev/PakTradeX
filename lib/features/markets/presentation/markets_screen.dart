import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/price_change_badge.dart';
import '../../home/data/mock_market_data.dart';
import '../../home/models/market_data_models.dart';

enum _MarketFilter { all, gainers, losers, volume }

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedSector = 'All';
  _MarketFilter _marketFilter = _MarketFilter.all;
  late final TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              _marketFilter = _MarketFilter.all;
            case 1:
              _marketFilter = _MarketFilter.gainers;
            case 2:
              _marketFilter = _MarketFilter.losers;
            case 3:
              _marketFilter = _MarketFilter.volume;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StockQuote> get _filteredStocks {
    List<StockQuote> base;
    switch (_marketFilter) {
      case _MarketFilter.gainers:
        base = MockMarketData.topGainers;
      case _MarketFilter.losers:
        base = MockMarketData.topLosers;
      case _MarketFilter.volume:
        base = MockMarketData.volumeLeaders;
      case _MarketFilter.all:
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
    final filtered = _filteredStocks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pakistan Capital Markets',
              style:
                  AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              '${MockMarketData.allPsxStocks.length} stocks · PSX Live',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
            unselectedLabelStyle: AppTypography.labelSmall,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: '▲ Gainers'),
              Tab(text: '▼ Losers'),
              Tab(text: '⬆ Volume'),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Sector Filter
          Container(
            color: AppColors.surface,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText:
                        'Search stocks (MCB, ENGRO, OGDC, SYS...)',
                    prefixIcon: const Icon(Icons.search,
                        size: 20, color: AppColors.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.roundedMd,
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Sector chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sectors.map((sector) {
                      final isSelected = _selectedSector == sector;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(sector),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedSector = sector);
                            }
                          },
                          selectedColor: AppColors.primaryLight,
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedSm,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                      .withValues(alpha: 0.4)
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Results header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} stocks',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_selectedSector != 'All')
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedSector = 'All'),
                    child: Text(
                      'Clear filter',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Stocks List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No stocks match "$_searchQuery"',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final stock = filtered[index];
                      return _StockListTile(
                        stock: stock,
                        rank: _marketFilter == _MarketFilter.volume
                            ? index + 1
                            : null,
                        onTap: () =>
                            context.go('/markets/stock/${stock.symbol}',
                                extra: stock),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _StockListTile extends StatelessWidget {
  final StockQuote stock;
  final int? rank;
  final VoidCallback onTap;

  const _StockListTile({
    required this.stock,
    required this.onTap,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercent >= 0;

    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          // Symbol avatar / rank badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.success.withValues(alpha: 0.10)
                  : AppColors.danger.withValues(alpha: 0.10),
              borderRadius: AppRadius.roundedSm,
            ),
            child: rank != null
                ? Center(
                    child: Text(
                      '#$rank',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      stock.symbol.length > 4
                          ? stock.symbol.substring(0, 4)
                          : stock.symbol,
                      style: AppTypography.labelSmall.copyWith(
                        color: isPositive
                            ? AppColors.success
                            : AppColors.danger,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Name & Sector
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stock.symbol,
                      style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.roundedXs,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          stock.sector,
                          style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  stock.name,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Vol: ${stock.volume.toStringAsFixed(1)}M  •  Mkt Cap: Rs.${stock.marketCap.toStringAsFixed(0)}B',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Price & Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${stock.price.toStringAsFixed(2)}',
                style: AppTypography.financialMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              PriceChangeBadge(
                changePercent: stock.changePercent,
                isCompact: true,
              ),
              const SizedBox(height: 2),
              Text(
                '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 10,
                  color: isPositive ? AppColors.success : AppColors.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
