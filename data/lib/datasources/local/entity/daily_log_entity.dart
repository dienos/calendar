import 'package:floor/floor.dart';

@entity
class DailyLogEntity {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'emotion')
  final String emotion;

  @ColumnInfo(name: 'memo')
  final String memo;

  final DateTime date;

  DailyLogEntity({this.id, required this.emotion, required this.memo, required this.date});
}
