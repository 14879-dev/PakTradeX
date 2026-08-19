enum AiSentiment { bullish, bearish, neutral, informative }

class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final double? confidenceScore;
  final List<String>? citations;
  final AiSentiment? sentiment;
  final List<String>? actionPrompts;
  final String? relatedStockSymbol;

  const AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.confidenceScore,
    this.citations,
    this.sentiment,
    this.actionPrompts,
    this.relatedStockSymbol,
  });
}
