import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_watchlist/models/stock.dart';
import 'package:stock_watchlist/providers/stock_watchlist_provider.dart';
import 'package:stock_watchlist/services/stock_api_service.dart';

const stock = Stock(
  ticker: 'TEST',
  company: 'Test Company',
  marketCap: r'$1B',
  psRatio: 2.5,
  dailyChange: '+1.0%',
);

void main() {
  test('loads market and watchlist concurrently into one state', () async {
    final fake = FakeStockApiService(watchlist: const [stock]);
    final container = ProviderContainer(
      overrides: [stockApiServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    container.read(stockWatchlistProvider);
    await _waitForLoad(container);

    final state = container.read(stockWatchlistProvider);
    expect(state.stocks, const [stock]);
    expect(state.watchedTickers, {'TEST'});
    expect(fake.fetchStocksCalls, 1);
    expect(fake.fetchWatchlistCalls, 1);
  });

  test('adds and removes without reloading stock lists', () async {
    final fake = FakeStockApiService();
    final container = ProviderContainer(
      overrides: [stockApiServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);

    container.read(stockWatchlistProvider);
    await _waitForLoad(container);
    final notifier = container.read(stockWatchlistProvider.notifier);

    await notifier.toggleWatchlist('TEST');
    expect(container.read(stockWatchlistProvider).watchedTickers, {'TEST'});

    await notifier.toggleWatchlist('TEST');
    expect(container.read(stockWatchlistProvider).watchedTickers, isEmpty);
    expect(fake.fetchStocksCalls, 1);
    expect(fake.fetchWatchlistCalls, 1);
  });
}

Future<void> _waitForLoad(ProviderContainer container) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    await Future<void>.delayed(Duration.zero);
    if (!container.read(stockWatchlistProvider).isLoading) {
      return;
    }
  }
  fail('Provider did not finish loading');
}

class FakeStockApiService extends StockApiService {
  FakeStockApiService({this.watchlist = const []});

  final List<Stock> watchlist;
  int fetchStocksCalls = 0;
  int fetchWatchlistCalls = 0;

  @override
  Future<List<Stock>> fetchStocks() async {
    fetchStocksCalls++;
    return const [stock];
  }

  @override
  Future<List<Stock>> fetchWatchlist() async {
    fetchWatchlistCalls++;
    return watchlist;
  }

  @override
  Future<Stock> addToWatchlist(String ticker) async => stock;

  @override
  Future<void> removeFromWatchlist(String ticker) async {}
}
