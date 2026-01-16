import '../entities/daily_record.dart';
import '../repositories/calendar_repository.dart';

class AddEventUseCase {
  final CalendarRepository _repository;

  AddEventUseCase(this._repository);

  Future<void> call(DateTime date, DailyRecord newRecord) {
    return _repository.addEvent(date, newRecord);
  }
}
