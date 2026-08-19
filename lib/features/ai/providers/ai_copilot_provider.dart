import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../models/ai_message.dart';

class AiCopilotState {
  final List<AiMessage> messages;
  final bool isGenerating;
  final String language; // 'English', 'Roman Urdu', 'Urdu'

  const AiCopilotState({
    required this.messages,
    required this.isGenerating,
    this.language = 'English',
  });

  AiCopilotState copyWith({
    List<AiMessage>? messages,
    bool? isGenerating,
    String? language,
  }) {
    return AiCopilotState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      language: language ?? this.language,
    );
  }
}

class AiCopilotNotifier extends StateNotifier<AiCopilotState> {
  AiCopilotNotifier()
      : super(
          AiCopilotState(
            isGenerating: false,
            messages: [
              AiMessage(
                id: 'init-1',
                text:
                    'Assalam-o-Alaikum! I am your **PakTradeX AI Financial Copilot**.\n\nI can assist you with:\n• PSX Stock analysis (Fundamentals, P/E, Div Yield)\n• KMI-30 Islamic Shariah screening & compliance criteria\n• SBP Monetary Policy & inflation impact on Pakistani equities\n• Plain English and Urdu explanations of complex financial metrics\n\nHow can I empower your investment research today?',
                isUser: false,
                timestamp: DateTime.now(),
                confidenceScore: 0.98,
                sentiment: AiSentiment.informative,
                citations: ['PSX Market Rules', 'SBP Statistical Bulletin', 'SECP Guidelines'],
                actionPrompts: [
                  'Analyze MCB Bank',
                  'High dividend PSX stocks',
                  'Is SYS Shariah compliant?',
                  'Explain Beta in Urdu',
                ],
              ),
            ],
          ),
        );

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void clearChat() {
    state = state.copyWith(messages: [
      AiMessage(
        id: 'new-session-${DateTime.now().millisecondsSinceEpoch}',
        text: 'New session started. Ask any question regarding Pakistan capital markets, stock valuations, or portfolio risk.',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.99,
        sentiment: AiSentiment.informative,
      ),
    ]);
  }

