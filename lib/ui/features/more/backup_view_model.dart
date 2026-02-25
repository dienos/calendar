import 'package:domain/entities/backup_result.dart';
import 'package:domain/repositories/backup_repository.dart';
import 'package:domain/usecases/export_backup_usecase.dart';
import 'package:domain/usecases/import_backup_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/permission_helper.dart';

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

  BackupViewModel(this._exportUseCase, this._importUseCase, this._backupRepository) : super(const BackupIdle());

  Future<BackupResult?> prepareImport() async {
    if (state is BackupLoading) return null;
    state = const BackupLoading();

    // 권한 체크
    final permission = await PermissionHelper.requestStoragePermission();
    if (permission != PermissionResult.granted) {
      state = BackupError(
        permission == PermissionResult.permanentlyDenied ? '저장소 권한이 영구적으로 거부되었습니다. 설정에서 허용해 주세요' : '저장소 접근 권한이 필요합니다',
      );
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
      } else if (result.failCount > 0) {
        state = BackupSuccess('${result.successCount}개의 기록을 불러왔어요 ✓ (실패: ${result.failCount}건)');
      } else {
        state = BackupSuccess('${result.successCount}개의 기록을 모두 불러왔어요 ✓');
      }
    } catch (_) {
      if (mounted) state = const BackupError('오류가 발생했어요. 다시 시도해 주세요');
    }
  }

  Future<void> exportBackup() async {
    if (state is BackupLoading) return;
    state = const BackupLoading();

    // 권한 체크
    final permission = await PermissionHelper.requestStoragePermission();
    if (permission != PermissionResult.granted) {
      state = BackupError(
        permission == PermissionResult.permanentlyDenied ? '저장소 권한이 영구적으로 거부되었습니다. 설정에서 허용해 주세요' : '저장소 접근 권한이 필요합니다',
      );
      return;
    }

    try {
      // 1. 폴더 선택을 먼저 수행 (사용자 인터랙션)
      final path = await _backupRepository.pickDirectoryPath();
      if (path == null) {
        state = const BackupIdle();
        return;
      }

      // 2. 백업 데이터 준비
      final lines = await _exportUseCase();

      // 3. 실제 파일 저장
      await _backupRepository.saveToFile(lines, path);

      if (!mounted) return;
      state = const BackupSuccess('백업 완료! ✓');
    } on NoDataException {
      if (mounted) state = const BackupError('내보낼 데이터가 없어요');
    } catch (e) {
      // 에러 로그 출력하여 추적 용이성 확보
      debugPrint('Export Error: $e');
      if (mounted) state = const BackupError('파일 저장에 실패했어요. 다시 시도해 주세요');
    }
  }

  void reset() => state = const BackupIdle();
}
