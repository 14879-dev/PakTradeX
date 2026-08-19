import '../models/market_data_models.dart';

/// Realistic PSX Market Simulation / Mock Dataset.
/// Note: Clearly labeled as DEMO / SIMULATION DATA in compliance with fintech guidelines.
abstract class MockMarketData {
  static const MarketIndex kse100 = MarketIndex(
    symbol: 'KSE-100',
    name: 'PSX Benchmark Index',
    currentPoints: 78420.50,
    changePoints: 684.20,
    changePercent: 0.88,
    high: 78650.00,
    low: 77920.10,
    volume: 342.8,
    status: 'Market Open',
    sparkline: [77920, 78050, 78200, 78150, 78340, 78500, 78420.5],
  );

  static const MarketIndex kse30 = MarketIndex(
    symbol: 'KSE-30',
    name: 'Top 30 Market Cap Index',
    currentPoints: 24890.30,
    changePoints: 312.40,
    changePercent: 1.27,
    high: 24950.00,
    low: 24600.00,
    volume: 180.4,
    status: 'Market Open',
    sparkline: [24600, 24720, 24800, 24780, 24850, 24910, 24890.3],
  );

  static const MarketIndex kmi30 = MarketIndex(
    symbol: 'KMI-30',
    name: 'Islamic Shariah Index',
    currentPoints: 128450.00,
    changePoints: -420.10,
    changePercent: -0.33,
    high: 129100.00,
    low: 128200.00,
    volume: 145.2,
    status: 'Market Open',
    sparkline: [128900, 129100, 128700, 128500, 128300, 128450],
  );

  static const PortfolioSummary demoPortfolio = PortfolioSummary(
    totalBalance: 1254300.00,
    investedAmount: 980000.00,
    cashBalance: 274300.00,
    todaysPnl: 18450.00,
    todaysPnlPercent: 1.49,
    totalPnl: 274300.00,
    totalPnlPercent: 27.99,
  );

  static const List<StockQuote> topGainers = [
    StockQuote(
      symbol: 'MCB',
      name: 'MCB Bank Limited',
      sector: 'Commercial Banks',
      price: 322.40,
      change: 6.75,
      changePercent: 2.14,
      volume: 4.8,
      marketCap: 382.5,
      peRatio: 5.4,
      dividendYield: 12.8,
      sparkline: [315.0, 317.0, 318.5, 320.0, 321.2, 322.4],
    ),
    StockQuote(
      symbol: 'ENGRO',
      name: 'Engro Corporation',
      sector: 'Fertilizer & Conglomerate',
      price: 481.20,
      change: 5.80,
      changePercent: 1.22,
      volume: 2.1,
      marketCap: 258.4,
      peRatio: 6.8,
      dividendYield: 9.5,
      sparkline: [475.0, 476.5, 479.0, 478.0, 480.5, 481.2],
    ),
    StockQuote(
      symbol: 'SYS',
      name: 'Systems Limited',
      sector: 'Technology & Comm.',
      price: 462.90,
      change: 14.50,
      changePercent: 3.23,
      volume: 3.4,
      marketCap: 134.2,
      peRatio: 18.2,
      dividendYield: 2.4,
      sparkline: [448.0, 452.0, 456.0, 459.0, 462.9],
    ),
    StockQuote(
      symbol: 'LUCK',
      name: 'Lucky Cement Limited',
      sector: 'Cement',
      price: 654.30,
      change: 2.75,
      changePercent: 0.42,
      volume: 1.6,
      marketCap: 205.1,
      peRatio: 7.1,
      dividendYield: 6.2,
      sparkline: [651.0, 652.0, 653.5, 654.3],
    ),
  ];

  static const List<StockQuote> topLosers = [
    StockQuote(
      symbol: 'OGDC',
      name: 'Oil & Gas Development Co.',
      sector: 'Oil & Gas Exploration',
      price: 287.50,
      change: -2.30,
      changePercent: -0.80,
      volume: 6.2,
      marketCap: 618.0,
      peRatio: 4.2,
      dividendYield: 11.2,
      sparkline: [290.0, 289.0, 288.5, 287.5],
    ),
    StockQuote(
      symbol: 'PSO',
      name: 'Pakistan State Oil',
      sector: 'Oil & Gas Marketing',
      price: 245.10,
      change: -3.80,
      changePercent: -1.53,
      volume: 3.9,
      marketCap: 115.0,
      peRatio: 5.9,
      dividendYield: 7.8,
      sparkline: [249.0, 248.0, 246.5, 245.1],
    ),
    StockQuote(
      symbol: 'HUBC',
      name: 'Hub Power Company',
      sector: 'Power Generation',
      price: 138.25,
      change: -1.15,
      changePercent: -0.82,
      volume: 5.1,
      marketCap: 179.3,
      peRatio: 4.5,
      dividendYield: 15.1,
      sparkline: [139.5, 139.0, 138.8, 138.25],
    ),
  ];

  static List<StockQuote> get allStocks => [...topGainers, ...topLosers];

  static final AiMarketBrief dailyAiBrief = AiMarketBrief(
    headline: 'PSX Gains Momentum as KSE-100 Breaks 78,400 Resistance',
    summary:
        'Robust corporate dividend yields in banking (MCB, UBL) and strong buying in technology counters (SYS) spearheaded the rally. Institutional liquidity remains high amidst foreign inflow interest.',
    sentiment: 'Bullish',
    keyDrivers: [
      'Banking sector reporting record margins & high dividend yields',
      'Stable PKR exchange rate and positive macroeconomic indicators',
      'Tech sector export revenue rebound led by Systems Limited',
    ],
    actionableInsight:
        'Watch for consolidation near 78,600 points. High-dividend banking stocks provide strong downside protection.',
    timestamp: DateTime.now(),
  );

  static const List<FinancialNews> latestNews = [
    FinancialNews(
      id: 'news-1',
      title: 'State Bank of Pakistan keeps key interest rate stable at policy review',
      source: 'Business Recorder',
      timeAgo: '25m ago',
      category: 'Macroeconomics',
      summary:
          'The Monetary Policy Committee noted stabilizing inflation trends and favorable foreign exchange reserves.',
    ),
    FinancialNews(
      id: 'news-2',
      title: 'MCB Bank declares interim cash dividend of Rs. 9.00 per share',
      source: 'PSX Announcements',
      timeAgo: '1h ago',
      category: 'Corporate Action',
      summary:
          'MCB recorded profit after tax expansion of 18% YoY in Q2, beating analyst consensus forecasts.',
      relatedSymbol: 'MCB',
    ),
    FinancialNews(
      id: 'news-3',
      title: 'Engro Corp expands green energy and logistics footprint',
      source: 'Dawn Financials',
      timeAgo: '3h ago',
      category: 'Industry',
      summary:
          'Engro subsidiaries announce strategic capital allocation toward high-yield industrial renewables.',
      relatedSymbol: 'ENGRO',
    ),
  ];
}
