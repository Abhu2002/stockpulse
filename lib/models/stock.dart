import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  const Stock({
    required this.symbol,
    required this.feedSymbol,
    required this.exchange,
    required this.lastPrice,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.high,
    required this.low,
    required this.previousClose,
    required this.holdings,
  });

  final String symbol;
  final String feedSymbol;
  final String exchange;
  final double lastPrice;
  final double change;
  final double changePercent;
  final String volume;
  final String high;
  final String low;
  final String previousClose;
  final String holdings;

  bool get isPositive => change >= 0;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] as String,
      feedSymbol: json['ss'] as String,
      exchange: json['exchange'] as String? ?? 'NSE',
      lastPrice: _toDouble(json['ltp']),
      change: _toDouble(json['ptsC']),
      changePercent: _toDouble(json['chgp']),
      volume: json['trdVolM'] as String? ?? '-',
      high: json['high'] as String? ?? '-',
      low: json['low'] as String? ?? '-',
      previousClose: json['previousClose'] as String? ?? '-',
      holdings: json['holdings'] as String? ?? '0',
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
    exchange,
    lastPrice,
    change,
    changePercent,
    volume,
    high,
    low,
    previousClose,
    holdings,
  ];
}
