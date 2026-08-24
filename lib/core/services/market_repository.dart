import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../../features/home/models/market_data_models.dart';
export '../../features/home/models/market_data_models.dart' show StockQuote, MarketIndex;

// ── Data Models ──────────────────────────────────────────────────

class OhlcvCandle {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  const OhlcvCandle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory OhlcvCandle.fromJson(Map<String, dynamic> j) => OhlcvCandle(
        timestamp: j['timestamp'] as int? ?? 0,
        open: (j['open'] as num?)?.toDouble() ?? 0,
        high: (j['high'] as num?)?.toDouble() ?? 0,
        low: (j['low'] as num?)?.toDouble() ?? 0,
        close: (j['close'] as num?)?.toDouble() ?? 0,
        volume: j['volume'] as int? ?? 0,
      );
}

class OrderBookDepthLevel {
  final double price;
  final int volume;
  final int orders;

  const OrderBookDepthLevel({
    required this.price,
    required this.volume,
    required this.orders,
  });

  factory OrderBookDepthLevel.fromJson(Map<String, dynamic> j) => OrderBookDepthLevel(
        price: (j['price'] as num?)?.toDouble() ?? 0.0,
        volume: (j['volume'] as num?)?.toInt() ?? 0,
        orders: (j['orders'] as num?)?.toInt() ?? 1,
      );
}

class LiveOrderBookData {
  final String symbol;
  final double lastPrice;
  final double change;
  final double changePercent;
  final List<OrderBookDepthLevel> bids;
  final List<OrderBookDepthLevel> asks;
  final int totalBidVolume;
  final int totalAskVolume;

  const LiveOrderBookData({
    required this.symbol,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.bids,
    required this.asks,
    required this.totalBidVolume,
    required this.totalAskVolume,
  });

  factory LiveOrderBookData.fromJson(Map<String, dynamic> j) {
    return LiveOrderBookData(
      symbol: j['symbol'] as String? ?? '',
      lastPrice: (j['last_price'] as num?)?.toDouble() ?? 0.0,
      change: (j['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (j['change_percent'] as num?)?.toDouble() ?? 0.0,
      bids: (j['bids'] as List<dynamic>? ?? [])
          .map((e) => OrderBookDepthLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      asks: (j['asks'] as List<dynamic>? ?? [])
          .map((e) => OrderBookDepthLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBidVolume: (j['total_bid_volume'] as num?)?.toInt() ?? 0,
      totalAskVolume: (j['total_ask_volume'] as num?)?.toInt() ?? 0,
    );
  }
}

class MarketOverview {
  final double kse100Level;
  final double kse100Change;
  final double kse100ChangePercent;
  final double kse100High;
  final double kse100Low;
  final int kse100Volume;
  final int kse100TickDirection;
  final bool isLive;
  final List<StockQuote> topGainers;
  final List<StockQuote> topLosers;
  final List<StockQuote> allStocks;
  final String lastUpdated;

  const MarketOverview({
    required this.kse100Level,
    required this.kse100Change,
    required this.kse100ChangePercent,
    this.kse100High = 78890.0,
    this.kse100Low = 77840.0,
    this.kse100Volume = 345000000,
    this.kse100TickDirection = 1,
    required this.isLive,
    required this.topGainers,
    required this.topLosers,
    this.allStocks = const [],
    required this.lastUpdated,
  });

  factory MarketOverview.fromJson(Map<String, dynamic> j) {
    final kse = j['kse100'] as Map<String, dynamic>? ?? {};
    final rawStocks = j['stocks'] as List<dynamic>? ?? [];

    return MarketOverview(
      kse100Level: (kse['level'] as num?)?.toDouble() ?? 78640.50,
      kse100Change: (kse['change'] as num?)?.toDouble() ?? 482.30,
      kse100ChangePercent: (kse['change_percent'] as num?)?.toDouble() ?? 0.62,
      kse100High: (kse['high'] as num?)?.toDouble() ?? 78890.0,
      kse100Low: (kse['low'] as num?)?.toDouble() ?? 77840.0,
      kse100Volume: (kse['volume'] as num?)?.toInt() ?? 345000000,
      kse100TickDirection: (kse['tick_direction'] as num?)?.toInt() ?? 1,
      isLive: kse['is_live'] as bool? ?? true,
      topGainers: (j['top_gainers'] as List<dynamic>? ?? [])
          .map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLosers: (j['top_losers'] as List<dynamic>? ?? [])
          .map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      allStocks: rawStocks.map((e) => StockQuote.fromJson(e as Map<String, dynamic>)).toList(),
      lastUpdated: j['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  static MarketOverview get mock => MarketOverview(
        kse100Level: 78640.50,
        kse100Change: 482.30,
        kse100ChangePercent: 0.62,
        isLive: true,
        topGainers: [
          StockQuote.mock('SYS'),
          StockQuote.mock('ENGRO'),
          StockQuote.mock('LUCK'),
        ],
        topLosers: [
          StockQuote.mock('OGDC'),
          StockQuote.mock('PSO'),
          StockQuote.mock('PPL'),
        ],
        allStocks: [],
        lastUpdated: DateTime.now().toIso8601String(),
      );
}

// ── Repository ───────────────────────────────────────────────────

class MarketRepository {
  final _client = apiClient;

  Future<StockQuote> fetchQuote(String symbol) async {
    try {
      final res = await _client.get('/market/quote/$symbol');
      return StockQuote.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return StockQuote.mock(symbol);
    }
  }

  Future<LiveOrderBookData?> fetchOrderBook(String symbol) async {
    try {
      final res = await _client.get('/market/orderbook/$symbol');
      return LiveOrderBookData.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<OhlcvCandle>> fetchHistory(String symbol, String timeframe) async {
    try {
      final res = await _client.get(
        '/market/history/$symbol',
        queryParameters: {'timeframe': timeframe},
      );
      final data = res.data as Map<String, dynamic>;
      final candles = data['candles'] as List<dynamic>? ?? [];
      if (candles.isNotEmpty) {
        return candles
            .map((c) => OhlcvCandle.fromJson(c as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Fallback candles
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int count = timeframe == '1D' ? 24 : 30;
    return List.generate(count, (i) {
      final price = 300.0 + (i * 1.5);
      return OhlcvCandle(
        timestamp: now - (count - i) * 3600,
        open: price * 0.995,
        high: price * 1.008,
        low: price * 0.992,
        close: price,
        volume: 150000,
      );
    });
  }

  Future<MarketOverview> fetchMarketOverview() async {
    try {
      final res = await _client.get('/market/overview');
      return MarketOverview.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return MarketOverview.mock;
    }
  }
}

// ── Providers ────────────────────────────────────────────────────

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepository();
});
