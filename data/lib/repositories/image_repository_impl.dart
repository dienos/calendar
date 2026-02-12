import 'dart:io';
import 'package:data/datasources/local/dao/image_dao.dart';
import 'package:data/datasources/local/entity/image_entity.dart';
import 'package:domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageDao imageDao;

  ImageRepositoryImpl(this.imageDao);

  @override
  Future<void> saveImage(int dailyRecordId, File image) async {
    final imageEntity = ImageEntity(dailyLogId: dailyRecordId, path: image.path);
    return imageDao.insertImage(imageEntity);
  }

  @override
  Future<List<File>> getImages(int dailyRecordId) async {
    final imageEntities = await imageDao.findImagesByDailyLogId(dailyRecordId);
    return imageEntities.map((e) => File(e.path)).toList();
  }
}
