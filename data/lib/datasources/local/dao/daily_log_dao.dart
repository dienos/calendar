import 'package:floor/floor.dart';
import '../entity/daily_log_entity.dart';

@dao
abstract class DailyLogDao {
  @Query('SELECT * FROM DailyLogEntity WHERE date = :date')
  Future<List<DailyLogEntity>> findDailyLogsByDate(DateTime date);

  @Query('SELECT * FROM DailyLogEntity')
  Future<List<DailyLogEntity>> findAllDailyLogs();

  @insert
  Future<void> insertDailyLog(DailyLogEntity dailyLog);
}
