import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock.dart';
import '../services/stock_api_service.dart';

final stockApiServiceProvider = Provider<StockApiService>(
  (ref) => StockApiService(),
);

final stockWatchlistProvider =
    NotifierProvider<StockWatchlistNotifier, StockWatchlistState>(
      StockWatchlistNotifier.new,
    );

class StockWatchlistState {
  const StockWatchlistState({
    this.stocks = const [],
    this.watchedTickers = const {},
    this.isLoading = true,
    this.errorMessage,
    this.mutatingTickers = const {},
  });

  final List<Stock> stocks;
  final Set<String> watchedTickers;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> mutatingTickers;

  StockWatchlistState copyWith({
    List<Stock>? stocks,
    Set<String>? watchedTickers,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    Set<String>? mutatingTickers,
  }) {
    return StockWatchlistState(
      stocks: stocks ?? this.stocks,
      watchedTickers: watchedTickers ?? this.watchedTickers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      mutatingTickers: mutatingTickers ?? this.mutatingTickers,
    );
  }
}

class StockWatchlistNotifier extends Notifier<StockWatchlistState> {
  late final StockApiService _apiService;

  @override
  StockWatchlistState build() {
    _apiService = ref.watch(stockApiServiceProvider);
    Future<void>.microtask(load);
    return const StockWatchlistState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _apiService.fetchStocks(),
        _apiService.fetchWatchlist(),
      ]);
      state = state.copyWith(
        stocks: results[0],
        watchedTickers: results[1].map((stock) => stock.ticker).toSet(),
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFor(error),
      );
    }
  }

  Future<void> toggleWatchlist(String ticker) async {
    if (state.mutatingTickers.contains(ticker)) {
      return;
    }

    final mutating = {...state.mutatingTickers, ticker};
    state = state.copyWith(mutatingTickers: mutating, clearError: true);
    try {
      final watched = {...state.watchedTickers};
      if (watched.contains(ticker)) {
        await _apiService.removeFromWatchlist(ticker);
        watched.remove(ticker);
      } else {
        await _apiService.addToWatchlist(ticker);
        watched.add(ticker);
      }
      state = state.copyWith(watchedTickers: watched, clearError: true);
    } catch (error) {
      state = state.copyWith(errorMessage: _messageFor(error));
      rethrow;
    } finally {
      state = state.copyWith(
        mutatingTickers: {...state.mutatingTickers}..remove(ticker),
      );
    }
  }

  String _messageFor(Object error) {
    if (error is StockApiException) {
      return error.message;
    }
    return 'Unable to reach the backend. Check that it is running and retry.';
  }
}
