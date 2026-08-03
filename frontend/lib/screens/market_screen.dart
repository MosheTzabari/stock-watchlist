import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stock_watchlist_provider.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/stock_table.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(
      stockWatchlistProvider.select(
        (state) => (
          isLoading: state.isLoading,
          initialError: state.stocks.isEmpty ? state.errorMessage : null,
          stocks: state.stocks,
        ),
      ),
    );

    if (viewState.isLoading) {
      return const LoadingView();
    }
    if (viewState.initialError != null) {
      return ErrorView(
        message: viewState.initialError!,
        onRetry: ref.read(stockWatchlistProvider.notifier).load,
      );
    }

    return StockTable(
      stocks: viewState.stocks,
      emptyMessage: 'No stocks are available in the market.',
      onToggle: (ticker) => _toggle(context, ref, ticker),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    String ticker,
  ) async {
    try {
      await ref.read(stockWatchlistProvider.notifier).toggleWatchlist(ticker);
    } catch (_) {
      if (context.mounted) {
        final message = ref.read(stockWatchlistProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message ?? 'The watchlist could not be updated.'),
          ),
        );
      }
    }
  }
}
