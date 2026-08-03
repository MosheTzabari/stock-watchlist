class Stock {
  const Stock({
    required this.ticker,
    required this.company,
    required this.marketCap,
    required this.psRatio,
    required this.dailyChange,
  });

  final String ticker;
  final String company;
  final String marketCap;
  final double psRatio;
  final String dailyChange;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      ticker: json['ticker'] as String,
      company: json['company'] as String,
      marketCap: json['marketCap'] as String,
      psRatio: (json['psRatio'] as num).toDouble(),
      dailyChange: json['dailyChange'] as String,
    );
  }
}
