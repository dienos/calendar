import 'dart:io';

import '../repositories/image_repository.dart';

class GetImagesUseCase {
  final ImageRepository repository;

  GetImagesUseCase(this.repository);

  Future<List<File>> call(int dailyRecordId) {
    return repository.getImages(dailyRecordId);
  }
}
