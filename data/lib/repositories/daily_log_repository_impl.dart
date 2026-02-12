import 'package:data/datasources/local/app_database.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final AppDatabase _database;

  DailyLogRepositoryImpl(this._database);

  @override
  Future<DailyLogRecord?> getDailyLogDetail(DateTime date) async {
    // 1. Find the log for the given date.
    final dailyLog = await _database.dailyLogDao.findDailyLogByDate(date);

    if (dailyLog != null && dailyLog.id != null) {
      // 2. Find the images associated with that log's ID.
      final images = await _database.dailyLogDao.findImagesByLogId(dailyLog.id!);
      
      // 3. Combine them into a single domain model.
      return DailyLogRecord(
        dailyLog.emotion,
        dailyLog.memo,
        images: images.map((e) => e.path).toList(),
      );
    }
    
    return null; // If no log exists for the date, return null.
  }
}
