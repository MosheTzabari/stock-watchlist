import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/stock.dart';
import 'stock_row.dart';

class StockTable extends StatelessWidget {
  const StockTable({
    required this.stocks,
    required this.emptyMessage,
    required this.onToggle,
    super.key,
  });

  final List<Stock> stocks;
  final String emptyMessage;
  final Future<void> Function(String ticker) onToggle;

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 24.0;
        const minimumTableWidth = 960.0;
        const maximumContentWidth = 1200.0;
        final availableWidth = math.max(
          0.0,
          constraints.maxWidth - horizontalPadding * 2,
        );
        final contentWidth = math.min(availableWidth, maximumContentWidth);
        final tableWidth = math.max(contentWidth, minimumTableWidth);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        const _TableHeader(),
                        for (final stock in stocks)
                          StockRow(
                            key: ValueKey(stock.ticker),
                            stock: stock,
                            onToggle: () => onToggle(stock.ticker),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge;
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('Ticker', style: style)),
          Expanded(flex: 3, child: Text('Company', style: style)),
          Expanded(
            child: Text('Market cap', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text('P/S ratio', style: style, textAlign: TextAlign.right),
          ),
          Expanded(
            child: Text(
              'Daily change',
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}
