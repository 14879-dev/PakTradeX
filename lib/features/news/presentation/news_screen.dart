import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../models/news_item.dart';
import '../providers/news_provider.dart';

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  final List<String> _categories = const ['All', 'Saved', 'Economy', 'Banking', 'Energy', 'Tech', 'Corporate'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsProvider);
    final articles = newsState.filteredArticles;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Financial News & Catalysts',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // Category filter pills
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = newsState.selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      labelStyle: AppTypography.labelSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                      onSelected: (_) {
                        ref.read(newsProvider.notifier).selectCategory(cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Articles List
          Expanded(
            child: articles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bookmark_border_rounded, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: AppSpacing.sm),
                          Text('No Articles Found', style: AppTypography.titleSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Try selecting a different filter category or bookmark articles to read later.',
                            style: AppTypography.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: articles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = articles[index];
                      final isSaved = newsState.bookmarkedIds.contains(item.id);

                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          context.push('/news/detail', extra: item);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Metadata header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildCategoryBadge(item.category),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${item.source} · ${item.publishedAt}',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildSentimentBadge(item.sentiment),
                                    IconButton(
                                      icon: Icon(
                                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                        color: isSaved ? AppColors.primary : AppColors.textSecondary,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref.read(newsProvider.notifier).toggleBookmark(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Title
                            Text(
                              item.title,
                              style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            // Summary
                            Text(
                              item.summary,
                              style: AppTypography.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // Bottom Tags row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.relatedStockSymbol != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: AppRadius.roundedXs,
                                    ),
                                    child: Text(
                                      'PSX: ${item.relatedStockSymbol}',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 12, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.readingTimeMinutes} min read',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String cat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.roundedXs,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        cat,
        style: AppTypography.labelSmall.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSentimentBadge(NewsSentiment sentiment) {
    Color bg;
    Color fg;
    String text;

    switch (sentiment) {
      case NewsSentiment.bullish:
        bg = AppColors.successLight;
        fg = AppColors.success;
        text = '▲ Bullish';
        break;
      case NewsSentiment.bearish:
        bg = AppColors.dangerLight;
        fg = AppColors.danger;
        text = '▼ Bearish';
        break;
      case NewsSentiment.neutral:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        text = '● Neutral';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.roundedXs,
      ),
      child: Text(
        text,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
