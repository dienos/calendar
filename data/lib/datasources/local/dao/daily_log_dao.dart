import 'package:floor/floor.dart';
import '../entity/daily_log_entity.dart';
import '../entity/image_entity.dart';

@dao
abstract class DailyLogDao {
  @Query('SELECT * FROM DailyLogEntity WHERE date = :date')
  Future<List<DailyLogEntity>> findDailyLogsByDate(DateTime date);

  @Query('SELECT * FROM DailyLogEntity')
  Future<List<DailyLogEntity>> findAllDailyLogs();

  @insert
  Future<int> insertDailyLog(DailyLogEntity dailyLog);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertOrReplaceDailyLog(DailyLogEntity dailyLog);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateDailyLog(DailyLogEntity dailyLog);

  // --- Methods for Monthly Highlights ---

  @Query(
    "SELECT * FROM DailyLogEntity WHERE strftime('%Y-%m', date / 1000, 'unixepoch') = :yearMonth ORDER BY date DESC",
  )
  Future<List<DailyLogEntity>> findDailyLogsByMonth(String yearMonth);

  @Query(
    "SELECT COUNT(*) FROM DailyLogEntity WHERE strftime('%Y-%m', date / 1000, 'unixepoch') = :yearMonth AND emotion != ''",
  )
  Future<int?> countMoodEntriesForMonth(String yearMonth);

  @Query(
    "SELECT COUNT(*) FROM DailyLogEntity WHERE strftime('%Y-%m', date / 1000, 'unixepoch') = :yearMonth AND memo != ''",
  )
  Future<int?> countMemoEntriesForMonth(String yearMonth);

  @Query(
    "SELECT * FROM DailyLogEntity WHERE strftime('%Y-%m', date / 1000, 'unixepoch') = :yearMonth AND memo != '' ORDER BY date DESC",
  )
  Future<List<DailyLogEntity>> findDailyLogsWithMemoByMonth(String yearMonth);

  // --- Methods for Detail Screen (New Approach) ---

  @Query('SELECT * FROM DailyLogEntity WHERE date = :date LIMIT 1')
  Future<DailyLogEntity?> findDailyLogByDate(DateTime date);

  @Query(
    'SELECT * FROM DailyLogEntity WHERE date >= :start AND date <= :end ORDER BY date ASC',
  )
  Future<List<DailyLogEntity>> findDailyLogsByRange(
    DateTime start,
    DateTime end,
  );

  @Query('SELECT * FROM images WHERE daily_log_id = :logId')
  Future<List<ImageEntity>> findImagesByLogId(int logId);
}
