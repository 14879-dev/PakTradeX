import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/ai/models/ai_message.dart';
import 'package:paktradex/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:paktradex/features/ai/providers/ai_copilot_provider.dart';

void main() {
  group('AI Copilot Feature & Provider Tests', () {
    test('Initial AI Copilot state contains welcome prompt', () {
      final notifier = AiCopilotNotifier();
      final state = notifier.state;

      expect(state.messages.isNotEmpty, isTrue);
      expect(state.messages.first.isUser, isFalse);
      expect(state.isGenerating, isFalse);
      expect(state.messages.first.citations, isNotNull);
    });

    testWidgets('AiMessageBubble renders AI message with citations and sentiment', (tester) async {
      final message = AiMessage(
        id: 'test-1',
        text: 'Test AI response with citations',
        isUser: false,
        timestamp: DateTime.now(),
        confidenceScore: 0.95,
        sentiment: AiSentiment.bullish,
        citations: ['PSX Market Rulebook', 'SBP Circular'],
        actionPrompts: ['Action 1', 'Action 2'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AiMessageBubble(message: message),
            ),
          ),
        ),
      );

      expect(find.text('PakTradeX AI'), findsOneWidget);
      expect(find.text('95% confidence'), findsOneWidget);
      expect(find.text('▲ Bullish Bias'), findsOneWidget);
      expect(find.text('Test AI response with citations'), findsOneWidget);
      expect(find.text('📚 PSX Market Rulebook'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
    });
  });
}
