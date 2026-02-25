import 'dart:io';

import 'package:domain/entities/backup_result.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class BackupRepositoryImpl implements BackupRepository {
  @override
  Future<String?> pickDirectoryPath() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  @override
  Future<void> saveToFile(List<String> lines, String directoryPath) async {
    final now = DateTime.now();
    final fileName = 'backup_${DateFormat('yyyyMMdd_HHmmss').format(now)}.txt';
    final file = File('$directoryPath/$fileName');
    await file.writeAsString(lines.join('\n'), flush: true);
  }

  @override
  Future<BackupResult?> readFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.single.path;
    if (path == null) return null;

    final file = File(path);
    final content = await file.readAsString();
    final lines = content.split('\n').map((l) => l.trim()).toList();

    if (lines.isEmpty || lines.first != '# CALENDAR_BACKUP_V1') {
      return const BackupResult(successCount: -2, failCount: 0);
    }

    return BackupResult(
      successCount: 0,
      failCount: 0,
      lines: lines,
      fileName: result.files.single.name,
    );
  }
}
