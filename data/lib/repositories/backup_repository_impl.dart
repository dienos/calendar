import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:domain/entities/backup_result.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class BackupRepositoryImpl implements BackupRepository {
  @override
  Future<bool> saveBackupFile(String defaultFileName, Uint8List bytes) async {
    final result = await FilePicker.platform.saveFile(
      dialogTitle: '백업 파일 저장 위치 선택',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['zip'],
      bytes: bytes,
    );
    return result != null;
  }

  @override
  Future<BackupResult?> readFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final fileData = result.files.single;
    Uint8List? zipBytes;

    if (fileData.bytes != null) {
      zipBytes = fileData.bytes!;
    } else if (fileData.path != null) {
      zipBytes = await File(fileData.path!).readAsBytes();
    } else {
      return null;
    }

    try {
      final archive = ZipDecoder().decodeBytes(zipBytes);

      ArchiveFile? dataTxtFile;
      final imageFiles = <ArchiveFile>[];

      for (final file in archive) {
        if (file.name == 'data.txt') {
          dataTxtFile = file;
        } else if (file.name.startsWith('images/') && file.isFile) {
          imageFiles.add(file);
        }
      }

      if (dataTxtFile == null) {
        return const BackupResult(successCount: -2, failCount: 0);
      }

      final content = utf8.decode(dataTxtFile.content as List<int>);
      final lines = content.split('\n').map((l) => l.trim()).toList();

      final header = lines.first.replaceAll('\ufeff', '').trim();
      if (header != '# CALENDAR_BACKUP_V1') {
        return const BackupResult(successCount: -2, failCount: 0);
      }

      await _copyImagesToAppDirectory(imageFiles);

      return BackupResult(
        successCount: 0,
        failCount: 0,
        lines: lines,
        fileName: fileData.name,
      );
    } catch (_) {
      return const BackupResult(successCount: -2, failCount: 0);
    }
  }

  Future<void> _copyImagesToAppDirectory(List<ArchiveFile> imageFiles) async {
    final docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${docDir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    for (final file in imageFiles) {
      try {
        final fileName = file.name.split('/').last;
        if (fileName.isEmpty) continue;
        final targetFile = File('${imageDir.path}/$fileName');
        await targetFile.writeAsBytes(file.content as List<int>);
      } catch (_) {}
    }
  }
}
