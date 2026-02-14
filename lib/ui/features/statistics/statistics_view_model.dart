import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/get_statistics_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dienos_calendar/providers.dart';

class StatisticsState {
  final DateTime startDate;
  final DateTime endDate;
  final List<DailyLogRecord> logs;
  final bool isLoading;

  StatisticsState({required this.startDate, required this.endDate, this.logs = const [], this.isLoading = false});

  StatisticsState copyWith({DateTime? startDate, DateTime? endDate, List<DailyLogRecord>? logs, bool? isLoading}) {
    return StatisticsState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class StatisticsViewModel extends StateNotifier<StatisticsState> {
  final GetStatisticsUseCase _getStatisticsUseCase;

  StatisticsViewModel(this._getStatisticsUseCase)
    : super(
        StatisticsState(
          startDate: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ).subtract(const Duration(days: 6)),
          endDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59),
        ),
      ) {
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    state = state.copyWith(isLoading: true);
    try {
      final logs = await _getStatisticsUseCase(state.startDate, state.endDate);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateRange(DateTime start, DateTime end) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    state = state.copyWith(startDate: normalizedStart, endDate: normalizedEnd);
    loadStatistics();
  }

  void setPreset(int days) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
    updateRange(start, end);
  }
}

final statisticsViewModelProvider = StateNotifierProvider.autoDispose<StatisticsViewModel, StatisticsState>((ref) {
  final useCase = ref.watch(getStatisticsUseCaseProvider);
  return StatisticsViewModel(useCase);
});
