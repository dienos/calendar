import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/daily_log_repository.dart';

class GetDailyLogDetailUseCase {
  final DailyLogRepository _repository;

  GetDailyLogDetailUseCase(this._repository);

  Future<DailyLogRecord?> call(DateTime date) {
    return _repository.getDailyLogDetail(date);
  }
}
