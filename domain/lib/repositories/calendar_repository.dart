import 'package:domain/entities/daily_record.dart';

abstract class CalendarRepository {
  Future<Map<DateTime, List<DailyRecord>>> getEvents();

  Future<void> addEvent(DateTime date, DailyRecord newRecord);

  // --- New Methods for Monthly Highlights ---
  Future<int> countMoodEntriesForMonth(String yearMonth);

  Future<int> countMemoEntriesForMonth(String yearMonth);

  Future<int> countPhotoEntriesForMonth(String yearMonth);
}
