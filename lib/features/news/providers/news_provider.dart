import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_news_data.dart';
import '../models/news_item.dart';

class NewsState {
  final List<NewsArticle> articles;
  final String selectedCategory;
  final List<String> bookmarkedIds;

  const NewsState({
    required this.articles,
    required this.selectedCategory,
    required this.bookmarkedIds,
  });

  List<NewsArticle> get filteredArticles {
    if (selectedCategory == 'All') {
      return articles;
    } else if (selectedCategory == 'Saved') {
      return articles.where((a) => bookmarkedIds.contains(a.id)).toList();
    }
    return articles.where((a) => a.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
  }

  NewsState copyWith({
    List<NewsArticle>? articles,
    String? selectedCategory,
    List<String>? bookmarkedIds,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier()
      : super(
          const NewsState(
            articles: MockNewsData.articles,
            selectedCategory: 'All',
            bookmarkedIds: ['news-1'],
          ),
        );

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleBookmark(String articleId) {
    final current = List<String>.from(state.bookmarkedIds);
    if (current.contains(articleId)) {
      current.remove(articleId);
    } else {
      current.add(articleId);
    }
    state = state.copyWith(bookmarkedIds: current);
  }

  bool isBookmarked(String articleId) => state.bookmarkedIds.contains(articleId);
}

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier();
});
