import 'dart:typed_data';
import 'package:domain/entities/backup_result.dart';

abstract class BackupRepository {
  Future<bool> saveBackupFile(String defaultFileName, Uint8List bytes);
  Future<BackupResult?> readFromFile();
}
