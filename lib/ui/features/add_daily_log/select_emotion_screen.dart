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

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9F9),
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.vertical,
                            child: child,
                          ),
                        );
                      },
                      child: state.selectedEmotion != null
                          ? Column(
                        key: const ValueKey('add_daily_log_content'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          _MemoInput(selectedDate: selectedDate),
                          const SizedBox(height: 32),
                          _PhotoAttachment(selectedDate: selectedDate),
                          const SizedBox(height: 24),
                        ],
                      )
                          : const SizedBox.shrink(
                        key: ValueKey('empty'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axis: Axis.vertical,
                    child: child,
                  ),
                );
              },
              child: state.selectedEmotion != null
                  ? _SaveButton(
                key: const ValueKey('save_button'),
                selectedDate: selectedDate,
              )
                  : const SizedBox.shrink(
                key: ValueKey('empty_button'),
              ),
            ),
          ],
        ),
      ),
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
            onPressed: () {},
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
      height: 100,
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2.5) : null,
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        spreadRadius: isSelected ? 1 : 0,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(emotion['emoji']!, style: const TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(height: 4),
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
              BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 12)
            ],
          ),
          child: TextField(
            onChanged: (text) => ref.read(addDailyLogViewModelProvider(selectedDate).notifier).updateMemo(text),
            decoration: InputDecoration(
              hintText: '오늘의 이야기를 적어보세요...',
              border: InputBorder.none,
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), spreadRadius: 1, blurRadius: 12)]),
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
          return Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))]),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: 200),
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

class _SaveButton extends ConsumerWidget {
  final DateTime selectedDate;
  const _SaveButton({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addDailyLogViewModelProvider(selectedDate));
    final viewModel = ref.read(addDailyLogViewModelProvider(selectedDate).notifier);
    final theme = Theme.of(context);

    final bool isEmotionSelected = state.selectedEmotion != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isEmotionSelected
              ? () async {
            final success = await viewModel.saveDailyLog();
            if (success) {
              Navigator.of(context).pop();
            }
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEmotionSelected ? theme.colorScheme.primary : Colors.grey[300],
            foregroundColor: isEmotionSelected ? Colors.white : Colors.grey[500],
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            elevation: isEmotionSelected ? 5 : 0,
            shadowColor: theme.colorScheme.primary.withOpacity(0.4),
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
        ),
      ),
    );
  }
}