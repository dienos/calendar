import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:domain/entities/backup_result.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:domain/usecases/export_backup_usecase.dart';
import 'package:domain/usecases/import_backup_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/permission_helper.dart';
import '../../../providers.dart';

sealed class BackupState {
  const BackupState();
}

class BackupIdle extends BackupState {
  const BackupIdle();
}

class BackupLoading extends BackupState {
  const BackupLoading();
}

class BackupSuccess extends BackupState {
  final String message;
  const BackupSuccess(this.message);
}

class BackupError extends BackupState {
  final String message;
  const BackupError(this.message);
}

class BackupViewModel extends StateNotifier<BackupState> {
  final ExportBackupUseCase _exportUseCase;
  final ImportBackupUseCase _importUseCase;
  final BackupRepository _backupRepository;
  final Ref _ref;

  BackupViewModel(this._exportUseCase, this._importUseCase, this._backupRepository, this._ref)
    : super(const BackupIdle());

  Future<BackupResult?> prepareImport() async {
    if (state is BackupLoading) return null;
    state = const BackupLoading();

    final permission = await PermissionHelper.requestStoragePermission();
    if (permission != PermissionResult.granted) {
      if (permission == PermissionResult.permanentlyDenied) {
        state = const BackupError('저장소 권한이 영구적으로 거부되었습니다. 설정에서 허용해 주세요');
      } else {
        state = const BackupIdle();
      }
      return null;
    }

    try {
      final result = await _importUseCase.pickFile();
      if (!mounted) return null;
      if (result == null) {
        state = const BackupIdle();
        return null;
      }
      if (result.successCount == -2) {
        state = const BackupError('올바른 백업 파일이 아니에요');
        return null;
      }
      state = const BackupIdle();
      return result;
    } catch (_) {
      if (mounted) state = const BackupError('오류가 발생했어요. 다시 시도해 주세요');
      return null;
    }
  }

  Future<void> doImport(List<String> lines) async {
    state = const BackupLoading();
    try {
      final result = await _importUseCase.doImport(lines);
      if (!mounted) return;
      if (result.successCount == 0) {
        state = const BackupError('불러올 수 있는 데이터가 없어요 (파일을 확인해 주세요)');
      } else {
        _ref.invalidate(calendarViewModelProvider);
        _ref.invalidate(getEventsUseCaseProvider);
        _ref.invalidate(dailyLogDetailProvider);

        if (result.failCount > 0) {
          state = BackupSuccess('${result.successCount}개의 기록을 불러왔어요 ✓ (실패: ${result.failCount}건)');
        } else {
          state = BackupSuccess('${result.successCount}개의 기록을 모두 불러왔어요 ✓');
        }
      }
    } catch (_) {
      if (mounted) state = const BackupError('오류가 발생했어요. 다시 시도해 주세요');
    }
  }

  Future<void> exportBackup() async {
    if (state is BackupLoading) return;
    state = const BackupLoading();

    final permission = await PermissionHelper.requestStoragePermission();
    if (permission != PermissionResult.granted) {
      if (permission == PermissionResult.permanentlyDenied) {
        state = const BackupError('저장소 권한이 영구적으로 거부되었습니다. 설정에서 허용해 주세요');
      } else {
        state = const BackupIdle();
      }
      return;
    }

    try {
      final lines = await _exportUseCase();
      final content = lines.join('\n');
      final contentBytes = utf8.encode(content);

      final archive = Archive();
      archive.addFile(ArchiveFile('data.txt', contentBytes.length, contentBytes));

      final docDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${docDir.path}/images');
      if (await imageDir.exists()) {
        final imageFiles = imageDir.listSync().whereType<File>().toList();
        for (final file in imageFiles) {
          final bytes = await file.readAsBytes();
          final fileName = file.path.split('/').last;
          archive.addFile(ArchiveFile('images/$fileName', bytes.length, bytes));
        }
      }

      final zipBytes = Uint8List.fromList(ZipEncoder().encode(archive)!);
      final now = DateTime.now();
      final defaultFileName = 'backup_${DateFormat('yyyyMMdd_HHmmss').format(now)}.zip';
      final success = await _backupRepository.saveBackupFile(defaultFileName, zipBytes);

      if (!success) {
        state = const BackupIdle();
        return;
      }

      if (!mounted) return;
      state = const BackupSuccess('백업 완료! ✓');
    } on NoDataException {
      if (mounted) state = const BackupError('내보낼 데이터가 없어요');
    } catch (e) {
      debugPrint('Export Error: $e');
      if (mounted) state = const BackupError('파일 저장에 실패했어요. 다시 시도해 주세요');
    }
  }

  void reset() => state = const BackupIdle();
}
