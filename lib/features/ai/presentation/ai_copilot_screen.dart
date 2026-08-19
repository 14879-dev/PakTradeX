import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';

class AiCopilotScreen extends StatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  State<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends State<AiCopilotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'ai',
      'text':
          'Assalam-o-Alaikum! I am your PakTradeX AI Financial Copilot.\n\nI can analyze PSX stocks, explain Pakistani financial terms in English or Urdu, screen high-dividend stocks, and review your portfolio health.\n\nHow can I assist your investment research today?',
    },
  ];

  final List<String> _suggestedPrompts = [
    'Analyze MCB Bank fundamentals',
    'Find high dividend PSX stocks',
    'Explain P/E ratio in Urdu',
    'How does KSE-100 index work?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 20),
            const SizedBox(width: 8),
            Text(
              'PakTradeX AI Copilot',
              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Suggested prompts
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestedPrompts.map((prompt) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(prompt),
                      labelStyle: AppTypography.labelSmall.copyWith(color: AppColors.primary),
                      backgroundColor: AppColors.primaryLight,
                      side: BorderSide.none,
                      onPressed: () {
                        _sendMessage(prompt);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Chat messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(14),
                          topRight: const Radius.circular(14),
                          bottomLeft: Radius.circular(isUser ? 14 : 2),
                          bottomRight: Radius.circular(isUser ? 2 : 14),
                        ),
                        border: isUser ? null : Border.all(color: AppColors.border),
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Text(
                        msg['text']!,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isUser ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask AI about PSX stocks or market trends...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.roundedMd,
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
    });
    _controller.clear();

    // Simulated Intelligent Response
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        if (text.toLowerCase().contains('mcb')) {
          _messages.add({
            'role': 'ai',
            'text':
                '📊 **MCB Bank Limited (PSX: MCB)** Analysis:\n\n• **Price**: Rs. 322.40 (+2.14%)\n• **P/E Ratio**: 5.4x (Sector Avg: 6.2x)\n• **Dividend Yield**: 12.8% (High)\n• **ROE**: ~31.2%\n\n💡 **AI Verdict**: MCB is one of the highest quality banks in Pakistan with strong asset quality, record NIMs, and a reliable quarterly dividend track record.',
          });
        } else if (text.toLowerCase().contains('dividend')) {
          _messages.add({
            'role': 'ai',
            'text':
                '📈 **Top High Dividend Yield Stocks on PSX**:\n\n1. **HUBC** (Hub Power) ~ 15.1% Yield\n2. **MCB** (MCB Bank) ~ 12.8% Yield\n3. **OGDC** (Oil & Gas) ~ 11.2% Yield\n4. **ENGRO** (Engro Corp) ~ 9.5% Yield\n\n*Note: High dividend yields should be balanced with earnings stability and corporate debt levels.*',
          });
        } else if (text.toLowerCase().contains('urdu') || text.toLowerCase().contains('p/e')) {
          _messages.add({
            'role': 'ai',
            'text':
                '📖 **P/E Ratio (Price-to-Earnings) کی آسان وضاحت**:\n\nپی/ای ریشو بتاتا ہے کہ کمپنی کے 1 روپے کے منافع (Earnings) کے بدلے سرمایہ کار مارکیٹ میں کتنی قیمت ادا کرنے کو تیار ہیں۔ اگر کسی کمپنی کا P/E کم ہے، تو عام طور پر اس کا شیئر سستا سمجھا جاتا ہے۔',
          });
        } else {
          _messages.add({
            'role': 'ai',
            'text':
                'I have retrieved real-time contextual data for the Pakistan Stock Exchange. The market sentiment is currently **Bullish** with KSE-100 trading at **78,420 points**. High institutional liquidity and robust dividend yield forecasts continue to support equities.',
          });
        }
      });
    });
  }
}
