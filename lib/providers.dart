import 'package:data/datasources/local/app_database.dart';
import 'package:data/repositories/calendar_repository_impl.dart';
import 'package:data/repositories/daily_log_repository_impl.dart';
import 'package:domain/entities/monthly_stats.dart';
import 'package:domain/repositories/calendar_repository.dart';
import 'package:domain/repositories/daily_log_repository.dart';
import 'package:domain/usecases/get_daily_log_detail_usecase.dart';
import 'package:domain/usecases/get_monthly_stats_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/add_event_usecase.dart';
import 'package:domain/usecases/get_events_usecase.dart';
import 'package:domain/usecases/get_memo_logs_usecase.dart';

import 'ui/features/add_daily_log/add_daily_log_screen_view_model.dart';
import 'ui/features/calendar/calendar_view_model.dart';
import 'package:domain/usecases/update_event_usecase.dart';
import 'package:domain/usecases/get_statistics_usecase.dart';

import 'package:domain/usecases/get_monthly_logs_usecase.dart';
import 'ui/features/emotion_list/emotion_list_view_model.dart';

// --- Composition Root ---

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  return await $FloorAppDatabase.databaseBuilder('app_database.db').build();
});

// 1. Data -> Domain
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return database.when(
    data: (db) => CalendarRepositoryImpl(db),
    loading: () => CalendarRepositoryImpl(null),
    error: (err, stack) => CalendarRepositoryImpl(null),
  );
});

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return database.when(
    data: (db) => DailyLogRepositoryImpl(db),
    loading: () => DailyLogRepositoryImpl(null),
    error: (err, stack) => DailyLogRepositoryImpl(null),
  );
});

// 2. Repository -> UseCases
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetEventsUseCase(repository);
});

final addEventUseCaseProvider = Provider<AddEventUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return AddEventUseCase(repository);
});

final updateEventUseCaseProvider = Provider<UpdateEventUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return UpdateEventUseCase(repository);
});

final getMemoLogsUseCaseProvider = Provider<GetMemoLogsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetMemoLogsUseCase(repository);
});

final getMonthlyStatsUseCaseProvider = Provider<GetMonthlyStatsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetMonthlyStatsUseCase(repository);
});

final getDailyLogDetailUseCaseProvider = Provider<GetDailyLogDetailUseCase>((ref) {
  final repository = ref.watch(dailyLogRepositoryProvider);
  return GetDailyLogDetailUseCase(repository);
});

final getStatisticsUseCaseProvider = Provider<GetStatisticsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetStatisticsUseCase(repository);
});

// 3. UseCases -> ViewModel / Screen Data
final calendarViewModelProvider = StateNotifierProvider<CalendarViewModel, CalendarState>((ref) {
  final getEvents = ref.watch(getEventsUseCaseProvider);
  final addEvent = ref.watch(addEventUseCaseProvider);
  final now = DateTime.now();
  return CalendarViewModel(getEvents, addEvent, CalendarState(selectedDay: now, focusedDay: now, events: {}));
});

final addDailyLogViewModelProvider = StateNotifierProvider.family<AddDailyLogViewModel, AddDailyLogState, DateTime>((
  ref,
  selectedDate,
) {
  final addEventUseCase = ref.watch(addEventUseCaseProvider);
  final updateEventUseCase = ref.watch(updateEventUseCaseProvider);
  return AddDailyLogViewModel(ref, selectedDate, addEventUseCase, updateEventUseCase);
});

final monthlyStatsProvider = StateNotifierProvider.autoDispose.family<MonthlyStatsViewModel, MonthlyStats, DateTime>((
  ref,
  month,
) {
  final getMonthlyStatsUseCase = ref.watch(getMonthlyStatsUseCaseProvider);
  return MonthlyStatsViewModel(month, getMonthlyStatsUseCase);
});

// New, simplified provider for the detail screen
final dailyLogDetailProvider = FutureProvider.autoDispose.family<DailyLogRecord?, DateTime>((ref, date) async {
  final useCase = ref.watch(getDailyLogDetailUseCaseProvider);
  return useCase(date);
});

final getMonthlyLogsUseCaseProvider = Provider<GetMonthlyLogsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetMonthlyLogsUseCase(repository);
});

final emotionListViewModelProvider = StateNotifierProvider.autoDispose
    .family<EmotionListViewModel, AsyncValue<List<DailyLogRecord>>, DateTime>((ref, month) {
      final useCase = ref.watch(getMonthlyLogsUseCaseProvider);
      return EmotionListViewModel(useCase, month);
    });

class MonthlyStatsViewModel extends StateNotifier<MonthlyStats> {
  final DateTime _month;
  final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;

  MonthlyStatsViewModel(this._month, this._getMonthlyStatsUseCase) : super(const MonthlyStats()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    final stats = await _getMonthlyStatsUseCase(_month);
    if (mounted) {
      state = stats;
    }
  }
}
