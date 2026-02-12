import 'package:floor/floor.dart';
import '../entity/image_entity.dart';

@dao
abstract class ImageDao {
  @insert
  Future<void> insertImage(ImageEntity image);

  @Query('SELECT * FROM ImageEntity WHERE daily_log_id = :dailyLogId')
  Future<List<ImageEntity>> findImagesByDailyLogId(int dailyLogId);
}
