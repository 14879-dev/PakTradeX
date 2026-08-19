import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/market_repository.dart';
import '../../../core/config/app_config.dart';

// ── Market State ────────────────────────────────────────────────

class MarketState {
  final MarketOverview overview;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const MarketState({
    required this.overview,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  MarketState copyWith({
    MarketOverview? overview,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) =>
      MarketState(
        overview: overview ?? this.overview,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        lastUpdated: lastUpdated ?? this.lastUpdated,
      );
}

// ── Market Notifier ─────────────────────────────────────────────

class MarketNotifier extends StateNotifier<MarketState> {
  final MarketRepository _repo;
  Timer? _pollTimer;

  MarketNotifier(this._repo, {bool autoPoll = false})
      : super(MarketState(overview: MarketOverview.mock)) {
    _load();
    if (autoPoll) {
      _startPolling();
    }
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final overview = await _repo.fetchMarketOverview();
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

  void _startPolling() {
    _pollTimer = Timer.periodic(AppConfig.overviewPollInterval, (_) => _load());
  }

  Future<void> refresh() => _load();

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

// ── Providers ───────────────────────────────────────────────────

final marketProvider =
    StateNotifierProvider.autoDispose<MarketNotifier, MarketState>((ref) {
  final repo = ref.watch(marketRepositoryProvider);
  final notifier = MarketNotifier(repo, autoPoll: false);
  ref.onDispose(() {
    notifier.dispose();
  });
  return notifier;
});

// Single stock quote provider (auto-refreshes)
final stockQuoteProvider =
    FutureProvider.family.autoDispose<StockQuote, String>((ref, symbol) async {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.fetchQuote(symbol);
});
