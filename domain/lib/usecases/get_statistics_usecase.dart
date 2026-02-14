import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class GetStatisticsUseCase {
  final CalendarRepository _repository;

  GetStatisticsUseCase(this._repository);

  Future<List<DailyLogRecord>> call(DateTime start, DateTime end) async {
    return _repository.getLogsByRange(start, end);
  }
}
