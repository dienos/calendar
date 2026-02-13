import '../entities/monthly_stats.dart';
import '../repositories/calendar_repository.dart';

class GetMonthlyStatsUseCase {
  final CalendarRepository _repository;

  GetMonthlyStatsUseCase(this._repository);

  Future<MonthlyStats> call(DateTime month) async {
    final yearMonth = '${month.year}-${month.month.toString().padLeft(2, '0')}';

    final moodCount = await _repository.countMoodEntriesForMonth(yearMonth);
    final memoCount = await _repository.countMemoEntriesForMonth(yearMonth);
    final photoCount = await _repository.countPhotoEntriesForMonth(yearMonth);

    return MonthlyStats(
      moodEntries: moodCount,
      memoEntries: memoCount,
      photoEntries: photoCount,
    );
  }
}
