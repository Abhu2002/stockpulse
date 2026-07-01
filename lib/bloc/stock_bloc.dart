import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/stock.dart';
import '../models/stock_index.dart';
import '../services/stock_service.dart';

sealed class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object?> get props => [];
}

class StocksRequested extends StockEvent {
  const StocksRequested();
}

class LiveIndexReceived extends StockEvent {
  const LiveIndexReceived(this.index);

  final StockIndex index;

  @override
  List<Object?> get props => [index];
}

enum StockStatus { initial, loading, success, failure }

class StockState extends Equatable {
  const StockState({
    required this.status,
    this.indices = const [],
    this.stocks = const [],
    this.errorMessage,
    this.liveConnected = false,
  });

  const StockState.initial() : this(status: StockStatus.initial);

  final StockStatus status;
  final List<StockIndex> indices;
  final List<Stock> stocks;
  final String? errorMessage;
  final bool liveConnected;

  StockState copyWith({
    StockStatus? status,
    List<StockIndex>? indices,
    List<Stock>? stocks,
    String? errorMessage,
    bool? liveConnected,
  }) {
    return StockState(
      status: status ?? this.status,
      indices: indices ?? this.indices,
      stocks: stocks ?? this.stocks,
      errorMessage: errorMessage,
      liveConnected: liveConnected ?? this.liveConnected,
    );
  }

  @override
  List<Object?> get props => [
    status,
    indices,
    stocks,
    errorMessage,
    liveConnected,
  ];
}

class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc(this._stockService) : super(const StockState.initial()) {
    on<StocksRequested>(_onRequested);
    on<LiveIndexReceived>(_onLiveIndexReceived);
  }

  final StockService _stockService;
  StreamSubscription<StockIndex>? _liveSubscription;

  Future<void> _onRequested(
    StocksRequested event,
    Emitter<StockState> emit,
  ) async {
    emit(state.copyWith(status: StockStatus.loading, errorMessage: null));
    try {
      final results = await Future.wait([
        _stockService.fetchIndices(),
        _stockService.fetchStocks(),
      ]);
      final indices = results[0] as List<StockIndex>;
      final stocks = results[1] as List<Stock>;

      emit(
        StockState(
          status: StockStatus.success,
          indices: indices,
          stocks: stocks,
          liveConnected: true,
        ),
      );

      await _liveSubscription?.cancel();
      _liveSubscription = _stockService
          .liveIndexUpdates(indices)
          .listen((index) => add(LiveIndexReceived(index)));
    } catch (_) {
      emit(
        const StockState(
          status: StockStatus.failure,
          errorMessage: 'Unable to load market data.',
        ),
      );
    }
  }

  void _onLiveIndexReceived(LiveIndexReceived event, Emitter<StockState> emit) {
    final updatedIndices = state.indices.map((index) {
      return index.feedSymbol == event.index.feedSymbol ? event.index : index;
    }).toList();

    emit(state.copyWith(indices: updatedIndices, liveConnected: true));
  }

  @override
  Future<void> close() async {
    await _liveSubscription?.cancel();
    return super.close();
  }
}
