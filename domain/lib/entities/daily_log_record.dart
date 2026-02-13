import 'package:domain/entities/daily_record.dart';

class DailyLogRecord extends DailyRecord {
  final String emotion;
  final String memo;
  final List<String> images;
  final DateTime? date;
  final int? id;

  DailyLogRecord(
    this.emotion,
    this.memo, {
    this.images = const [],
    this.date,
    this.id,
  });
}
