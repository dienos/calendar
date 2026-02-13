import 'dart:io';

abstract class ImageRepository {
  Future<void> saveImage(int dailyRecordId, File image);
  Future<List<File>> getImages(int dailyRecordId);
}
