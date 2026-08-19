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
  final List<double> sparkline;

  const StockQuote({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.peRatio,
    required this.dividendYield,
    required this.sparkline,
  });
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
    required this.totalPnl,
    required this.totalPnlPercent,
  });
}

class AiMarketBrief {
  final String headline;
  final String summary;
  final String sentiment; // Bullish, Neutral, Bearish
  final List<String> keyDrivers;
  final String actionableInsight;
  final DateTime timestamp;

  const AiMarketBrief({
    required this.headline,
    required this.summary,
    required this.sentiment,
    required this.keyDrivers,
    required this.actionableInsight,
    required this.timestamp,
  });
}

class FinancialNews {
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String category;
  final String summary;
  final String? relatedSymbol;

  const FinancialNews({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.category,
    required this.summary,
    this.relatedSymbol,
  });
}
