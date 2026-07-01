import 'package:equatable/equatable.dart';

class StockIndex extends Equatable {
  const StockIndex({
    required this.symbol,
    required this.feedSymbol,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final String symbol;
  final String feedSymbol;
  final double lastPrice;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double close;

  bool get isPositive => change >= 0;

  StockIndex copyWith({
    double? lastPrice,
    double? change,
    double? changePercent,
    double? open,
    double? high,
    double? low,
    double? close,
  }) {
    return StockIndex(
      symbol: symbol,
      feedSymbol: feedSymbol,
      lastPrice: lastPrice ?? this.lastPrice,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
    );
  }

  factory StockIndex.fromJson(Map<String, dynamic> json) {
    return StockIndex(
      symbol: json['symbol'] as String,
      feedSymbol: json['ss'] as String,
      lastPrice: _toDouble(json['ltp']),
      change: _toDouble(json['chg']),
      changePercent: _toDouble(json['chgp']),
      open: _toDouble(json['open']),
      high: _toDouble(json['high']),
      low: _toDouble(json['low']),
      close: _toDouble(json['close']),
    );
  }

  static double _toDouble(Object? value) {
    final normalized = value.toString().replaceAll(',', '');
    return double.tryParse(normalized) ?? 0;
  }

  @override
  List<Object> get props => [
    symbol,
    feedSymbol,
    lastPrice,
    change,
    changePercent,
    open,
    high,
    low,
    close,
  ];
}
