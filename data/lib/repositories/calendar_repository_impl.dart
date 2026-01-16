import 'package:data/datasources/local/app_database.dart';
import 'package:data/datasources/local/entity/memo_entity.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/memo_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AppDatabase? _database;

  CalendarRepositoryImpl(this._database);

  @override
  Future<Map<DateTime, List<DailyRecord>>> getEvents() async {
    if (_database == null) return {};

    await Future.delayed(Duration.zero);
    final allMemos = await _database.memoDao.findAllMemos();
    final Map<DateTime, List<DailyRecord>> events = {};

    for (var memoEntity in allMemos) {
      final date = DateTime.utc(memoEntity.date.year, memoEntity.date.month, memoEntity.date.day);
      final memoRecord = MemoRecord(memoEntity.memoText);

      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(memoRecord);
    }
    return Map.of(events);
  }

  @override
  Future<void> addEvent(DateTime date, DailyRecord newRecord) async {
    if (_database == null) {
      return;
    }

    await Future.delayed(Duration.zero);

    if (newRecord is MemoRecord) {
      final memoEntity = MemoEntity(
        memoText: newRecord.text, // text -> memoText
        date: date,
      );
      await _database.memoDao.insertMemo(memoEntity);
    }
  }
}
