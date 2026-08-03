import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_watchlist/app.dart';
import 'package:stock_watchlist/models/stock.dart';
import 'package:stock_watchlist/providers/stock_watchlist_provider.dart';
import 'package:stock_watchlist/services/stock_api_service.dart';

void main() {
  testWidgets('shows loading while initial requests are pending', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockApiServiceProvider.overrideWithValue(PendingStockApiService()),
        ],
        child: const StockWatchlistApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(StockWatchlistApp), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders market and empty watchlist from shared state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockApiServiceProvider.overrideWithValue(SuccessStockApiService()),
        ],
        child: const StockWatchlistApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TEST'), findsOneWidget);
    expect(find.text('Test Company'), findsOneWidget);

    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your watchlist is empty. Add stocks from the Market tab.'),
      findsOneWidget,
    );
  });

  testWidgets('shows a retryable error when initial loading fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stockApiServiceProvider.overrideWithValue(FailingStockApiService()),
        ],
        child: const StockWatchlistApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Unable to reach the backend. Check that it is running and retry.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });

  testWidgets('disables only the mutating ticker and keeps its star visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final apiService = MutationStockApiService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [stockApiServiceProvider.overrideWithValue(apiService)],
        child: const StockWatchlistApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_tickerButton('TEST'));
    await tester.pump();

    final testButton = tester.widget<IconButton>(_tickerButton('TEST'));
    final otherButton = tester.widget<IconButton>(_tickerButton('OTHER'));
    final testRow = find.byKey(const ValueKey('TEST'));

    expect(testButton.onPressed, isNull);
    expect(otherButton.onPressed, isNotNull);
    expect(
      find.descendant(of: testRow, matching: find.byIcon(Icons.star_outline)),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Opacity>(
            find.descendant(of: testRow, matching: find.byType(Opacity)),
          )
          .opacity,
      0.45,
    );

    apiService.addCompleter.complete(MutationStockApiService.testStock);
    await tester.pumpAndSettle();
  });
}

Finder _tickerButton(String ticker) => find.byWidgetPredicate(
  (widget) => widget is IconButton && widget.tooltip?.contains(ticker) == true,
);

class PendingStockApiService extends StockApiService {
  final Completer<List<Stock>> completer = Completer<List<Stock>>();

  @override
  Future<List<Stock>> fetchStocks() => completer.future;

  @override
  Future<List<Stock>> fetchWatchlist() => completer.future;
}

class FailingStockApiService extends StockApiService {
  @override
  Future<List<Stock>> fetchStocks() => Future.error(Exception('offline'));

  @override
  Future<List<Stock>> fetchWatchlist() => Future.error(Exception('offline'));
}

class SuccessStockApiService extends StockApiService {
  static const stock = Stock(
    ticker: 'TEST',
    company: 'Test Company',
    marketCap: r'$1B',
    psRatio: 2.5,
    dailyChange: '+1.0%',
  );

  @override
  Future<List<Stock>> fetchStocks() async => const [stock];

  @override
  Future<List<Stock>> fetchWatchlist() async => const [];
}

class MutationStockApiService extends StockApiService {
  static const testStock = Stock(
    ticker: 'TEST',
    company: 'Test Company',
    marketCap: r'$1B',
    psRatio: 2.5,
    dailyChange: '+1.0%',
  );
  static const otherStock = Stock(
    ticker: 'OTHER',
    company: 'Other Company',
    marketCap: r'$2B',
    psRatio: 3.5,
    dailyChange: '-1.0%',
  );

  final Completer<Stock> addCompleter = Completer<Stock>();

  @override
  Future<List<Stock>> fetchStocks() async => const [testStock, otherStock];

  @override
  Future<List<Stock>> fetchWatchlist() async => const [];

  @override
  Future<Stock> addToWatchlist(String ticker) => addCompleter.future;
}
