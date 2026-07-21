class TopUpLog {
  final String id;
  final double amount; // Virtual money added
  final double charge; // Real money charged
  final String paymentMethod;
  final DateTime timestamp;

  TopUpLog({
    required this.id,
    required this.amount,
    required this.charge,
    required this.paymentMethod,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'charge': charge,
      'paymentMethod': paymentMethod,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TopUpLog.fromJson(Map<String, dynamic> json) {
    return TopUpLog(
      id: json['id'],
      amount: json['amount'].toDouble(),
      charge: json['charge'].toDouble(),
      paymentMethod: json['paymentMethod'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
