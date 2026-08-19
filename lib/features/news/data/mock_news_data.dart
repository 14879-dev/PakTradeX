import '../models/news_item.dart';

abstract class MockNewsData {
  static const List<NewsArticle> articles = [
    NewsArticle(
      id: 'news-1',
      title: 'SBP Monetary Policy Committee Signals Further Interest Rate Easing',
      source: 'Business Recorder',
      publishedAt: '25m ago',
      category: 'Economy',
      sentiment: NewsSentiment.bullish,
      readingTimeMinutes: 3,
      relatedStockSymbol: 'MCB',
      summary:
          'State Bank of Pakistan notes headline CPI inflation decelerating to single digits, paving the way for further key policy rate cuts to stimulate commercial credit growth.',
      fullContent:
          'The Monetary Policy Committee (MPC) of the State Bank of Pakistan observed that macroeconomic stability is consolidating with foreign exchange reserves building up steadily above \$14 billion.\n\n'
          'With headline inflation showing sharp deceleration, real interest rates remain comfortably positive. Lower borrowing costs are expected to boost industrial CAPEX, corporate debt restructuring, and consumer demand across manufacturing and tech sectors.\n\n'
          'Market participants anticipate aggressive equity re-rating as institutional asset allocators shift capital from fixed-income instruments back into high-yielding PSX equities.',
      aiKeyTakeaways: [
        'Headline inflation drop provides room for monetary easing.',
        'Banking NIMs will compress slightly, but private credit volume will surge.',
        'Cyclical sectors like Cement (LUCK) and Auto will benefit from cheaper financing.',
      ],
    ),
    NewsArticle(
      id: 'news-2',
      title: 'Energy Circular Debt Settlement Plan Reaches Final Approval Stage',
      source: 'Dawn News Business',
      publishedAt: '1h ago',
      category: 'Energy',
      sentiment: NewsSentiment.bullish,
      readingTimeMinutes: 4,
      relatedStockSymbol: 'OGDC',
      summary:
          'Ministry of Energy and Finance finalize a structured dividend and cash-settlement mechanism to clear overdue receivables across state-owned E&P giants including OGDC, PPL, and PSO.',
      fullContent:
          'The federal government has finalized a landmark resolution framework aimed at resolving the multi-trillion rupee circular debt bottleneck crippling Pakistan\'s energy supply chain.\n\n'
          'Under the approved structure, clearing overdue gas and power subsidies will inject massive liquidity directly into Oil and Gas Development Company (OGDC) and Pakistan Petroleum Limited (PPL).\n\n'
          'The unlocked cashflows are expected to fund aggressive domestic offshore exploration, new drilling concessions, and special cash dividend disbursements to shareholders.',
      aiKeyTakeaways: [
        'Massive cash injection directly into OGDC and PPL balance sheets.',
        'Significant upside potential for special cash dividends.',
        'Improves sovereign fiscal rating and energy sector operational sustainability.',
      ],
    ),
    NewsArticle(
      id: 'news-3',
      title: 'Systems Limited (SYS) Secures \$45M Digital Transformation Contract in GCC',
      source: 'Profit by Pakistan Today',
      publishedAt: '3h ago',
      category: 'Tech',
      sentiment: NewsSentiment.bullish,
      readingTimeMinutes: 2,
      relatedStockSymbol: 'SYS',
      summary:
          'Pakistan\'s premier IT exporter SYS expands enterprise software footprint in Saudi Arabia and UAE with a multi-year cloud architecture and digital banking contract.',
      fullContent:
          'Systems Limited (PSX: SYS) announced that its Middle Eastern subsidiary has inked a major \$45 million multi-year enterprise transformation engagement with a Tier-1 financial consortium in Riyadh.\n\n'
          'The mandate encompasses cloud modernization, AI-assisted credit underwriting engines, and regulatory compliance automation.\n\n'
          'Export remittances from SYS continue to demonstrate double-digit dollar-denominated growth, insulating the tech heavyweight from domestic currency fluctuations.',
      aiKeyTakeaways: [
        'USD-based revenues strengthen FX hedge for Pakistan investors.',
        'Expands footprint in high-margin Saudi Vision 2030 modernization programs.',
        'Reinforces SYS status as Pakistan\'s flagship technology stock.',
      ],
    ),
    NewsArticle(
      id: 'news-4',
      title: 'Engro Corp Strategic Realignment and Fertilizer Distribution Growth',
      source: 'The News International',
      publishedAt: '5h ago',
      category: 'Corporate',
      sentiment: NewsSentiment.neutral,
      readingTimeMinutes: 3,
      relatedStockSymbol: 'ENGRO',
      summary:
          'Engro Corporation completes strategic portfolio review focusing on agricultural value-chain resilience, specialty chemicals, and renewable energy infrastructure.',
      fullContent:
          'Engro Corporation (PSX: ENGRO) detailed its capital allocation strategy for the next five years, emphasizing domestic food security through enhanced urea availability and international chemical trading.\n\n'
          'Despite seasonal gas tariff revisions, operational efficiencies across EnVen plant ensured industry-leading capacity utilization.\n\n'
          'The conglomerate maintains an investment-grade credit rating with robust cash distribution yields for long-term institutional and retail investors.',
      aiKeyTakeaways: [
        'High defensive qualities against domestic economic cyclicality.',
        'Steady dividend distribution track record supported by diverse subsidiary revenue.',
      ],
    ),
  ];
}
