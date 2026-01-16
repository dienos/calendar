import 'package:domain/entities/daily_record.dart';
import 'package:domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final Map<DateTime, List<DailyRecord>> _events = {};

  @override
  Future<Map<DateTime, List<DailyRecord>>> getEvents() async {
    // 상태 업데이트 타이밍 문제를 해결하기 위해 최소한의 비동기 딜레이를 줍니다.
    await Future.delayed(Duration.zero);
    return Map.of(_events);
  }

  @override
  Future<void> addEvent(DateTime date, DailyRecord newRecord) async {
    // 상태 업데이트 타이밍 문제를 해결하기 위해 최소한의 비동기 딜레이를 줍니다.
    await Future.delayed(Duration.zero);
    final dateOnly = DateTime.utc(date.year, date.month, date.day);

    final currentEvents = _events[dateOnly] ?? [];
    final updatedEvents = List<DailyRecord>.from(currentEvents)..add(newRecord);
    _events[dateOnly] = updatedEvents;
  }
}
