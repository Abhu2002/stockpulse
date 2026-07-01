import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/stock.dart';
import '../models/stock_index.dart';

class StockService {
  Future<List<StockIndex>> fetchIndices() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _indexData.map(StockIndex.fromJson).toList();
  }

  Future<List<Stock>> fetchStocks() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _stockData.map(Stock.fromJson).toList();
  }

  Stream<StockIndex> liveIndexUpdates(List<StockIndex> currentIndices) async* {
    WebSocket? socket;
    try {
      socket = await WebSocket.connect(
        'wss://streamer.ysil.in/',
      ).timeout(const Duration(seconds: 6));
      final symbols = currentIndices
          .where((index) => index.feedSymbol == 'NSEIDX_26000')
          .map((index) => index.feedSymbol)
          .toList();
      socket.add(
        jsonEncode({
          'action': 'subscribe',
          'type': 'freefeed',
          'symbols': symbols.isEmpty ? ['NSEIDX_26000'] : symbols,
        }),
      );

      await for (final message in socket) {
        final update = _parseIndexUpdate(message.toString(), currentIndices);
        if (update != null) yield update;
      }
    } catch (_) {
      yield* _simulatedUpdates(currentIndices);
    } finally {
      await socket?.close();
    }
  }

  Stream<StockIndex> _simulatedUpdates(List<StockIndex> indices) async* {
    var tick = 0;
    while (true) {
      await Future<void>.delayed(const Duration(seconds: 3));
      final base = indices[tick % indices.length];
      final swing = tick.isEven ? 6.25 : -4.75;
      final nextPrice = base.lastPrice + swing;
      final change = nextPrice - base.close;
      yield base.copyWith(
        lastPrice: nextPrice,
        change: change,
        changePercent: base.close == 0 ? 0 : (change / base.close) * 100,
      );
      tick++;
    }
  }

  StockIndex? _parseIndexUpdate(String message, List<StockIndex> indices) {
    final parts = message.split('|');
    if (parts.length < 8) return null;
    final feedPrefix = parts.first;
    final name = parts[1].replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').trim();
    final matching = indices.where((index) {
      final comparable = index.symbol.replaceAll(' ', '').toLowerCase();
      return index.feedSymbol.startsWith(feedPrefix) ||
          comparable.contains(name.replaceAll(' ', '').toLowerCase());
    }).firstOrNull;
    if (matching == null) return null;

    final lastPrice = double.tryParse(parts[2]) ?? matching.lastPrice;
    final high = double.tryParse(parts[3]) ?? matching.high;
    final low = double.tryParse(parts[4]) ?? matching.low;
    final open = double.tryParse(parts[5]) ?? matching.open;
    final close = double.tryParse(parts[6]) ?? matching.close;
    final percent = double.tryParse(parts[7]) ?? matching.changePercent;

    return matching.copyWith(
      lastPrice: lastPrice,
      high: high,
      low: low,
      open: open,
      close: close,
      change: lastPrice - close,
      changePercent: percent,
    );
  }
}

const _indexData = [
  {
    'symbol': 'NIFTY 50',
    'ss': 'NSEIDX_26000',
    'ltp': '18591.950000',
    'chg': '-50.80',
    'chgp': '-0.27',
    'open': '18570.850000',
    'high': '18625.000000',
    'low': '18536.950000',
    'close': '18560.500000',
  },
  {
    'symbol': 'NIFTY NEXT 50',
    'ss': 'NSEIDX_26013',
    'ltp': '44039.200000',
    'chg': '233.00',
    'chgp': '0.53',
    'open': '44001.450000',
    'high': '44092.400000',
    'low': '43924.350000',
    'close': '43892.200000',
  },
  {
    'symbol': 'NIFTY 100',
    'ss': 'NSEIDX_26012',
    'ltp': '18786.900000',
    'chg': '-34.65',
    'chgp': '-0.18',
    'open': '18770.800000',
    'high': '18820.350000',
    'low': '18739.000000',
    'close': '18754.000000',
  },
  {
    'symbol': 'NIFTY BANK',
    'ss': 'NSEIDX_26009',
    'ltp': '43417.550000',
    'chg': '279.00',
    'chgp': '0.65',
    'open': '43142.250000',
    'high': '43458.850000',
    'low': '43095.300000',
    'close': '43098.700000',
  },
  {
    'symbol': 'NIFTY IT',
    'ss': 'NSEIDX_26008',
    'ltp': '30083.500000',
    'chg': '-359.50',
    'chgp': '-1.18',
    'open': '30175.850000',
    'high': '30226.550000',
    'low': '29983.400000',
    'close': '30187.050000',
  },
  {
    'symbol': 'INDIA VIX',
    'ss': 'NSEIDX_26017',
    'ltp': '13.670000',
    'chg': '-0.37',
    'chgp': '-2.64',
    'open': '14.080000',
    'high': '14.890000',
    'low': '13.360000',
    'close': '14.080000',
  },
];

const _stockData = [
  {
    'symbol': 'HDFC',
    'ss': 'NSECM_1330',
    'exchange': 'NSE',
    'holdings': '100',
    'high': '2,415.95',
    'low': '2,375.05',
    'ltp': '2395.00',
    'ptsC': '63.35',
    'chgp': '2.72',
    'trdVolM': '2.37',
    'previousClose': '2,331.65',
  },
  {
    'symbol': 'BAJAJ-AUTO',
    'ss': 'NSECM_16669',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '3,716.95',
    'low': '3,623.75',
    'ltp': '3692.00',
    'ptsC': '80.70',
    'chgp': '2.23',
    'trdVolM': '0.23',
    'previousClose': '3,611.30',
  },
  {
    'symbol': 'RELIANCE',
    'ss': 'NSECM_2885',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '2,502.70',
    'low': '2,441.70',
    'ltp': '2499.95',
    'ptsC': '48.70',
    'chgp': '1.99',
    'trdVolM': '2.47',
    'previousClose': '2,451.25',
  },
  {
    'symbol': 'POWERGRID',
    'ss': 'NSECM_14977',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '216.90',
    'low': '212.95',
    'ltp': '216.45',
    'ptsC': '4.10',
    'chgp': '1.93',
    'trdVolM': '2.57',
    'previousClose': '212.35',
  },
  {
    'symbol': 'AXISBANK',
    'ss': 'NSECM_5900',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '834.00',
    'low': '816.90',
    'ltp': '831.65',
    'ptsC': '15.30',
    'chgp': '1.87',
    'trdVolM': '2.99',
    'previousClose': '816.35',
  },
  {
    'symbol': 'TITAN',
    'ss': 'NSECM_3506',
    'exchange': 'NSE',
    'holdings': '500',
    'high': '2,677.00',
    'low': '2,648.75',
    'ltp': '2666.00',
    'ptsC': '24.90',
    'chgp': '0.94',
    'trdVolM': '0.26',
    'previousClose': '2,641.10',
  },
  {
    'symbol': 'TATASTEEL',
    'ss': 'NSECM_3499',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '101.25',
    'low': '99.70',
    'ltp': '100.95',
    'ptsC': '0.30',
    'chgp': '0.30',
    'trdVolM': '11.74',
    'previousClose': '100.65',
  },
  {
    'symbol': 'ITC',
    'ss': 'NSECM_1660',
    'exchange': 'NSE',
    'holdings': '0',
    'high': '343.80',
    'low': '339.80',
    'ltp': '341.25',
    'ptsC': '0.95',
    'chgp': '0.28',
    'trdVolM': '3.01',
    'previousClose': '340.30',
  },
];
