import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/market_repository.dart';

class StockChartParams {
  final String symbol;
  final String timeframe;

  const StockChartParams(this.symbol, this.timeframe);

  @override
  bool operator ==(Object other) =>
      other is StockChartParams &&
      other.symbol == symbol &&
      other.timeframe == timeframe;

  @override
  int get hashCode => Object.hash(symbol, timeframe);
}

/// Provider that fetches real OHLCV candles for a given symbol & timeframe.
/// Returns an empty list if the backend is unavailable.
final stockChartProvider =
    FutureProvider.family<List<OhlcvCandle>, StockChartParams>(
  (ref, params) async {
    final repo = ref.watch(marketRepositoryProvider);
    return repo.fetchHistory(params.symbol, params.timeframe);
  },
);
