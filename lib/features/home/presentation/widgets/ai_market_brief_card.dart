import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../models/market_data_models.dart';

class AiMarketBriefCard extends StatelessWidget {
  final AiMarketBrief brief;
  final VoidCallback? onAskCopilotTap;

  const AiMarketBriefCard({
    super.key,
    required this.brief,
    this.onAskCopilotTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.surface,
      border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.25), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: AI Badge + Sentiment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.aiAccentLight,
                      borderRadius: AppRadius.roundedSm,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.aiAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI MARKET BRIEF',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.aiAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Text(
                  brief.sentiment.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Headline
          Text(
            brief.headline,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Summary
          Text(
            brief.summary,
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          // Key Drivers List
          Text(
            'Key Catalysts:',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...brief.keyDrivers.map(
            (driver) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.aiAccent, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      driver,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Actionable Insight box
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: AppRadius.roundedSm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    brief.actionableInsight,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Button to ask AI
          InkWell(
            onTap: onAskCopilotTap,
            borderRadius: AppRadius.roundedSm,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.3)),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.aiAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Ask AI Copilot for Market Analysis',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.aiAccent,
                      fontWeight: FontWeight.w700,
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
}
