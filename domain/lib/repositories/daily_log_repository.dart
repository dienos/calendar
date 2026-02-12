import 'package:domain/entities/daily_log_record.dart';

abstract class DailyLogRepository {
  Future<DailyLogRecord?> getDailyLogDetail(DateTime date);
}
