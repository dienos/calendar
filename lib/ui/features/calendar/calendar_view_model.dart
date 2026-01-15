import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domain/entities/event.dart';
import 'package:domain/repositories/calendar_repository.dart';

class CalendarState {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<Event>> events;

  CalendarState({
    required this.selectedDay,
    required this.focusedDay,
    required this.events,
  });

  CalendarState copyWith({
    DateTime? selectedDay,
    DateTime? focusedDay,
    Map<DateTime, List<Event>>? events,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      focusedDay: focusedDay ?? this.focusedDay,
      events: events ?? this.events,
    );
  }
}

class CalendarViewModel extends StateNotifier<CalendarState> {
  final CalendarRepository _repository;

  CalendarViewModel(this._repository, CalendarState initialState) : super(initialState) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventsMap = await _repository.getEvents();
    if (mounted) {
      state = state.copyWith(events: eventsMap);
    }
  }

  List<Event> getEventsForDay(DateTime day) {
    final dateOnly = DateTime.utc(day.year, day.month, day.day);
    return state.events[dateOnly] ?? [];
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(state.selectedDay, selectedDay)) {
      state = state.copyWith(
        selectedDay: selectedDay,
        focusedDay: focusedDay,
      );
    }
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
  }

  Future<void> addEvent(Event newEvent) async {
    final date = state.selectedDay;
    await _repository.addEvent(date, newEvent);
    await _loadEvents();
  }
}
