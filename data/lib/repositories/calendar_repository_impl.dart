import 'package:data/datasources/local/app_database.dart';
import 'package:data/datasources/local/entity/daily_log_entity.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AppDatabase? _database;

  CalendarRepositoryImpl(this._database);

  @override
  Future<Map<DateTime, List<DailyRecord>>> getEvents() async {
    if (_database == null) return {};

    final allDailyLogs = await _database.dailyLogDao.findAllDailyLogs();
    final Map<DateTime, List<DailyRecord>> events = {};

    for (var dailyLogEntity in allDailyLogs) {
      final date = DateTime.utc(dailyLogEntity.date.year, dailyLogEntity.date.month, dailyLogEntity.date.day);
      final dailyLogRecord = DailyLogRecord(dailyLogEntity.emotion, dailyLogEntity.memo);

      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(dailyLogRecord);
    }
    return Map.of(events);
  }

  @override
  Future<void> addEvent(DateTime date, DailyRecord newRecord) async {
    if (_database == null) {
      return;
    }

    if (newRecord is DailyLogRecord) {
      final dailyLogEntity = DailyLogEntity(
        emotion: newRecord.emotion,
        memo: newRecord.memo,
        date: date,
      );
      await _database.dailyLogDao.insertDailyLog(dailyLogEntity);
    }
  }
}
