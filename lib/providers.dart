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
import 'package:dienos_calendar/ui/features/daily_log_detail/daily_log_detail_view_model.dart';
import 'ui/features/add_daily_log/add_daily_log_screen_view_model.dart';
import 'ui/features/calendar/calendar_view_model.dart';

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
  // We assume the database is available here, otherwise it will throw.
  // A more robust solution might handle the loading/error state.
  return DailyLogRepositoryImpl(database.value!);
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

final getMonthlyStatsUseCaseProvider = Provider<GetMonthlyStatsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetMonthlyStatsUseCase(repository);
});

final getDailyLogDetailUseCaseProvider = Provider<GetDailyLogDetailUseCase>((ref) {
  final repository = ref.watch(dailyLogRepositoryProvider);
  return GetDailyLogDetailUseCase(repository);
});

// 3. UseCases -> ViewModel
final calendarViewModelProvider =
    StateNotifierProvider<CalendarViewModel, CalendarState>((ref) {
  final getEvents = ref.watch(getEventsUseCaseProvider);
  final addEvent = ref.watch(addEventUseCaseProvider);
  final now = DateTime.now();
  return CalendarViewModel(
      getEvents,
      addEvent,
      CalendarState(
        selectedDay: now,
        focusedDay: now,
        events: {},
      ));
});

final addDailyLogViewModelProvider = StateNotifierProvider.family<
    AddDailyLogViewModel, AddDailyLogState, DateTime>((ref, selectedDate) {
  final addEventUseCase = ref.watch(addEventUseCaseProvider);
  return AddDailyLogViewModel(ref, selectedDate, addEventUseCase);
});

final monthlyStatsProvider = StateNotifierProvider.autoDispose
    .family<MonthlyStatsViewModel, MonthlyStats, DateTime>((ref, month) {
  final getMonthlyStatsUseCase = ref.watch(getMonthlyStatsUseCaseProvider);
  return MonthlyStatsViewModel(month, getMonthlyStatsUseCase);
});

final dailyLogDetailProvider = StateNotifierProvider.autoDispose
    .family<DailyLogDetailViewModel, DailyLogDetailState, DateTime>((ref, date) {
  final getDailyLogDetailUseCase = ref.watch(getDailyLogDetailUseCaseProvider);
  return DailyLogDetailViewModel(getDailyLogDetailUseCase, date);
});

class MonthlyStatsViewModel extends StateNotifier<MonthlyStats> {
  final DateTime _month;
  final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;

  MonthlyStatsViewModel(this._month, this._getMonthlyStatsUseCase)
      : super(const MonthlyStats()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = await _getMonthlyStatsUseCase(_month);
  }
}
