import 'package:flutter_riverpod/flutter_riverpod.dart';

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(['MCB', 'ENGRO', 'SYS']);

  void addToWatchlist(String symbol) {
    if (!state.contains(symbol)) {
      state = [...state, symbol];
    }
  }

  void removeFromWatchlist(String symbol) {
    state = state.where((s) => s != symbol).toList();
  }

  void toggle(String symbol) {
    if (state.contains(symbol)) {
      removeFromWatchlist(symbol);
    } else {
      addToWatchlist(symbol);
    }
  }

  bool isInWatchlist(String symbol) => state.contains(symbol);
}

final watchlistProvider = StateNotifierProvider<WatchlistNotifier, List<String>>((ref) {
  return WatchlistNotifier();
});
