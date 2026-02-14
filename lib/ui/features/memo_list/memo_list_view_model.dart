import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/get_memo_logs_usecase.dart';
import 'package:dienos_calendar/providers.dart';

class MemoListState {
  final List<DailyLogRecord> logs;
  final bool isLoading;
  final DateTime selectedMonth;

  const MemoListState({this.logs = const [], this.isLoading = false, required this.selectedMonth});

  MemoListState copyWith({List<DailyLogRecord>? logs, bool? isLoading, DateTime? selectedMonth}) {
    return MemoListState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

class MemoListViewModel extends StateNotifier<MemoListState> {
  final GetMemoLogsUseCase _getMemoLogsUseCase;

  MemoListViewModel(this._getMemoLogsUseCase, DateTime initialMonth)
    : super(MemoListState(selectedMonth: initialMonth)) {
    loadMemos(initialMonth);
  }

  Future<void> loadMemos(DateTime month) async {
    state = state.copyWith(isLoading: true, selectedMonth: month);
    try {
      final logs = await _getMemoLogsUseCase(month);
      state = state.copyWith(logs: logs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void updateMonth(DateTime month) {
    loadMemos(month);
  }
}

final memoListViewModelProvider = StateNotifierProvider.autoDispose.family<MemoListViewModel, MemoListState, DateTime>((
  ref,
  initialMonth,
) {
  final useCase = ref.watch(getMemoLogsUseCaseProvider);
  return MemoListViewModel(useCase, initialMonth);
});
