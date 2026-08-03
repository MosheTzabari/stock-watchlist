import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/stock.dart';

class StockApiService {
  StockApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  final http.Client _client;

  Future<List<Stock>> fetchStocks() => _fetchStockList('/stocks');

  Future<List<Stock>> fetchWatchlist() => _fetchStockList('/watchlist');

  Future<Stock> addToWatchlist(String ticker) async {
    final response = await _client.post(_uri('/watchlist/$ticker'));
    _ensureSuccess(response, expectedStatus: 201);
    return Stock.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> removeFromWatchlist(String ticker) async {
    final response = await _client.delete(_uri('/watchlist/$ticker'));
    _ensureSuccess(response, expectedStatus: 204);
  }

  Future<List<Stock>> _fetchStockList(String path) async {
    final response = await _client.get(_uri(path));
    _ensureSuccess(response, expectedStatus: 200);
    final items = jsonDecode(response.body) as List<dynamic>;
    return items
        .map((item) => Stock.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  void _ensureSuccess(http.Response response, {required int expectedStatus}) {
    if (response.statusCode == expectedStatus) {
      return;
    }

    String message = 'Request failed. Please try again.';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } on FormatException {
      // Keep the safe fallback when the server response is not JSON.
    }
    throw StockApiException(message);
  }
}

class StockApiException implements Exception {
  const StockApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
