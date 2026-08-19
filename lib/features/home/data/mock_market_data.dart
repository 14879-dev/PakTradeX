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

  // ── All PSX Stocks (20+ across all major sectors) ─────────────────
  static const List<StockQuote> allPsxStocks = [
    // Commercial Banks
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
      symbol: 'HBL',
      name: 'Habib Bank Limited',
      sector: 'Commercial Banks',
      price: 198.60,
      change: 3.20,
      changePercent: 1.64,
      volume: 5.2,
      marketCap: 288.1,
      peRatio: 4.8,
      dividendYield: 10.5,
      sparkline: [195.0, 196.0, 197.5, 198.6],
    ),
    StockQuote(
      symbol: 'UBL',
      name: 'United Bank Limited',
      sector: 'Commercial Banks',
      price: 245.80,
      change: -1.40,
      changePercent: -0.57,
      volume: 3.7,
      marketCap: 321.0,
      peRatio: 5.1,
      dividendYield: 11.2,
      sparkline: [247.2, 246.8, 246.2, 245.8],
    ),
    StockQuote(
      symbol: 'MEBL',
      name: 'Meezan Bank Limited',
      sector: 'Commercial Banks',
      price: 189.30,
      change: 4.10,
      changePercent: 2.21,
      volume: 6.1,
      marketCap: 270.4,
      peRatio: 6.2,
      dividendYield: 8.9,
      sparkline: [185.0, 186.5, 188.0, 189.3],
    ),
    StockQuote(
      symbol: 'BAFL',
      name: 'Bank Alfalah Limited',
      sector: 'Commercial Banks',
      price: 54.10,
      change: 0.80,
      changePercent: 1.50,
      volume: 8.4,
      marketCap: 62.5,
      peRatio: 4.2,
      dividendYield: 9.8,
      sparkline: [53.2, 53.5, 53.9, 54.1],
    ),

    // Technology & Communication
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
      symbol: 'TRG',
      name: 'TRG Pakistan Limited',
      sector: 'Technology & Comm.',
      price: 121.50,
      change: 5.30,
      changePercent: 4.56,
      volume: 9.1,
      marketCap: 48.2,
      peRatio: 22.4,
      dividendYield: 0.0,
      sparkline: [116.0, 118.0, 119.5, 121.5],
    ),
    StockQuote(
      symbol: 'NETSOL',
      name: 'NetSol Technologies Inc.',
      sector: 'Technology & Comm.',
      price: 88.40,
      change: 2.10,
      changePercent: 2.43,
      volume: 2.2,
      marketCap: 12.8,
      peRatio: 14.6,
      dividendYield: 1.8,
      sparkline: [86.0, 87.0, 88.0, 88.4],
    ),

    // Fertilizer
    StockQuote(
      symbol: 'ENGRO',
      name: 'Engro Corporation',
      sector: 'Fertilizer',
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
      symbol: 'FFC',
      name: 'Fauji Fertilizer Company',
      sector: 'Fertilizer',
      price: 148.60,
      change: -2.10,
      changePercent: -1.39,
      volume: 3.5,
      marketCap: 175.3,
      peRatio: 5.9,
      dividendYield: 14.2,
      sparkline: [150.7, 150.2, 149.8, 148.6],
    ),
    StockQuote(
      symbol: 'EFERT',
      name: 'Engro Fertilizers Limited',
      sector: 'Fertilizer',
      price: 98.20,
      change: 1.40,
      changePercent: 1.45,
      volume: 4.0,
      marketCap: 116.5,
      peRatio: 5.2,
      dividendYield: 13.8,
      sparkline: [96.7, 97.2, 97.8, 98.2],
    ),

    // Oil & Gas
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
      symbol: 'PPL',
      name: 'Pakistan Petroleum Limited',
      sector: 'Oil & Gas Exploration',
      price: 178.30,
      change: -0.90,
      changePercent: -0.50,
      volume: 4.4,
      marketCap: 310.5,
      peRatio: 3.8,
      dividendYield: 12.5,
      sparkline: [179.2, 178.9, 178.6, 178.3],
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
      symbol: 'MARI',
      name: 'Mari Petroleum Company',
      sector: 'Oil & Gas Exploration',
      price: 1520.00,
      change: 18.50,
      changePercent: 1.23,
      volume: 0.8,
      marketCap: 456.0,
      peRatio: 6.1,
      dividendYield: 5.9,
      sparkline: [1500.0, 1508.0, 1515.0, 1520.0],
    ),

    // Cement
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
    StockQuote(
      symbol: 'DGKC',
      name: 'D.G. Khan Cement Company',
      sector: 'Cement',
      price: 87.40,
      change: 1.20,
      changePercent: 1.39,
      volume: 3.2,
      marketCap: 44.8,
      peRatio: 8.2,
      dividendYield: 4.5,
      sparkline: [86.0, 86.5, 87.0, 87.4],
    ),
    StockQuote(
      symbol: 'MLCF',
      name: 'Maple Leaf Cement Factory',
      sector: 'Cement',
      price: 62.80,
      change: -0.70,
      changePercent: -1.10,
      volume: 5.8,
      marketCap: 32.4,
      peRatio: 9.5,
      dividendYield: 3.2,
      sparkline: [63.5, 63.2, 63.0, 62.8],
    ),

    // Power Generation
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
    StockQuote(
      symbol: 'KAPCO',
      name: 'Kot Addu Power Company',
      sector: 'Power Generation',
      price: 68.90,
      change: 0.60,
      changePercent: 0.88,
      volume: 2.8,
      marketCap: 55.2,
      peRatio: 5.8,
      dividendYield: 16.4,
      sparkline: [68.2, 68.5, 68.7, 68.9],
    ),

    // Automobiles
    StockQuote(
      symbol: 'INDU',
      name: 'Indus Motor Company',
      sector: 'Automobiles',
      price: 1485.00,
      change: 22.50,
      changePercent: 1.54,
      volume: 0.4,
      marketCap: 211.5,
      peRatio: 9.1,
      dividendYield: 8.4,
      sparkline: [1460.0, 1468.0, 1478.0, 1485.0],
    ),
    StockQuote(
      symbol: 'HCAR',
      name: 'Honda Atlas Cars (Pak)',
      sector: 'Automobiles',
      price: 342.80,
      change: -4.20,
      changePercent: -1.21,
      volume: 0.9,
      marketCap: 38.6,
      peRatio: 11.2,
      dividendYield: 5.0,
      sparkline: [347.0, 345.5, 344.0, 342.8],
    ),
    StockQuote(
      symbol: 'PSMC',
      name: 'Pak Suzuki Motor Co.',
      sector: 'Automobiles',
      price: 895.50,
      change: 12.30,
      changePercent: 1.39,
      volume: 0.6,
      marketCap: 68.4,
      peRatio: 13.5,
      dividendYield: 3.1,
      sparkline: [882.0, 886.0, 891.0, 895.5],
    ),

    // Pharmaceuticals
    StockQuote(
      symbol: 'SEARL',
      name: 'The Searle Company',
      sector: 'Pharmaceuticals',
      price: 315.40,
      change: 7.80,
      changePercent: 2.54,
      volume: 1.1,
      marketCap: 42.5,
      peRatio: 15.4,
      dividendYield: 3.5,
      sparkline: [307.0, 309.5, 313.0, 315.4],
    ),
    StockQuote(
      symbol: 'FEROZ',
      name: 'Ferozsons Laboratories',
      sector: 'Pharmaceuticals',
      price: 254.70,
      change: -2.60,
      changePercent: -1.01,
      volume: 0.5,
      marketCap: 15.2,
      peRatio: 12.8,
      dividendYield: 4.2,
      sparkline: [257.3, 256.8, 255.5, 254.7],
    ),

    // Textile
    StockQuote(
      symbol: 'NML',
      name: 'Nishat Mills Limited',
      sector: 'Textile',
      price: 148.50,
      change: 2.30,
      changePercent: 1.57,
      volume: 2.6,
      marketCap: 75.2,
      peRatio: 8.4,
      dividendYield: 7.2,
      sparkline: [146.0, 147.0, 148.0, 148.5],
    ),

    // Insurance
    StockQuote(
      symbol: 'JLICL',
      name: 'Jubilee Life Insurance',
      sector: 'Insurance',
      price: 482.30,
      change: 5.10,
      changePercent: 1.07,
      volume: 0.7,
      marketCap: 38.6,
      peRatio: 11.5,
      dividendYield: 2.8,
      sparkline: [476.8, 479.0, 481.0, 482.3],
    ),
  ];

  // ── Derived subsets ───────────────────────────────────────────────
  static List<StockQuote> get topGainers => allPsxStocks
      .where((s) => s.changePercent > 0)
      .toList()
    ..sort((a, b) => b.changePercent.compareTo(a.changePercent));

  static List<StockQuote> get topLosers => allPsxStocks
      .where((s) => s.changePercent < 0)
      .toList()
    ..sort((a, b) => a.changePercent.compareTo(b.changePercent));

  static List<StockQuote> get volumeLeaders => [...allPsxStocks]
    ..sort((a, b) => b.volume.compareTo(a.volume));

  static List<StockQuote> get allStocks => allPsxStocks;

  static final AiMarketBrief dailyAiBrief = AiMarketBrief(
    headline: 'PSX Gains Momentum as KSE-100 Breaks 78,400 Resistance',
    summary:
        'Robust corporate dividend yields in banking (MCB, UBL) and strong buying in technology counters (SYS, TRG) spearheaded the rally. Institutional liquidity remains high amidst foreign inflow interest.',
    sentiment: 'Bullish',
    keyDrivers: [
      'Banking sector reporting record margins & high dividend yields',
      'Stable PKR exchange rate and positive macroeconomic indicators',
      'Tech sector export revenue rebound led by Systems Limited & TRG',
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
    FinancialNews(
      id: 'news-4',
      title: 'TRG Pakistan posts record IT export earnings, eyes US expansion',
      source: 'The News International',
      timeAgo: '5h ago',
      category: 'Technology',
      summary:
          'TRG Pakistan achieved record-high quarterly revenues driven by BPO and digital services contracts.',
      relatedSymbol: 'TRG',
    ),
    FinancialNews(
      id: 'news-5',
      title: 'HUBC announces Rs. 2.50 per share final dividend amid energy sector challenges',
      source: 'PSX Announcements',
      timeAgo: '8h ago',
      category: 'Corporate Action',
      summary:
          'Hub Power Company maintained strong cash flows despite circular debt concerns affecting the power sector.',
      relatedSymbol: 'HUBC',
    ),
  ];
}
