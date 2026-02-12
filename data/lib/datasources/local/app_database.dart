import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import './converter/type_converter.dart';
import './dao/daily_log_dao.dart';
import './entity/daily_log_entity.dart';
import 'entity/image_entity.dart';

part 'app_database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [DailyLogEntity, ImageEntity])
abstract class AppDatabase extends FloorDatabase {
  DailyLogDao get dailyLogDao;
}
