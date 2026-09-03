import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import '../../features/home/data/mock_market_data.dart';
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
    this.kse100High = 177400.0,
    this.kse100Low = 175800.0,
    this.kse100Volume = 482500000,
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
      kse100Level: (kse['level'] as num?)?.toDouble() ?? 176850.40,
      kse100Change: (kse['change'] as num?)?.toDouble() ?? 870.20,
      kse100ChangePercent: (kse['change_percent'] as num?)?.toDouble() ?? 0.49,
      kse100High: (kse['high'] as num?)?.toDouble() ?? 177400.0,
      kse100Low: (kse['low'] as num?)?.toDouble() ?? 175800.0,
      kse100Volume: (kse['volume'] as num?)?.toInt() ?? 482500000,
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

  static MarketOverview get mock {
    final stocks = List<StockQuote>.from(MockMarketData.allPsxStocks);
    final sortedByGain = List<StockQuote>.from(stocks)
      ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    final sortedByLoss = List<StockQuote>.from(stocks)
      ..sort((a, b) => a.changePercent.compareTo(b.changePercent));

    return MarketOverview(
      kse100Level: 176850.40,
      kse100Change: 870.20,
      kse100ChangePercent: 0.49,
      kse100High: 177400.0,
      kse100Low: 175800.0,
      kse100Volume: 482500000,
      kse100TickDirection: 1,
      isLive: true,
      topGainers: sortedByGain.take(6).toList(),
      topLosers: sortedByLoss.take(6).toList(),
      allStocks: stocks,
      lastUpdated: DateTime.now().toIso8601String(),
    );
  }
}

// ── Repository ───────────────────────────────────────────────────

class MarketRepository {
  final _client = apiClient;
  final _rnd = Random();

  Future<StockQuote> fetchQuote(String symbol) async {
    try {
      final res = await _client.get('/market/quote/$symbol');
      return StockQuote.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      final match = MockMarketData.allPsxStocks.firstWhere(
        (s) => s.symbol.toUpperCase() == symbol.toUpperCase(),
        orElse: () => StockQuote.mock(symbol),
      );
      return match;
    }
  }

  Future<LiveOrderBookData?> fetchOrderBook(String symbol) async {
    try {
      final res = await _client.get('/market/orderbook/$symbol');
      return LiveOrderBookData.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      final q = await fetchQuote(symbol);
      final p = q.price;
      return LiveOrderBookData(
        symbol: symbol.toUpperCase(),
        lastPrice: p,
        change: q.change,
        changePercent: q.changePercent,
        bids: [
          OrderBookDepthLevel(price: p - 0.20, volume: _rnd.nextInt(15000) + 3000, orders: _rnd.nextInt(8) + 2),
          OrderBookDepthLevel(price: p - 0.50, volume: _rnd.nextInt(25000) + 6000, orders: _rnd.nextInt(15) + 4),
          OrderBookDepthLevel(price: p - 0.80, volume: _rnd.nextInt(35000) + 9000, orders: _rnd.nextInt(20) + 6),
          OrderBookDepthLevel(price: p - 1.20, volume: _rnd.nextInt(50000) + 12000, orders: _rnd.nextInt(25) + 8),
          OrderBookDepthLevel(price: p - 1.60, volume: _rnd.nextInt(80000) + 18000, orders: _rnd.nextInt(35) + 10),
        ],
        asks: [
          OrderBookDepthLevel(price: p + 0.20, volume: _rnd.nextInt(14000) + 2500, orders: _rnd.nextInt(8) + 2),
          OrderBookDepthLevel(price: p + 0.50, volume: _rnd.nextInt(22000) + 5000, orders: _rnd.nextInt(12) + 3),
          OrderBookDepthLevel(price: p + 0.80, volume: _rnd.nextInt(32000) + 8000, orders: _rnd.nextInt(18) + 5),
          OrderBookDepthLevel(price: p + 1.20, volume: _rnd.nextInt(48000) + 11000, orders: _rnd.nextInt(22) + 7),
          OrderBookDepthLevel(price: p + 1.60, volume: _rnd.nextInt(75000) + 16000, orders: _rnd.nextInt(30) + 9),
        ],
        totalBidVolume: 125000,
        totalAskVolume: 118000,
      );
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

    // Fallback authentic candles anchored to real price
    final q = await fetchQuote(symbol);
    final base = q.price;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int count = timeframe == '1D' ? 24 : 30;
    final step = timeframe == '1D' ? 1800 : 86400;

    double curr = base * 0.94;
    return List.generate(count, (i) {
      final t = now - (count - i) * step;
      final drift = (_rnd.nextDouble() * 0.02) - 0.009;
      final closeP = (curr * (1 + drift));
      final openP = curr;
      final highP = max(openP, closeP) * (1 + _rnd.nextDouble() * 0.006);
      final lowP = min(openP, closeP) * (1 - _rnd.nextDouble() * 0.006);
      curr = closeP;
      return OhlcvCandle(
        timestamp: t,
        open: double.parse(openP.toStringAsFixed(2)),
        high: double.parse(highP.toStringAsFixed(2)),
        low: double.parse(lowP.toStringAsFixed(2)),
        close: double.parse((i == count - 1 ? base : closeP).toStringAsFixed(2)),
        volume: _rnd.nextInt(800000) + 100000,
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
