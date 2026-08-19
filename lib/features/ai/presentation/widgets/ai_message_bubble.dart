import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../models/ai_message.dart';

class AiMessageBubble extends StatelessWidget {
  final AiMessage message;
  final Function(String prompt)? onActionPromptTap;

  const AiMessageBubble({
    super.key,
    required this.message,
    this.onActionPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('hh:mm a');

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.text,
                      style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(message.timestamp),
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 16, color: AppColors.primary),
            ),
          ],
        ),
      );
    }

    // AI Response Bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.aiAccentLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.aiAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Metadata row (Confidence & Sentiment)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'PakTradeX AI',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.aiAccent,
                            ),
                          ),
                          if (message.confidenceScore != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: AppRadius.roundedXs,
                              ),
                              child: Text(
                                '${(message.confidenceScore! * 100).toInt()}% confidence',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (message.sentiment != null) _buildSentimentBadge(message.sentiment!),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Message text
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),

                  // Citations / Sources
                  if (message.citations != null && message.citations!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Verified Sources:',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: message.citations!.map((c) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.roundedXs,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            '📚 $c',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Action Prompts
                  if (message.actionPrompts != null && message.actionPrompts!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: message.actionPrompts!.map((act) {
                        return ActionChip(
                          label: Text(
                            act,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: AppColors.primaryLight,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          onPressed: () => onActionPromptTap?.call(act),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentBadge(AiSentiment sentiment) {
    Color bg;
    Color fg;
    String label;

    switch (sentiment) {
      case AiSentiment.bullish:
        bg = AppColors.successLight;
        fg = AppColors.success;
        label = '▲ Bullish Bias';
        break;
      case AiSentiment.bearish:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        label = '▼ Bearish Bias';
        break;
      case AiSentiment.neutral:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        label = '● Neutral';
        break;
      case AiSentiment.informative:
        bg = AppColors.aiAccentLight;
        fg = AppColors.aiAccent;
        label = '✦ Educational';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.roundedXs,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
