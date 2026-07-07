class StockTransaction {
  final String id;
  final String symbol;
  final String stockName;
  final String type; // 'BUY' or 'SELL'
  final double shares;
  final double price; // Executed price per share
  final DateTime timestamp;
  final double totalAmount;
  final double realizedProfitLoss; // Only relevant for SELL

  StockTransaction({
    required this.id,
    required this.symbol,
    required this.stockName,
    required this.type,
    required this.shares,
    required this.price,
    required this.timestamp,
    required this.totalAmount,
    this.realizedProfitLoss = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'stockName': stockName,
      'type': type,
      'shares': shares,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'totalAmount': totalAmount,
      'realizedProfitLoss': realizedProfitLoss,
    };
  }

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'],
      symbol: json['symbol'],
      stockName: json['stockName'],
      type: json['type'],
      shares: json['shares'].toDouble(),
      price: json['price'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      totalAmount: json['totalAmount'].toDouble(),
      realizedProfitLoss: json['realizedProfitLoss']?.toDouble() ?? 0.0,
    );
  }
}
