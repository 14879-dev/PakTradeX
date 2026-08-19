enum NewsSentiment { bullish, bearish, neutral }

class NewsArticle {
  final String id;
  final String title;
  final String source;
  final String publishedAt;
  final String category; // 'Economy', 'Banking', 'Energy', 'Tech', 'Corporate'
  final String summary;
  final String fullContent;
  final NewsSentiment sentiment;
  final String? relatedStockSymbol;
  final List<String> aiKeyTakeaways;
  final int readingTimeMinutes;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.source,
    required this.publishedAt,
    required this.category,
    required this.summary,
    required this.fullContent,
    required this.sentiment,
    required this.aiKeyTakeaways,
    this.relatedStockSymbol,
    this.readingTimeMinutes = 2,
  });
}
