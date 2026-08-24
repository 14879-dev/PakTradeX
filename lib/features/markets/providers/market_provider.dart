import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/market_repository.dart';

// ── Market State ────────────────────────────────────────────────

class MarketState {
  final MarketOverview overview;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;
  final Map<String, int> tickFlash; // symbol -> +1 (green flash), -1 (red flash)

  const MarketState({
    required this.overview,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
    this.tickFlash = const {},
  });

  MarketState copyWith({
    MarketOverview? overview,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
    Map<String, int>? tickFlash,
  }) =>
      MarketState(
        overview: overview ?? this.overview,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        tickFlash: tickFlash ?? this.tickFlash,
      );
}

// ── Market Notifier with Active Live Moving Stream ──────────────

class MarketNotifier extends StateNotifier<MarketState> {
  final MarketRepository _repo;
  Timer? _liveTickerTimer;
  final Map<String, double> _lastPrices = {};

  MarketNotifier(this._repo)
      : super(MarketState(overview: MarketOverview.mock)) {
    _load();
    _startLiveStream();
  }

  void _startLiveStream() {
    _liveTickerTimer?.cancel();
    // Poll every 2.5 seconds for active moving market updates
    _liveTickerTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      _fetchLiveTick();
    });
  }

  Future<void> _fetchLiveTick() async {
    try {
      final overview = await _repo.fetchMarketOverview();
      final newFlash = <String, int>{};

      for (var stk in overview.allStocks) {
        final last = _lastPrices[stk.symbol];
        if (last != null) {
          if (stk.price > last) {
            newFlash[stk.symbol] = 1; // uptick
          } else if (stk.price < last) {
            newFlash[stk.symbol] = -1; // downtick
          }
        }
        _lastPrices[stk.symbol] = stk.price;
      }

      if (mounted) {
        state = state.copyWith(
          overview: overview,
          isLoading: false,
          lastUpdated: DateTime.now(),
          tickFlash: newFlash,
        );
      }
    } catch (_) {}
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final overview = await _repo.fetchMarketOverview();
      for (var stk in overview.allStocks) {
        _lastPrices[stk.symbol] = stk.price;
      }
      if (mounted) {
        state = state.copyWith(
          overview: overview,
          isLoading: false,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Unable to fetch live market data',
        );
      }
    }
  }

  Future<void> refresh() => _load();

  @override
  void dispose() {
    _liveTickerTimer?.cancel();
    super.dispose();
  }
}

// ── Providers ───────────────────────────────────────────────────

final marketProvider =
    StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  return MarketNotifier(repo);
});

// Single stock quote provider (reactive)
final stockQuoteProvider =
    FutureProvider.family.autoDispose<StockQuote, String>((ref, symbol) async {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.fetchQuote(symbol);
});

// Live order book provider
final liveOrderBookProvider =
    FutureProvider.family.autoDispose<LiveOrderBookData?, String>((ref, symbol) async {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.fetchOrderBook(symbol);
});
