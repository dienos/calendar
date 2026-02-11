import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const List<Map<String, String>> emotions = [
  {'emoji': '🤩', 'label': '정말 좋음'},
  {'emoji': '🙂', 'label': '좋음'},
  {'emoji': '😐', 'label': '보통'},
  {'emoji': '😟', 'label': '나쁨'},
  {'emoji': '😠', 'label': '끔찍함'},
];

class AddDailyLogState {
  final DateTime selectedDate;
  final String? selectedEmotion;
  final String memo;
  final List<File> images;
  final bool isLoading;

  const AddDailyLogState({
    required this.selectedDate,
    this.selectedEmotion,
    this.memo = '',
    this.images = const [],
    this.isLoading = false,
  });

  AddDailyLogState copyWith({
    DateTime? selectedDate,
    String? selectedEmotion,
    String? memo,
    List<File>? images,
    bool? isLoading,
  }) {
    return AddDailyLogState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      memo: memo ?? this.memo,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  String toString() {
    return 'AddDailyLogState(selectedDate: $selectedDate, selectedEmotion: $selectedEmotion, memo: $memo, images: $images, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddDailyLogState &&
        other.selectedDate == selectedDate &&
        other.selectedEmotion == selectedEmotion &&
        other.memo == memo &&
        listEquals(other.images, images) &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode {
    return Object.hash(
      selectedDate,
      selectedEmotion,
      memo,
      images,
      isLoading,
    );
  }
}

class AddDailyLogViewModel extends StateNotifier<AddDailyLogState> {
  final _picker = ImagePicker();

  AddDailyLogViewModel(DateTime selectedDate)
      : super(AddDailyLogState(selectedDate: selectedDate));

  void selectEmotion(String emotion) {
    state = state.copyWith(selectedEmotion: emotion);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  Future<void> addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (state.images.length < 5) {
        state = state.copyWith(images: [...state.images, File(pickedFile.path)]);
      }
    }
  }

  void removeImage(int index) {
    final newImages = List<File>.from(state.images);
    newImages.removeAt(index);
    state = state.copyWith(images: newImages);
  }

  Future<bool> saveDailyLog() async {
    if (state.selectedEmotion == null) {
      return false;
    }

    state = state.copyWith(isLoading: true);
    try {
      // TODO: Implement actual saving logic using a use case
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}

final addDailyLogViewModelProvider = StateNotifierProvider.family<
    AddDailyLogViewModel, AddDailyLogState, DateTime>((ref, selectedDate) {
  return AddDailyLogViewModel(selectedDate);
});
