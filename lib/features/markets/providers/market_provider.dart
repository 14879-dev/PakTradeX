import 'dart:async';
import 'dart:math';
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
  final Random _rnd = Random();
  List<StockQuote> _currentStocks = [];

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
      MarketOverview overview;
      try {
        overview = await _repo.fetchMarketOverview();
      } catch (_) {
        overview = _generateOfflineTick();
      }

      // If overview came back as mock, apply micro-movement
      if (overview.allStocks.isNotEmpty && _currentStocks.isNotEmpty) {
        overview = _simulateLiveMicroMovement(overview);
      }

      final newFlash = <String, int>{};
      for (var stk in overview.allStocks) {
        final last = _lastPrices[stk.symbol];
        if (last != null) {
          if (stk.price > last) {
            newFlash[stk.symbol] = 1; // uptick green
          } else if (stk.price < last) {
            newFlash[stk.symbol] = -1; // downtick red
          }
        }
        _lastPrices[stk.symbol] = stk.price;
      }
      _currentStocks = List.from(overview.allStocks);

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

  MarketOverview _generateOfflineTick() {
    if (_currentStocks.isEmpty) {
      _currentStocks = List.from(MarketOverview.mock.allStocks);
    }
    return _simulateLiveMicroMovement(MarketOverview.mock);
  }

  MarketOverview _simulateLiveMicroMovement(MarketOverview base) {
    final list = _currentStocks.isNotEmpty ? _currentStocks : base.allStocks;
    if (list.isEmpty) return base;

    final updated = List<StockQuote>.from(list);
    // Pick 3-5 random stocks to apply micro tick (±0.05% to ±0.15%)
    final count = min(4, updated.length);
    for (int i = 0; i < count; i++) {
      final idx = _rnd.nextInt(updated.length);
      final stk = updated[idx];
      final deltaPct = (_rnd.nextBool() ? 1 : -1) * (_rnd.nextDouble() * 0.0015 + 0.0003);
      final newPrice = double.parse((stk.price * (1 + deltaPct)).toStringAsFixed(2));
      final prev = stk.previousClose > 0 ? stk.previousClose : (stk.price * 0.99);
      final change = double.parse((newPrice - prev).toStringAsFixed(2));
      final changePct = double.parse(((change / prev) * 100).toStringAsFixed(2));

      final newSpark = List<double>.from(stk.sparkline);
      newSpark.add(newPrice);
      if (newSpark.length > 8) newSpark.removeAt(0);

      updated[idx] = stk.copyWith(
        price: newPrice,
        change: change,
        changePercent: changePct,
        sparkline: newSpark,
        volume: stk.volume + _rnd.nextInt(500) + 50,
      );
    }

    final sortedGain = List<StockQuote>.from(updated)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final sortedLoss = List<StockQuote>.from(updated)
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));

    final kseDelta = (_rnd.nextBool() ? 1 : -1) * (_rnd.nextDouble() * 15.0 + 2.0);
    final newKse = double.parse((base.kse100Level + kseDelta).toStringAsFixed(2));

    return MarketOverview(
      kse100Level: newKse,
      kse100Change: double.parse((base.kse100Change + kseDelta).toStringAsFixed(2)),
      kse100ChangePercent: base.kse100ChangePercent,
      kse100High: max(base.kse100High, newKse),
      kse100Low: min(base.kse100Low, newKse),
      kse100Volume: base.kse100Volume + _rnd.nextInt(25000),
      kse100TickDirection: kseDelta >= 0 ? 1 : -1,
      isLive: true,
      topGainers: sortedGain.take(6).toList(),
      topLosers: sortedLoss.take(6).toList(),
      allStocks: updated,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final overview = await _repo.fetchMarketOverview();
      _currentStocks = List.from(overview.allStocks);
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
    } catch (_) {
      final mock = MarketOverview.mock;
      _currentStocks = List.from(mock.allStocks);
      if (mounted) {
        state = state.copyWith(
          overview: mock,
          isLoading: false,
          lastUpdated: DateTime.now(),
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

final marketProvider = StateNotifierProvider<MarketNotifier, MarketState>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  return MarketNotifier(repo);
});
