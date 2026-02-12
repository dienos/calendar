import 'package:floor/floor.dart';
import 'daily_log_entity.dart';

@Entity(
  tableName: 'images',
  foreignKeys: [
    ForeignKey(
      childColumns: ['daily_log_id'],
      parentColumns: ['id'],
      entity: DailyLogEntity,
    )
  ],
)
class IMAGEENTITY {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String path;

  @ColumnInfo(name: 'daily_log_id')
  final int dailyLogId;

  ImageEntity({this.id, required this.path, required this.dailyLogId});
}
