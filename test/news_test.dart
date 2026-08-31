import 'package:flutter_test/flutter_test.dart';
import 'package:paktradex/features/news/providers/news_provider.dart';

void main() {
  group('Financial News Feature & State Tests', () {
    test('Initial News state contains articles and default category All', () {
      final notifier = NewsNotifier();
      final state = notifier.state;

      expect(state.articles.isNotEmpty, isTrue);
      expect(state.selectedCategory, equals('All'));
      expect(state.filteredArticles.length, equals(state.articles.length));
    });

    test('Selecting category filters articles accordingly', () {
      final notifier = NewsNotifier();
      notifier.selectCategory('Economy');

      expect(notifier.state.selectedCategory, equals('Economy'));
      for (final article in notifier.state.filteredArticles) {
        expect(article.category.toLowerCase(), equals('economy'));
      }
    });

    test('Toggling bookmark adds/removes article from bookmarkedIds', () {
      final notifier = NewsNotifier();
      const articleId = 'news-2';

      final wasSaved = notifier.isBookmarked(articleId);
      notifier.toggleBookmark(articleId);
      expect(notifier.isBookmarked(articleId), equals(!wasSaved));

      notifier.toggleBookmark(articleId);
      expect(notifier.isBookmarked(articleId), equals(wasSaved));
    });
  });
}
