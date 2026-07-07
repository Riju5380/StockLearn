class Stock {
  final String symbol;
  final String name;
  final String sector;
  double price;
  double change;
  double changePercent;
  final String marketCap;
  final double peRatio;
  final double dividendYield;
  final String avgVolume;
  final double high52w;
  final double low52w;
  final String description;
  final List<double> history1D;
  final List<double> history1W;
  final List<double> history1M;
  final List<double> history1Y;
  final List<double> historyAll;
  bool isFavorite;

  Stock({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.marketCap,
    required this.peRatio,
    required this.dividendYield,
    required this.avgVolume,
    required this.high52w,
    required this.low52w,
    required this.description,
    required this.history1D,
    required this.history1W,
    required this.history1M,
    required this.history1Y,
    required this.historyAll,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'marketCap': marketCap,
      'peRatio': peRatio,
      'dividendYield': dividendYield,
      'avgVolume': avgVolume,
      'high52w': high52w,
      'low52w': low52w,
      'description': description,
      'history1D': history1D,
      'history1W': history1W,
      'history1M': history1M,
      'history1Y': history1Y,
      'historyAll': historyAll,
      'isFavorite': isFavorite,
    };
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'],
      name: json['name'],
      sector: json['sector'],
      price: json['price'].toDouble(),
      change: json['change'].toDouble(),
      changePercent: json['changePercent'].toDouble(),
      marketCap: json['marketCap'],
      peRatio: json['peRatio'].toDouble(),
      dividendYield: json['dividendYield'].toDouble(),
      avgVolume: json['avgVolume'],
      high52w: json['high52w'].toDouble(),
      low52w: json['low52w'].toDouble(),
      description: json['description'],
      history1D: List<double>.from(json['history1D'].map((x) => x.toDouble())),
      history1W: List<double>.from(json['history1W'].map((x) => x.toDouble())),
      history1M: List<double>.from(json['history1M'].map((x) => x.toDouble())),
      history1Y: List<double>.from(json['history1Y'].map((x) => x.toDouble())),
      historyAll: List<double>.from(json['historyAll'].map((x) => x.toDouble())),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Stock copyWith({
    double? price,
    double? change,
    double? changePercent,
    bool? isFavorite,
  }) {
    return Stock(
      symbol: symbol,
      name: name,
      sector: sector,
      price: price ?? this.price,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      marketCap: marketCap,
      peRatio: peRatio,
      dividendYield: dividendYield,
      avgVolume: avgVolume,
      high52w: high52w,
      low52w: low52w,
      description: description,
      history1D: history1D,
      history1W: history1W,
      history1M: history1M,
      history1Y: history1Y,
      historyAll: historyAll,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
