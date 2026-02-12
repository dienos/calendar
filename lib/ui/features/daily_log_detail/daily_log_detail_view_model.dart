import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/get_daily_log_detail_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. State Definition
class DailyLogDetailState {
  final DailyLogRecord? dailyLog;
  final bool isLoading;

  const DailyLogDetailState({
    this.dailyLog,
    this.isLoading = true,
  });

  DailyLogDetailState copyWith({
    DailyLogRecord? dailyLog,
    bool? isLoading,
  }) {
    return DailyLogDetailState(
      dailyLog: dailyLog ?? this.dailyLog,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. ViewModel Definition
class DailyLogDetailViewModel extends StateNotifier<DailyLogDetailState> {
  final GetDailyLogDetailUseCase _getDailyLogDetailUseCase;
  final DateTime _date;

  DailyLogDetailViewModel(this._getDailyLogDetailUseCase, this._date)
      : super(const DailyLogDetailState()) {
    _fetchLogDetail();
  }

  Future<void> _fetchLogDetail() async {
    state = state.copyWith(isLoading: true);
    final log = await _getDailyLogDetailUseCase(_date);
    state = state.copyWith(dailyLog: log, isLoading: false);
  }
}
