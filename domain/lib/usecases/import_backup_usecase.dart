import 'package:domain/entities/backup_result.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:domain/repositories/calendar_repository.dart';

class ImportBackupUseCase {
  final CalendarRepository _calendarRepository;
  final BackupRepository _backupRepository;

  ImportBackupUseCase(this._calendarRepository, this._backupRepository);

  Future<BackupResult?> pickFile() => _backupRepository.readFromFile();

  Future<BackupResult> doImport(List<String> lines) async {
    final validEmotions = {'정말 좋음', '좋음', '보통', '나쁨', '끔찍함'};
    int success = 0;
    int fail = 0;

    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      try {
        final parts = line.split('|');
        if (parts.length != 3) {
          fail++;
          continue;
        }

        final date = DateTime.parse(parts[0].trim());
        final emotion = parts[1].trim();
        final memo = parts[2].replaceAll(r'\n', '\n');

        if (!validEmotions.contains(emotion)) {
          fail++;
          continue;
        }

        await _calendarRepository.insertOrReplaceLog(
          DailyLogRecord(emotion, memo, date: date),
        );
        success++;
      } catch (_) {
        fail++;
      }
    }

    return BackupResult(successCount: success, failCount: fail);
  }
}
