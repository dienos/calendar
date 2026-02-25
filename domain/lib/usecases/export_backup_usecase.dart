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
      final memoEscaped = log.memo.replaceAll('\n', r'\n');
      lines.add('$dateStr|${log.emotion}|$memoEscaped');
    }

    return lines;
  }
}

class NoDataException implements Exception {
  const NoDataException();
}
