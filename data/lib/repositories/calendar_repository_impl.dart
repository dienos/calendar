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
      final dailyLogRecord = DailyLogRecord(
        dailyLogEntity.emotion,
        dailyLogEntity.memo,
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
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: images.map((i) => i.path).toList(),
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
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: images.map((i) => i.path).toList(),
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
        return DailyLogRecord(
          e.emotion,
          e.memo,
          date: e.date,
          id: e.id,
          images: images.map((i) => i.path).toList(),
        );
      }),
    );
  }

  @override
  Future<List<DailyLogRecord>> getAllLogs() async {
    if (_database == null) return [];

    final entities = await _database.dailyLogDao.findAllDailyLogs();
    return entities
        .map((e) => DailyLogRecord(e.emotion, e.memo, date: e.date, id: e.id))
        .toList();
  }

  @override
  Future<void> insertOrReplaceLog(DailyLogRecord record) async {
    if (_database == null || record.date == null) return;

    final entity = DailyLogEntity(
      emotion: record.emotion,
      memo: record.memo,
      date: record.date!,
    );
    await _database.dailyLogDao.insertOrReplaceDailyLog(entity);
  }
}
