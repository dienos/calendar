import 'package:floor/floor.dart';
import '../entity/image_entity.dart';

@dao
abstract class ImageDao {
  @insert
  Future<void> insertImage(ImageEntity image);

  @Query('SELECT * FROM ImageEntity WHERE daily_log_id = :dailyLogId')
  Future<List<ImageEntity>> findImagesByDailyLogId(int dailyLogId);

  @Query(
    "SELECT COUNT(*) FROM images INNER JOIN DailyLogEntity ON images.daily_log_id = DailyLogEntity.id WHERE strftime('%Y-%m', DailyLogEntity.date / 1000, 'unixepoch') = :yearMonth",
  )
  Future<int?> countPhotoEntriesForMonth(String yearMonth);

  @Query('DELETE FROM images WHERE daily_log_id = :dailyLogId')
  Future<void> deleteImagesByDailyLogId(int dailyLogId);
}
