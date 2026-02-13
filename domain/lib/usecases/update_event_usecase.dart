import '../entities/daily_record.dart';
import '../repositories/calendar_repository.dart';

class UpdateEventUseCase {
  final CalendarRepository _repository;

  UpdateEventUseCase(this._repository);

  Future<void> call(DateTime date, DailyRecord updatedRecord) {
    return _repository.updateEvent(date, updatedRecord);
  }
}
