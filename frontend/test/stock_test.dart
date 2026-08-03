import 'package:flutter_test/flutter_test.dart';
import 'package:stock_watchlist/models/stock.dart';

void main() {
  test('parses stock JSON', () {
    final stock = Stock.fromJson({
      'ticker': 'TEST',
      'company': 'Test Company',
      'marketCap': r'$1B',
      'psRatio': 2.5,
      'dailyChange': '+1.0%',
    });

    expect(stock.ticker, 'TEST');
    expect(stock.company, 'Test Company');
    expect(stock.marketCap, r'$1B');
    expect(stock.psRatio, 2.5);
    expect(stock.dailyChange, '+1.0%');
  });
}
