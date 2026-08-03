import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stock.dart';
import '../providers/stock_watchlist_provider.dart';

class StockRow extends ConsumerWidget {
  const StockRow({required this.stock, required this.onToggle, super.key});

  final Stock stock;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWatched = ref.watch(
      stockWatchlistProvider.select(
        (state) => state.watchedTickers.contains(stock.ticker),
      ),
    );
    final isMutating = ref.watch(
      stockWatchlistProvider.select(
        (state) => state.mutatingTickers.contains(stock.ticker),
      ),
    );

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              stock.ticker,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(flex: 3, child: Text(stock.company)),
          Expanded(child: Text(stock.marketCap, textAlign: TextAlign.right)),
          Expanded(
            child: Text(
              stock.psRatio.toStringAsFixed(2),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              stock.dailyChange,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _changeColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Opacity(
              opacity: isMutating ? 0.45 : 1,
              child: IconButton(
                tooltip: isWatched
                    ? 'Remove ${stock.ticker} from watchlist'
                    : 'Add ${stock.ticker} to watchlist',
                onPressed: isMutating ? null : onToggle,
                icon: Icon(
                  isWatched ? Icons.star : Icons.star_outline,
                  color: isWatched ? Colors.amber.shade700 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _changeColor(BuildContext context) {
    final value = stock.dailyChange.trim();
    if (value.startsWith('-')) {
      return Theme.of(context).colorScheme.error;
    }
    if (value.startsWith('+')) {
      return Colors.green.shade700;
    }
    return null;
  }
}
