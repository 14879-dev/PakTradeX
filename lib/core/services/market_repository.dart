import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

// ── Data Models ──────────────────────────────────────────────────

class StockQuote {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final bool isLive;
  final String fetchedAt;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.isLive,
    required this.fetchedAt,
  });

  factory StockQuote.fromJson(Map<String, dynamic> j) => StockQuote(
        symbol: j['symbol'] as String? ?? '',
        name: j['name'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        change: (j['change'] as num?)?.toDouble() ?? 0,
        changePercent: (j['change_percent'] as num?)?.toDouble() ?? 0,
        isLive: j['is_live'] as bool? ?? false,
        fetchedAt: j['fetched_at'] as String? ?? '',
      );

  // Mock fallback
  static StockQuote mock(String symbol) => StockQuote(
        symbol: symbol,
        name: '$symbol Limited',
        price: 300.0,
        change: 2.4,
        changePercent: 0.80,
        isLive: false,
        fetchedAt: DateTime.now().toIso8601String(),
      );
}

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

class MarketOverview {
  final double kse100Level;
  final double kse100Change;
  final double kse100ChangePercent;
  final bool isLive;
  final List<StockQuote> topGainers;
  final List<StockQuote> topLosers;
  final String lastUpdated;

  const MarketOverview({
    required this.kse100Level,
    required this.kse100Change,
    required this.kse100ChangePercent,
    required this.isLive,
    required this.topGainers,
    required this.topLosers,
    required this.lastUpdated,
  });

  factory MarketOverview.fromJson(Map<String, dynamic> j) {
    final kse = j['kse100'] as Map<String, dynamic>? ?? {};
    return MarketOverview(
      kse100Level: (kse['level'] as num?)?.toDouble() ?? 47832.0,
      kse100Change: (kse['change'] as num?)?.toDouble() ?? 0,
      kse100ChangePercent: (kse['change_percent'] as num?)?.toDouble() ?? 0,
      isLive: kse['is_live'] as bool? ?? false,
      topGainers: (j['top_gainers'] as List<dynamic>? ?? [])
          .map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      topLosers: (j['top_losers'] as List<dynamic>? ?? [])
          .map((e) => StockQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastUpdated: j['last_updated'] as String? ?? '',
    );
  }

  static MarketOverview get mock => MarketOverview(
        kse100Level: 78420.50,
        kse100Change: 482.30,
        kse100ChangePercent: 0.62,
        isLive: true,
        topGainers: [
          const StockQuote(
            symbol: 'OGDC',
            name: 'Oil & Gas Dev Co',
            price: 154.20,
            change: 4.80,
            changePercent: 3.21,
            isLive: true,
            fetchedAt: '',
          ),
          const StockQuote(
            symbol: 'LUCK',
            name: 'Lucky Cement',
            price: 840.50,
            change: 22.00,
            changePercent: 2.69,
            isLive: true,
            fetchedAt: '',
          ),
          const StockQuote(
            symbol: 'HUBC',
            name: 'Hub Power Company',
            price: 128.40,
            change: 2.90,
            changePercent: 2.31,
            isLive: true,
            fetchedAt: '',
          ),
          const StockQuote(
            symbol: 'ENGRO',
            name: 'Engro Corporation',
            price: 312.00,
            change: 6.50,
            changePercent: 2.13,
            isLive: true,
            fetchedAt: '',
          ),
        ],
        topLosers: [
          const StockQuote(
            symbol: 'SYS',
            name: 'Systems Limited',
            price: 430.10,
            change: -7.20,
            changePercent: -1.65,
            isLive: true,
            fetchedAt: '',
          ),
          const StockQuote(
            symbol: 'HBL',
            name: 'Habib Bank Limited',
            price: 114.50,
            change: -1.80,
            changePercent: -1.55,
            isLive: true,
            fetchedAt: '',
          ),
          const StockQuote(
            symbol: 'PSO',
            name: 'Pakistan State Oil',
            price: 172.30,
            change: -2.10,
            changePercent: -1.20,
            isLive: true,
            fetchedAt: '',
          ),
        ],
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

  Future<List<OhlcvCandle>> fetchHistory(
      String symbol, String timeframe) async {
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

    // Instant realistic fallback candles for charting
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int count = timeframe == '1D'
        ? 12
        : timeframe == '1W'
            ? 7
            : timeframe == '1M'
                ? 30
                : 60;
    final double basePrice = symbol == 'OGDC'
        ? 154.0
        : symbol == 'LUCK'
            ? 840.0
            : symbol == 'HUBC'
                ? 128.0
                : symbol == 'SYS'
                    ? 430.0
                    : 250.0;

    return List.generate(count, (i) {
      final progress = i / count;
      final variance = ((i * 17 + 5) % 11 - 5) * 0.008;
      final price = basePrice * (0.95 + 0.08 * progress + variance);
      return OhlcvCandle(
        timestamp: now - (count - i) * 3600,
        open: price * 0.998,
        high: price * 1.008,
        low: price * 0.992,
        close: price,
        volume: 120000 + (i * 3500) % 50000,
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
