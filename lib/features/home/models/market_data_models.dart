class MarketIndex {
  final String symbol;
  final String name;
  final double currentPoints;
  final double changePoints;
  final double changePercent;
  final double high;
  final double low;
  final double volume; // In Millions
  final String status; // Open / Closed
  final List<double> sparkline;
  final int tickDirection;

  const MarketIndex({
    required this.symbol,
    required this.name,
    required this.currentPoints,
    required this.changePoints,
    required this.changePercent,
    required this.high,
    required this.low,
    required this.volume,
    required this.status,
    required this.sparkline,
    this.tickDirection = 1,
  });
}

class StockQuote {
  final String symbol;
  final String name;
  final String sector;
  final double price;
  final double change;
  final double changePercent;
  final double volume;
  final double marketCap; // in Billion PKR
  final double peRatio;
  final double dividendYield;
  final bool isShariah;
  final List<double> sparkline;
  final double high;
  final double low;
  final int tickDirection; // +1 (up), -1 (down), 0 (neutral)
  final bool isLive;
  final String fetchedAt;

  const StockQuote({
    required this.symbol,
    required this.name,
    this.sector = 'Other',
    required this.price,
    required this.change,
    required this.changePercent,
    this.volume = 1.2,
    this.marketCap = 150.0,
    this.peRatio = 6.5,
    this.dividendYield = 8.5,
    this.isShariah = false,
    this.sparkline = const [],
    this.high = 0.0,
    this.low = 0.0,
    this.tickDirection = 1,
    this.isLive = true,
    this.fetchedAt = '',
  });

  factory StockQuote.fromJson(Map<String, dynamic> j) {
    final rawSpark = j['sparkline'] as List<dynamic>? ?? [];
    final sparkList = rawSpark.map((e) => (e as num).toDouble()).toList();
    final rawVol = (j['volume'] as num?)?.toDouble() ?? 1200000.0;
    final volInM = rawVol > 10000 ? rawVol / 1000000.0 : rawVol;

    return StockQuote(
      symbol: j['symbol'] as String? ?? '',
      name: j['name'] as String? ?? '',
      sector: j['sector'] as String? ?? 'Other',
      price: (j['price'] as num?)?.toDouble() ?? 0.0,
      change: (j['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (j['change_percent'] as num?)?.toDouble() ?? 0.0,
      volume: volInM,
      marketCap: (j['market_cap'] as num?)?.toDouble() ?? 150.0,
      peRatio: (j['pe_ratio'] as num?)?.toDouble() ?? 6.5,
      dividendYield: (j['dividend_yield'] as num?)?.toDouble() ?? 8.5,
      isShariah: j['is_shariah'] as bool? ?? false,
      sparkline: sparkList.isNotEmpty ? sparkList : [(j['price'] as num?)?.toDouble() ?? 100.0],
      high: (j['high'] as num?)?.toDouble() ?? 0.0,
      low: (j['low'] as num?)?.toDouble() ?? 0.0,
      tickDirection: (j['tick_direction'] as num?)?.toInt() ?? 1,
      isLive: j['is_live'] as bool? ?? true,
      fetchedAt: j['fetched_at'] as String? ?? '',
    );
  }

  static StockQuote mock(String symbol) => StockQuote(
        symbol: symbol,
        name: '$symbol Limited',
        sector: 'Commercial Banks',
        price: 300.0,
        change: 2.4,
        changePercent: 0.80,
        volume: 2.45,
        sparkline: const [295.0, 297.0, 298.5, 300.0],
        tickDirection: 1,
        isLive: true,
        fetchedAt: DateTime.now().toIso8601String(),
      );
}

class PortfolioSummary {
  final double totalBalance;
  final double investedAmount;
  final double cashBalance;
  final double todaysPnl;
  final double todaysPnlPercent;
  final double totalPnl;
  final double totalPnlPercent;

  const PortfolioSummary({
    required this.totalBalance,
    required this.investedAmount,
    required this.cashBalance,
    required this.todaysPnl,
    required this.todaysPnlPercent,
    this.totalPnl = 12450.0,
    this.totalPnlPercent = 6.45,
  });
}

class AiMarketBrief {
  final String headline;
  final String summary;
  final String sentiment; // Bullish / Bearish / Neutral
  final double confidenceScore;
  final List<String> keyDrivers;
  final String recommendation;
  final String actionableInsight;
  final DateTime? timestamp;

  const AiMarketBrief({
    this.headline = 'PSX Rally Sustained Above 78,000 Level',
    required this.summary,
    required this.sentiment,
    this.confidenceScore = 88.0,
    required this.keyDrivers,
    this.recommendation = 'Hold & Accumulate',
    this.actionableInsight = 'Consider selective exposure in high-dividend blue chips.',
    this.timestamp,
  });
}

class FinancialNews {
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String category;
  final String summary;
  final String? sentiment; // Bullish / Bearish / Neutral
  final String? relatedSymbol;
  final String? timestamp;

  const FinancialNews({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.category,
    required this.summary,
    this.sentiment,
    this.relatedSymbol,
    this.timestamp,
  });
}
