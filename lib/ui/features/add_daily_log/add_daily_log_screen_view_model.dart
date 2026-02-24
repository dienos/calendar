import 'dart:io';

import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/utils/permission_helper.dart';
import 'package:dienos_calendar/utils/widget_service.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:domain/usecases/add_event_usecase.dart';
import 'package:domain/usecases/update_event_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

const List<Map<String, String>> emotions = [
  {'svgPath': 'assets/svgs/emotion_very_good.svg', 'label': '정말 좋음'},
  {'svgPath': 'assets/svgs/emotion_good.svg', 'label': '좋음'},
  {'svgPath': 'assets/svgs/emotion_soso.svg', 'label': '보통'},
  {'svgPath': 'assets/svgs/emotion_bad.svg', 'label': '나쁨'},
  {'svgPath': 'assets/svgs/emotion_very_bad.svg', 'label': '끔찍함'},
];

class AddDailyLogState {
  final DateTime selectedDate;
  final String? selectedEmotion;
  final String memo;
  final List<File> images;
  final bool isLoading;
  final bool isEditMode;

  const AddDailyLogState({
    required this.selectedDate,
    this.selectedEmotion,
    this.memo = '',
    this.images = const [],
    this.isLoading = false,
    this.isEditMode = false,
  });

  AddDailyLogState copyWith({
    DateTime? selectedDate,
    String? selectedEmotion,
    String? memo,
    List<File>? images,
    bool? isLoading,
    bool? isEditMode,
  }) {
    return AddDailyLogState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      memo: memo ?? this.memo,
      images: images ?? this.images,
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  String toString() {
    return 'AddDailyLogState(selectedDate: $selectedDate, selectedEmotion: $selectedEmotion, memo: $memo, images: $images, isLoading: $isLoading, isEditMode: $isEditMode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddDailyLogState &&
        other.selectedDate == selectedDate &&
        other.selectedEmotion == selectedEmotion &&
        other.memo == memo &&
        listEquals(other.images, images) &&
        other.isLoading == isLoading &&
        other.isEditMode == isEditMode;
  }

  @override
  int get hashCode {
    return Object.hash(selectedDate, selectedEmotion, memo, images, isLoading, isEditMode);
  }
}

class AddDailyLogViewModel extends StateNotifier<AddDailyLogState> {
  final Ref _ref;
  final AddEventUseCase _addEventUseCase;
  final UpdateEventUseCase _updateEventUseCase;
  final _picker = ImagePicker();

  AddDailyLogViewModel(this._ref, DateTime selectedDate, this._addEventUseCase, this._updateEventUseCase)
    : super(AddDailyLogState(selectedDate: selectedDate));

  void loadInitialData(DailyLogRecord record) {
    if (state.isEditMode) return;

    state = state.copyWith(
      selectedEmotion: record.emotion,
      memo: record.memo,
      images: record.images.map((path) => File(path)).toList(),
      isEditMode: true,
    );
  }

  void selectEmotion(String emotion) {
    state = state.copyWith(selectedEmotion: emotion);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  Future<PermissionResult?> addImage() async {
    if (state.images.length >= 5) {
      return null;
    }

    final permissionResult = await PermissionHelper.requestPhotoPermission();
    if (permissionResult != PermissionResult.granted) {
      return permissionResult;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      state = state.copyWith(images: [...state.images, File(pickedFile.path)]);
    }
    return PermissionResult.granted;
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
      final record = DailyLogRecord(
        state.selectedEmotion!,
        state.memo,
        images: state.images.map((f) => f.path).toList(),
      );

      if (state.isEditMode) {
        await _updateEventUseCase(state.selectedDate, record);
      } else {
        await _addEventUseCase(state.selectedDate, record);
      }

      _ref.invalidate(calendarViewModelProvider);
      _ref.invalidate(dailyLogDetailProvider(state.selectedDate));

      await WidgetService.update(_ref.read(getEventsUseCaseProvider));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
