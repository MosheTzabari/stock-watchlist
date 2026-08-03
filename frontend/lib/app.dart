import 'package:flutter/material.dart';

import 'screens/market_screen.dart';
import 'screens/watchlist_screen.dart';

class StockWatchlistApp extends StatelessWidget {
  const StockWatchlistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Watchlist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315C9B)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Stock Watchlist'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.storefront_outlined), text: 'Market'),
                Tab(icon: Icon(Icons.star_outline), text: 'Watchlist'),
              ],
            ),
          ),
          body: const TabBarView(children: [MarketScreen(), WatchlistScreen()]),
        ),
      ),
    );
  }
}
