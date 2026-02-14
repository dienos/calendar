import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class GetMemoLogsUseCase {
  final CalendarRepository _repository;

  GetMemoLogsUseCase(this._repository);

  Future<List<DailyLogRecord>> call(DateTime month) {
    return _repository.getMemoLogs(month);
  }
}
