import 'dart:io';

import 'package:intl/intl.dart';

import 'package:data/datasources/local/app_database.dart';
import 'package:data/datasources/local/entity/daily_log_entity.dart';
import 'package:data/datasources/local/entity/image_entity.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/repositories/calendar_repository.dart';
import 'package:path_provider/path_provider.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AppDatabase? _database;

  CalendarRepositoryImpl(this._database);

  @override
  Future<Map<DateTime, List<DailyRecord>>> getEvents() async {
    if (_database == null) return {};

    final allDailyLogs = await _database.dailyLogDao.findAllDailyLogs();
    final Map<DateTime, List<DailyRecord>> events = {};

    for (var dailyLogEntity in allDailyLogs) {
      final date = DateTime.utc(
        dailyLogEntity.date.year,
        dailyLogEntity.date.month,
        dailyLogEntity.date.day,
      );

      final images = await _database.dailyLogDao.findImagesByLogId(
        dailyLogEntity.id!,
      );
      final resolvedImages = await Future.wait(
        images.map((i) => _resolveImagePath(i.path)),
      );

      final dailyLogRecord = DailyLogRecord(
        dailyLogEntity.emotion,
        dailyLogEntity.memo,
        date: date,
        id: dailyLogEntity.id,
        images: resolvedImages,
      );

      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(dailyLogRecord);
    }
    return Map.of(events);
  }

  @override
  Future<void> addEvent(DateTime date, DailyRecord newRecord) async {
    if (_database == null) {
      return;
    }

    if (newRecord is DailyLogRecord) {
      final dailyLogEntity = DailyLogEntity(
        emotion: newRecord.emotion,
        memo: newRecord.memo,
        date: date,
      );
      final dailyLogId = await _database.dailyLogDao.insertDailyLog(
        dailyLogEntity,
      );

      if (newRecord.images.isNotEmpty) {
        final appDir = await _getAppImageDirectory();
        for (final imagePath in newRecord.images) {
          final sourceFile = File(imagePath);
          if (await sourceFile.exists()) {
            final fileName =
                '${dailyLogId}_${DateTime.now().millisecondsSinceEpoch}_${newRecord.images.indexOf(imagePath)}.jpg';
            final savedFile = await sourceFile.copy('${appDir.path}/$fileName');
            final imageEntity = ImageEntity(
              dailyLogId: dailyLogId,
              path: savedFile.path,
            );
            await _database.imageDao.insertImage(imageEntity);
          }
        }
      }
    }
  }

  @override
  Future<void> updateEvent(DateTime date, DailyRecord updatedRecord) async {
    if (_database == null) {
      return;
    }

    final existingLog = await _database.dailyLogDao.findDailyLogByDate(date);

    if (existingLog == null) {
      // 데이터가 없으면 새로 추가
      await addEvent(date, updatedRecord);
      return;
    }

    if (updatedRecord is DailyLogRecord) {
      // 1. DailyLog 내용 업데이트
      final updatedEntity = DailyLogEntity(
        id: existingLog.id, // 기존 ID 유지
        emotion: updatedRecord.emotion,
        memo: updatedRecord.memo,
        date: date,
      );
      await _database.dailyLogDao.updateDailyLog(updatedEntity);

      // 2. 이미지 업데이트 (기존 연결 삭제 후 재등록)
      if (existingLog.id != null) {
        await _database.imageDao.deleteImagesByDailyLogId(existingLog.id!);

        if (updatedRecord.images.isNotEmpty) {
          final appDir = await _getAppImageDirectory();

          for (int i = 0; i < updatedRecord.images.length; i++) {
            final imagePath = updatedRecord.images[i];
            final sourceFile = File(imagePath);
            String finalPath = imagePath;

            // 앱 내부 저장소 경로에 없는 파일(=새로 추가된 파일)만 복사
            // 기존 파일 path에는 이미 앱 내부 경로가 포함되어 있음
            if (!imagePath.contains(appDir.path) && await sourceFile.exists()) {
              final fileName =
                  '${existingLog.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
              final savedFile = await sourceFile.copy(
                '${appDir.path}/$fileName',
              );
              finalPath = savedFile.path;
            } else if (!await sourceFile.exists()) {
              // 파일이 실제로 존재하지 않으면 DB에 추가하지 않음 (예외 처리)
              continue;
            }

            final imageEntity = ImageEntity(
              dailyLogId: existingLog.id!,
              path: finalPath,
            );
            await _database.imageDao.insertImage(imageEntity);
          }
        }
      }
    }
  }

  Future<Directory> _getAppImageDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${docDir.path}/images');
    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  Future<String> _resolveImagePath(String storedPath) async {
    if (storedPath.isEmpty) return storedPath;
    final appDir = await _getAppImageDirectory();
    final fileName = storedPath.split('/').last;
    return '${appDir.path}/$fileName';
  }

  @override
  Future<int> countMemoEntriesForMonth(String yearMonth) async {
    if (_database == null) return 0;
    final count = await _database.dailyLogDao.countMemoEntriesForMonth(
      yearMonth,
    );
    return count ?? 0;
  }

  @override
  Future<int> countMoodEntriesForMonth(String yearMonth) async {
    if (_database == null) return 0;
    final count = await _database.dailyLogDao.countMoodEntriesForMonth(
      yearMonth,
    );
    return count ?? 0;
  }

  @override
  Future<int> countPhotoEntriesForMonth(String yearMonth) async {
    if (_database == null) return 0;
    final count = await _database.imageDao.countPhotoEntriesForMonth(yearMonth);
    return count ?? 0;
  }

  @override
  Future<List<DailyRecord>> getMonthlyLogs(DateTime month) async {
    if (_database == null) return [];

    final yearMonth = DateFormat('yyyy-MM').format(month);
    final entities = await _database.dailyLogDao.findDailyLogsByMonth(
      yearMonth,
    );

    return Future.wait(
      entities.map((e) async {
        final images = await _database.dailyLogDao.findImagesByLogId(e.id!);
        final resolvedImages = await Future.wait(
          images.map((i) => _resolveImagePath(i.path)),
        );
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: resolvedImages,
        );
      }),
    );
  }

  @override
  Future<List<DailyLogRecord>> getLogsByRange(
    DateTime start,
    DateTime end,
  ) async {
    if (_database == null) return [];

    final entities = await _database.dailyLogDao.findDailyLogsByRange(
      start,
      end,
    );

    return Future.wait(
      entities.map((e) async {
        final images = await _database.dailyLogDao.findImagesByLogId(e.id!);
        final resolvedImages = await Future.wait(
          images.map((i) => _resolveImagePath(i.path)),
        );
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: resolvedImages,
        );
      }),
    );
  }

  @override
  Future<List<DailyLogRecord>> getMemoLogs(DateTime month) async {
    if (_database == null) return [];

    final yearMonth = DateFormat('yyyy-MM').format(month);
    final entities = await _database.dailyLogDao.findDailyLogsWithMemoByMonth(
      yearMonth,
    );

    return Future.wait(
      entities.map((e) async {
        final images = await _database.dailyLogDao.findImagesByLogId(e.id!);
        final resolvedImages = await Future.wait(
          images.map((i) => _resolveImagePath(i.path)),
        );
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: resolvedImages,
        );
      }),
    );
  }

  @override
  Future<List<DailyLogRecord>> getAllLogs() async {
    if (_database == null) return [];

    final entities = await _database.dailyLogDao.findAllDailyLogs();
    return Future.wait(
      entities.map((e) async {
        final images = await _database.dailyLogDao.findImagesByLogId(e.id!);
        final resolvedImages = await Future.wait(
          images.map((i) => _resolveImagePath(i.path)),
        );
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: resolvedImages,
        );
      }),
    );
  }

  @override
  Future<void> insertOrReplaceLog(DailyLogRecord record) async {
    if (_database == null || record.date == null) return;

    // 1. 기존 로그 확인
    final existingLog = await _database.dailyLogDao.findDailyLogByDate(
      record.date!,
    );

    // 2. 로그 엔티티 생성 및 삽입/교체
    final entity = DailyLogEntity(
      id: existingLog?.id,
      emotion: record.emotion,
      memo: record.memo,
      date: record.date!,
    );
    final logId = await _database.dailyLogDao.insertOrReplaceDailyLog(entity);

    // 3. 이미지 정보 업데이트
    if (existingLog?.id != null) {
      await _database.imageDao.deleteImagesByDailyLogId(existingLog!.id!);
    }

    // 4. 새 이미지 정보 등록 (백업 파일의 경로에서 파일명만 추출하여 현재 앱 경로로 보정하여 저장)
    if (record.images.isNotEmpty) {
      for (final path in record.images) {
        if (path.isEmpty) continue;
        final resolvedPath = await _resolveImagePath(path);
        await _database.imageDao.insertImage(
          ImageEntity(dailyLogId: logId, path: resolvedPath),
        );
      }
    }
  }
}
