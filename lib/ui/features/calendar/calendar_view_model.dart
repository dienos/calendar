import 'package:domain/event.dart';
import 'package:domain/repository/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

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
  final EventRepository _repository;

  CalendarViewModel(this._repository) : super(CalendarState(
    selectedDay: DateTime.now(),
    focusedDay: DateTime.now(),
    events: _repository.loadEvents(),
  ));

  List<Event> getEventsForDay(DateTime day) {
    return state.events[day] ?? [];
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
    final currentEvents = state.events[state.selectedDay] ?? [];
    final updatedEventsForDay = List<Event>.from(currentEvents)..add(newEvent);

    final newEventsMap = Map<DateTime, List<Event>>.from(state.events);
    newEventsMap[state.selectedDay] = updatedEventsForDay;

    await _repository.saveEvents(newEventsMap);

    state = state.copyWith(events: newEventsMap);
  }
}

final calendarViewModelProvider = StateNotifierProvider<CalendarViewModel, CalendarState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return CalendarViewModel(repository);
});
