import '../entities/daily_record.dart';
import '../repositories/calendar_repository.dart';

class GetEventsUseCase {
  final CalendarRepository _repository;

  GetEventsUseCase(this._repository);

  Future<Map<DateTime, List<DailyRecord>>> call() {
    return _repository.getEvents();
  }
}
