import 'package:domain/entities/backup_result.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:domain/repositories/calendar_repository.dart';

class ImportBackupUseCase {
  final CalendarRepository _calendarRepository;
  final BackupRepository _backupRepository;

  ImportBackupUseCase(this._calendarRepository, this._backupRepository);

  Future<BackupResult?> pickFile() async {
    return await _backupRepository.readFromFile();
  }

  Future<BackupResult> doImport(List<String> lines) async {
    final validEmotions = {'정말 좋음', '좋음', '보통', '나쁨', '끔찍함'};
    int success = 0;
    int fail = 0;

    for (final line in lines.skip(1)) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      try {
        final parts = trimmedLine.split('|').map((p) => p.trim()).toList();

        if (parts.length < 2) {
          fail++;
          continue;
        }

        final dateStr = parts[0];
        final emotion = parts[1];
        final memoRaw = parts.length > 2 ? parts[2] : '';
        final imageRaw = parts.length > 3 ? parts[3] : '';

        if (dateStr.isEmpty || emotion.isEmpty) {
          fail++;
          continue;
        }

        final parsedDate = DateTime.parse(dateStr);
        final date = DateTime.utc(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        if (!validEmotions.contains(emotion)) {
          fail++;
          continue;
        }

        final memo = memoRaw.replaceAll(r'\|', '|').replaceAll(r'\n', '\n');
        final images = imageRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        await _calendarRepository.insertOrReplaceLog(
          DailyLogRecord(emotion, memo, date: date, images: images),
        );
        success++;
      } catch (e) {
        print('Import parsing error on line: $line, error: $e');
        fail++;
      }
    }

    return BackupResult(successCount: success, failCount: fail);
  }
}
