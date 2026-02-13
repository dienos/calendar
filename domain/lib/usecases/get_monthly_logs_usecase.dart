import 'package:domain/entities/daily_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class GetMonthlyLogsUseCase {
  final CalendarRepository _repository;

  GetMonthlyLogsUseCase(this._repository);

  Future<List<DailyRecord>> execute(DateTime month) {
    return _repository.getMonthlyLogs(month);
  }
}