  Future<void> sendUserQuery(String prompt) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = AiMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: prompt,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isGenerating: true,
    );

    await Future.delayed(const Duration(milliseconds: 750));

    // Try live Backend Gemini AI call first
    try {
      final res = await apiClient.post('/copilot/query', data: {
        'prompt': prompt,
        'language': state.language,
      });

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final d = res.data as Map<String, dynamic>;
        final text = d['text'] as String? ?? '';
        final conf = (d['confidenceScore'] as num?)?.toDouble() ?? 0.95;
        final sentStr = d['sentiment'] as String? ?? 'neutral';
        final citList = (d['citations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Gemini AI'];
        final actList = (d['actionPrompts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final sym = d['relatedStockSymbol'] as String?;

        AiSentiment sentiment = AiSentiment.neutral;
        if (sentStr == 'bullish') sentiment = AiSentiment.bullish;
        if (sentStr == 'bearish') sentiment = AiSentiment.bearish;
        if (sentStr == 'informative') sentiment = AiSentiment.informative;

        final aiLiveResponse = AiMessage(
          id: d['id'] as String? ?? 'ai-${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          confidenceScore: conf,
          sentiment: sentiment,
          relatedStockSymbol: sym,
          citations: citList,
          actionPrompts: actList,
        );

        state = state.copyWith(
          messages: [...state.messages, aiLiveResponse],
          isGenerating: false,
        );
        return;
      }
    } catch (_) {
      // Backend offline or unreachable — fallback to local knowledge engine below
    }

    final queryLower = prompt.toLowerCase();
    AiMessage aiResponse;

    if (queryLower.contains('mcb')) {
      aiResponse = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            '📊 **MCB Bank Limited (PSX: MCB) Fundamental Breakdown**:\n\n'
            '• **Current Price**: Rs. 322.40\n'
            '• **P/E Ratio**: 5.4x (Favorable vs Banking sector avg of 6.2x)\n'
            '• **Dividend Yield**: 12.8% (Consistently high quarterly payout ratio)\n'
            '• **Return on Equity (ROE)**: ~31.2%\n'
            '• **Non-Performing Loan (NPL) Ratio**: Sub-4.5% with high coverage\n\n'
            '🔍 **Key Catalyst**: MCB maintains superior low-cost CASA deposit franchise (~70%), protecting net interest margins even during SBP policy rate adjustment cycles.',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.96,
        sentiment: AiSentiment.bullish,
        relatedStockSymbol: 'MCB',
        citations: ['MCB Annual Financial Statements 2024', 'PSX Daily Quotations', 'SBP Banking Review'],
        actionPrompts: ['Compare MCB vs MEBL', 'View MCB Order Book', 'Check Banking Sector Overview'],
      );
    } else if (queryLower.contains('dividend') || queryLower.contains('yield')) {
      aiResponse = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            '💰 **Top PSX Dividend Champions (Simulated Screener)**:\n\n'
            '1. **HUBC (Hub Power Co.)** — ~15.1% Div Yield · Consistent dividend payout track record.\n'
            '2. **MCB (MCB Bank)** — ~12.8% Div Yield · Quarterly dividends, high capital adequacy.\n'
            '3. **OGDC (Oil & Gas Dev Co.)** — ~11.2% Div Yield · Strong sovereign cashflows and reserves.\n'
            '4. **ENGRO (Engro Corp)** — ~9.5% Div Yield · Diversified conglomerate with steady distributions.\n\n'
            '💡 *Investor Insight*: Always verify dividend sustainability against free cash flow generation and corporate leverage ratios.',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.94,
        sentiment: AiSentiment.bullish,
        citations: ['PSX Corporate Announcements', 'Mutual Funds Association of Pakistan (MUFAP)'],
        actionPrompts: ['Analyze HUBC', 'Analyze ENGRO', 'Explain Dividend Tax in Pakistan'],
      );
    } else if (queryLower.contains('shariah') || queryLower.contains('islamic') || queryLower.contains('kmi')) {
      aiResponse = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            '🕌 **KMI-30 Shariah Screening Compliance Guidelines**:\n\n'
            'To qualify under the KMI (KSE-Meezan Index) Shariah screening methodology, a company must pass 6 core tests:\n\n'
            '1. **Core Business**: Must not involve prohibited activities (conventional banking, alcohol, gambling, etc.)\n'
            '2. **Debt to Total Assets**: Interest-bearing debt must be < 37% of total assets.\n'
            '3. **Non-Compliant Investments**: Interest-earning investments must be < 33% of total assets.\n'
            '4. **Non-Compliant Income**: Income from impermissible sources must be < 5% of total revenue.\n'
            '5. **Illiquid Assets Ratio**: Illiquid assets must be at least 25% of total assets.\n'
            '6. **Market Price / Net Liquid Assets**: Share price must be greater than net liquid assets per share.',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.98,
        sentiment: AiSentiment.informative,
        citations: ['Al-Meezan Investment Management Shariah Board', 'KMI-30 Technical Index Criteria'],
        actionPrompts: ['Is ENGRO Shariah Compliant?', 'Is SYS Shariah Compliant?', 'List KMI-30 Stocks'],
      );
    } else if (queryLower.contains('urdu') || queryLower.contains('اردو')) {
      aiResponse = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            '📖 **اسٹاک مارکیٹ کی بنیادی اصطلاحات کی آسان وضاحت**:\n\n'
            '• **P/E Ratio (پرائس ٹو ارننگ)**: یہ بتاتا ہے کہ کمپنی کے 1 روپے کے منافع کے بدلے آپ کتنی قیمت ادا کر رہے ہیں۔ کم P/E کا مطلب عام طور پر مناسب قیمت والا شیئر ہے۔\n'
            '• **Dividend Yield (ڈیویڈنڈ ریٹ)**: یہ وہ فیصد منافع ہے جو کمپنی اپنے شیئر ہولڈرز کو نقد منافع کی صورت میں واپس دیتی ہے۔\n'
            '• **Market Cap (مارکیٹ کیپٹلائزیشن)**: تمام جاری شدہ شیئرز کی مجموعی مارکیٹ ویلیو۔\n'
            '• **Stop Loss (اسٹاپ لاس)**: نقصان کو محدود رکھنے کے لیے پہلے سے طے شدہ قیمت پر شیئر بیچنے کا خودکار آرڈر۔',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.99,
        sentiment: AiSentiment.informative,
        citations: ['SECP Jamapunji Financial Literacy Portal', 'PSX Investor Education Guides'],
        actionPrompts: ['Explain Diversification in Urdu', 'How to open CDC Sub-Account in Urdu'],
      );
    } else {
      aiResponse = AiMessage(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        text:
            '📈 **PSX Market Intelligence Summary**:\n\n'
            'The benchmark **KSE-100** is hovering around key support levels with active participation from local mutual funds and institutional liquidity.\n\n'
            '• **Macro Catalysts**: Current account balance stability, foreign exchange reserve build-up at SBP, and anticipated policy rate moderation.\n'
            '• **High-Momentum Sectors**: Commercial Banks, Exploration & Production (E&P), and IT Services.\n'
            '• **Risk Factors**: Energy sector circular debt settlement speed and international oil price volatility.\n\n'
            'Would you like a specific deep dive into any sector or listed ticker?',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.92,
        sentiment: AiSentiment.neutral,
        citations: ['PSX Market Data Feed', 'State Bank of Pakistan (SBP) Monetary Policy Releases'],
        actionPrompts: ['Analyze MCB Bank', 'Screen Tech Sector', 'What is Circular Debt?'],
      );
    }

    state = state.copyWith(
      messages: [...state.messages, aiResponse],
      isGenerating: false,
    );
  }
}

final aiCopilotProvider = StateNotifierProvider<AiCopilotNotifier, AiCopilotState>((ref) {
  return AiCopilotNotifier();
});
