import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../home/data/mock_market_data.dart';
import '../models/news_item.dart';
import '../providers/news_provider.dart';

class NewsDetailScreen extends ConsumerWidget {
  final NewsArticle article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(newsProvider).bookmarkedIds.contains(article.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          article.category,
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.primary : AppColors.textSecondary,
            ),
            tooltip: isSaved ? 'Remove Bookmark' : 'Save Article',
            onPressed: () {
              ref.read(newsProvider.notifier).toggleBookmark(article.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article link copied to clipboard')),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${article.source} · ${article.publishedAt}',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  '${article.readingTimeMinutes} min read',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(
              article.title,
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, height: 1.3),
            ),
            const SizedBox(height: AppSpacing.md),

            // AI Takeaways Box
            AppCard(
              backgroundColor: AppColors.aiAccentLight,
              border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.3)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'AI Key Market Takeaways',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.aiAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...article.aiKeyTakeaways.map(
                    (takeaway) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: AppColors.aiAccent, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              takeaway,
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Full Article Body
            Text(
              article.fullContent,
              style: AppTypography.bodyMedium.copyWith(
                height: 1.6,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Related Stock Card
            if (article.relatedStockSymbol != null) ...[
              Text('Related Asset', style: AppTypography.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                onTap: () {
                  final stock = MockMarketData.allStocks.firstWhere(
                    (s) => s.symbol == article.relatedStockSymbol,
                    orElse: () => MockMarketData.allStocks.first,
                  );
                  context.push('/home/stock/${stock.symbol}', extra: stock);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: AppRadius.roundedMd,
                          ),
                          child: Text(
                            article.relatedStockSymbol!,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Live Stock Quote',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Explore real-time order book & financials',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
