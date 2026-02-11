import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'add_daily_log_screen_view_model.dart';

class AddDailyLogScreen extends ConsumerWidget {
  final DateTime selectedDate;

  const AddDailyLogScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addDailyLogViewModelProvider(selectedDate));
    final viewModel = ref.read(addDailyLogViewModelProvider(selectedDate).notifier);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _CustomAppBar(selectedDate: selectedDate),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      '오늘 기분은 어떠신가요?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '잠시 나를 돌보는 시간을 가져보세요.',
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    _EmotionSelector(
                      selectedEmotion: state.selectedEmotion,
                      onSelectEmotion: viewModel.selectEmotion,
                    ),
                    const SizedBox(height: 32),
                    _MemoInput(selectedDate: selectedDate),
                    const SizedBox(height: 32),
                    _PhotoAttachment(selectedDate: selectedDate),
                    const SizedBox(height: 120), // For bottom button spacing
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Floating action button is removed and replaced by a button within the body
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final DateTime selectedDate;
  const _CustomAppBar({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Column(
            children: [
              Text('기분 기록하기', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(
                DateFormat('M월 d일 EEEE', 'ko_KR').format(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
      ),
    );
  }
}

class _EmotionSelector extends StatelessWidget {
  final String? selectedEmotion;
  final Function(String) onSelectEmotion;

  const _EmotionSelector({this.selectedEmotion, required this.onSelectEmotion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: emotions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final emotion = emotions[index];
          final isSelected = selectedEmotion == emotion['label'];
          return GestureDetector(
            onTap: () => onSelectEmotion(emotion['label']!),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
                  ),
                  child: Center(
                    child: Text(emotion['emoji']!, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 2), // Adjusted spacing to prevent overflow
                Text(
                  emotion['label']!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MemoInput extends ConsumerWidget {
  final DateTime selectedDate;
  const _MemoInput({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.edit_note, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text('메모', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10)
            ]
          ),
          child: TextField(
            onChanged: (text) => ref.read(addDailyLogViewModelProvider(selectedDate).notifier).updateMemo(text),
            decoration: InputDecoration(
              hintText: '오늘의 이야기를 적어보세요...',
              border: InputBorder.none,
              // suffixIcon: Icon(Icons.mic, color: Colors.grey[400]), // Removed mic icon
            ),
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }
}

class _PhotoAttachment extends ConsumerWidget {
  final DateTime selectedDate;
  const _PhotoAttachment({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addDailyLogViewModelProvider(selectedDate));
    final viewModel = ref.read(addDailyLogViewModelProvider(selectedDate).notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.photo_library, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('오늘의 사진', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            Text('${state.images.length}/5개 등록됨', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: viewModel.addImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
               border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text('사진 추가하기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...state.images.asMap().entries.map((entry) {
          int idx = entry.key;
          File imageFile = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: 200)
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => viewModel.removeImage(idx),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          );
        })
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final DateTime selectedDate;
  const _SaveButton({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(addDailyLogViewModelProvider(selectedDate));
                final viewModel = ref.read(addDailyLogViewModelProvider(selectedDate).notifier);
                final theme = Theme.of(context);

                return ElevatedButton(
                  onPressed: () async {
                    final success = await viewModel.saveDailyLog();
                    if (success) {
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('감정을 선택해주세요.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    elevation: 2,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '기분 저장하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.favorite, size: 20),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
