import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/get_monthly_logs_usecase.dart';

class EmotionListViewModel extends StateNotifier<AsyncValue<List<DailyLogRecord>>> {
  final GetMonthlyLogsUseCase _useCase;
  final DateTime _month;

  EmotionListViewModel(this._useCase, this._month) : super(const AsyncLoading()) {
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final logs = await _useCase.execute(_month);
      state = AsyncData(logs.cast<DailyLogRecord>());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
