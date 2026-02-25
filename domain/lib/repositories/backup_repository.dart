import 'package:domain/entities/backup_result.dart';

abstract class BackupRepository {
  Future<String?> pickDirectoryPath();
  Future<void> saveToFile(List<String> lines, String directoryPath);
  Future<BackupResult?> readFromFile();
}
