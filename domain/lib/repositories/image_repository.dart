import 'dart:io';

import '../entities/daily_record.dart';


abstract class ImageRepository {
  Future<void> saveImage(int dailyRecordId, File image);
  Future<List<File>> getImages(int dailyRecordId);
}
