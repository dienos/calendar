import 'dart:io';

import '../repositories/image_repository.dart';

class SaveImageUseCase {
  final ImageRepository repository;

  SaveImageUseCase(this.repository);

  Future<void> call(int dailyRecordId, File image) {
    return repository.saveImage(dailyRecordId, image);
  }
}
