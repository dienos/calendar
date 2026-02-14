import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/common/glassy_container.dart';
import 'package:dienos_calendar/ui/common/gradient_background.dart';
import 'package:dienos_calendar/utils/permission_helper.dart';
import 'package:dienos_calendar/utils/ui_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dienos_calendar/ui/common/bottom_action_button.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:dienos_calendar/utils/voice_service.dart';
import 'add_daily_log_screen_view_model.dart';

class AddDailyLogScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final DailyLogRecord? initialRecord;

  const AddDailyLogScreen({super.key, required this.selectedDate, this.initialRecord});

  @override
  ConsumerState<AddDailyLogScreen> createState() => _AddDailyLogScreenState();
}

class _AddDailyLogScreenState extends ConsumerState<AddDailyLogScreen> {
  late TextEditingController _memoController;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController();

    if (widget.initialRecord != null) {
      _memoController.text = widget.initialRecord!.memo;
      Future.microtask(() {
        ref.read(addDailyLogViewModelProvider(widget.selectedDate).notifier).loadInitialData(widget.initialRecord!);
      });
    }
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addDailyLogViewModelProvider(widget.selectedDate));
    final viewModel = ref.read(addDailyLogViewModelProvider(widget.selectedDate).notifier);

    return GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _CustomAppBar(selectedDate: widget.selectedDate),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        state.isEditMode ? '기록을 수정하시겠어요?' : '오늘 기분은 어떠신가요?',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '잠시 나를 돌보는 시간을 가져보세요.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
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
                            child: SizeTransition(sizeFactor: animation, axis: Axis.vertical, child: child),
                          );
                        },
                        child: state.selectedEmotion != null
                            ? Column(
                                key: const ValueKey('add_daily_log_content'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 32),
                                  _MemoInput(selectedDate: widget.selectedDate, controller: _memoController),
                                  const SizedBox(height: 32),
                                  _PhotoAttachment(selectedDate: widget.selectedDate),
                                  const SizedBox(height: 24),
                                ],
                              )
                            : const SizedBox.shrink(key: ValueKey('empty')),
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
                    child: SizeTransition(sizeFactor: animation, axis: Axis.vertical, child: child),
                  );
                },
                child: state.selectedEmotion != null
                    ? _SaveButton(key: const ValueKey('save_button'), selectedDate: widget.selectedDate)
                    : const SizedBox.shrink(key: ValueKey('empty_button')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomAppBar extends ConsumerWidget {
  final DateTime selectedDate;
  const _CustomAppBar({required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addDailyLogViewModelProvider(selectedDate));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.of(context).pop()),
          Column(
            children: [
              Text(
                state.isEditMode ? '기록 수정하기' : '기분 기록하기',
                style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('M월 d일 EEEE', 'ko_KR').format(selectedDate),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: emotions.map((emotion) {
          final isSelected = selectedEmotion == emotion['label'];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onSelectEmotion(emotion['label']!),
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    transform: Matrix4.identity()..scale(isSelected ? 1.15 : 1.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.surface,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.1),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.4)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: isSelected ? 10 : 5,
                          spreadRadius: isSelected ? 1 : 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(child: SvgPicture.asset(emotion['svgPath']!, width: 32, height: 32)),
                  ),
                  const SizedBox(height: 8),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    child: Text(emotion['label']!),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MemoInput extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final TextEditingController controller;

  const _MemoInput({required this.selectedDate, required this.controller});

  @override
  ConsumerState<_MemoInput> createState() => _MemoInputState();
}

class _MemoInputState extends ConsumerState<_MemoInput> with SingleTickerProviderStateMixin {
  final VoiceRecorderService _voiceService = VoiceRecorderService();
  bool _isListening = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      if (mounted) setState(() => _isListening = false);
    } else {
      bool available = await _voiceService.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
          }
        },
      );
      if (available) {
        if (mounted) setState(() => _isListening = true);
        await _voiceService.startListening(
          onResult: (text, isFinal) {
            widget.controller.text = text;
            ref.read(addDailyLogViewModelProvider(widget.selectedDate).notifier).updateMemo(text);
          },
          onSoundLevelChanged: (level) {},
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('음성 인식을 사용할 수 없습니다.')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.edit_note, color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '메모',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _toggleListening,
                  child: Row(
                    children: [
                      Text(
                        '보이스로 입력하기',
                        style: TextStyle(
                          fontSize: 13,
                          color: _isListening ? Colors.redAccent : theme.colorScheme.primary.withOpacity(0.7),
                          fontWeight: _isListening ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.redAccent.withOpacity(0.1) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.redAccent : theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GlassyContainer(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: widget.controller,
                onChanged: (text) =>
                    ref.read(addDailyLogViewModelProvider(widget.selectedDate).notifier).updateMemo(text),
                decoration: InputDecoration(
                  hintText: _isListening ? '듣고 있어요...' : '오늘의 이야기를 적어보세요...',
                  border: InputBorder.none,
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
          ],
        ),
        if (_isListening)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(
                        begin: 1.0,
                        end: 1.3,
                      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.mic, color: Colors.redAccent, size: 40),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '녹음 중...',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
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
                Text(
                  '오늘의 사진',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            Text(
              '${state.images.length}/5개 등록됨',
              style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final result = await viewModel.addImage();
              if (!context.mounted) return;
              if (result == PermissionResult.permanentlyDenied) {
                showAppSnackBar(context, '설정에서 사진 접근 권한을 허용해주세요.');
                openAppSettings();
              } else if (result == PermissionResult.denied) {
                showAppSnackBar(context, '사진 접근 권한이 필요합니다.');
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: GlassyContainer(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '사진 추가하기',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                  ),
                ],
              ),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity, height: 200),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => viewModel.removeImage(idx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
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

    final bool isEmotionSelected = state.selectedEmotion != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      child: BottomActionButton(
        text: state.isEditMode ? '수정하기' : '기분 저장하기',
        icon: Icons.favorite,
        isLoading: state.isLoading,
        onPressed: isEmotionSelected
            ? () async {
                final success = await viewModel.saveDailyLog();
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            : null,
      ),
    );
  }
}
