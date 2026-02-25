import 'package:domain/repositories/calendar_repository.dart';

class ExportBackupUseCase {
  final CalendarRepository _calendarRepository;

  ExportBackupUseCase(this._calendarRepository);

  Future<List<String>> call() async {
    final allLogs = await _calendarRepository.getAllLogs();
    if (allLogs.isEmpty) throw const NoDataException();

    final lines = <String>['# CALENDAR_BACKUP_V1'];

    for (final log in allLogs) {
      if (log.date == null) continue;
      final d = log.date!;
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final memoEscaped = log.memo
          .replaceAll('|', r'\|')
          .replaceAll('\n', r'\n');
      final images = log.images.map((p) => p.split('/').last).join(',');
      lines.add('$dateStr|${log.emotion}|$memoEscaped|$images');
    }

    return lines;
  }
}

class NoDataException implements Exception {
  const NoDataException();
}
