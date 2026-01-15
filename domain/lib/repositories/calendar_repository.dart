import '../entities/event.dart';

abstract class CalendarRepository {
  Future<Map<DateTime, List<Event>>> getEvents();

  Future<void> addEvent(DateTime date, Event newEvent);
}
