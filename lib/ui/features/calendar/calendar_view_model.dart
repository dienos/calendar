import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/memo_record.dart';
import 'package:domain/usecases/add_event_usecase.dart';
import 'package:domain/usecases/get_events_usecase.dart';

class CalendarState {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<DailyRecord>> events;

  CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    required this.events,
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<DailyRecord>>? events,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      events: events ?? this.events,
    );
  }
}

class CalendarViewModel extends StateNotifier<CalendarState> {
  final GetEventsUseCase _getEvents;
  final AddEventUseCase _addEvent;

  CalendarViewModel(this._getEvents, this._addEvent, CalendarState initialState)
      : super(initialState) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    final eventsMap = await _getEvents();
    if (mounted) {
      state = state.copyWith(events: eventsMap);
    }
  }

  List<DailyRecord> getEventsForDay(DateTime day) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return state.events[dateOnly] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(state.selectedDay, selectedDay)) {
      state = state.copyWith(selectedDay: selectedDay, focusedDay: focusedDay);
    }
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  Future<void> addMemo(DateTime date, String text) async {
    await _addEvent(date, MemoRecord(text));
    await loadEvents();
  }
}
