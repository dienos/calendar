import 'package:data/datasources/local/app_database.dart';
import 'package:data/repositories/calendar_repository_impl.dart';
import 'package:domain/repositories/calendar_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/add_event_usecase.dart';
import 'package:domain/usecases/get_events_usecase.dart';
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

// 2. Repository -> UseCases
final getEventsUseCaseProvider = Provider<GetEventsUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return GetEventsUseCase(repository);
});

final addEventUseCaseProvider = Provider<AddEventUseCase>((ref) {
  final repository = ref.watch(calendarRepositoryProvider);
  return AddEventUseCase(repository);
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
