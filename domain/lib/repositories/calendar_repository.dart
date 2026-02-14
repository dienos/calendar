import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/daily_log_record.dart';

abstract class CalendarRepository {
  Future<Map<DateTime, List<DailyRecord>>> getEvents();

  Future<void> addEvent(DateTime date, DailyRecord newRecord);

  Future<void> updateEvent(DateTime date, DailyRecord updatedRecord);

  // --- New Methods for Monthly Highlights ---
  Future<int> countMoodEntriesForMonth(String yearMonth);

  Future<int> countMemoEntriesForMonth(String yearMonth);

  Future<int> countPhotoEntriesForMonth(String yearMonth);

  Future<List<DailyRecord>> getMonthlyLogs(DateTime month);

  Future<List<DailyLogRecord>> getLogsByRange(DateTime start, DateTime end);

  Future<List<DailyLogRecord>> getMemoLogs(DateTime month);
}
