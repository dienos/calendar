import '../entities/daily_record.dart';

// 이제 Repository는 DailyRecord 타입을 다룹니다.
abstract class CalendarRepository {
  Future<Map<DateTime, List<DailyRecord>>> getEvents();

  Future<void> addEvent(DateTime date, DailyRecord newRecord);
}
