import 'package:data/datasources/local/app_database.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/daily_log_repository.dart';

class DailyLogRepositoryImpl implements DailyLogRepository {
  final AppDatabase? _database;

  DailyLogRepositoryImpl(this._database);

  @override
  Future<DailyLogRecord?> getDailyLogDetail(DateTime date) async {
    if (_database == null) return null;

    final dailyLog = await _database.dailyLogDao.findDailyLogByDate(date);

    if (dailyLog != null && dailyLog.id != null) {
      final images = await _database.dailyLogDao.findImagesByLogId(
        dailyLog.id!,
      );

      return DailyLogRecord(
        dailyLog.emotion,
        dailyLog.memo,
        images: images.map((e) => e.path).toList(),
      );
    }

    return null;
  }
}
