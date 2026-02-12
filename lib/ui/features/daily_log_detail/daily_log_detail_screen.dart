import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'widgets/emotion_section.dart';
import 'widgets/memo_section.dart';
import 'widgets/photo_section.dart';

class DailyLogDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyLogDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyLogAsync = ref.watch(dailyLogDetailProvider(date));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        title: Text(DateFormat('M월 d일 EEEE', 'ko_KR').format(date)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {},
              child: const Text('수정하기'),
            ),
          ),
        ],
      ),
      body: dailyLogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터를 불러올 수 없습니다: $err')),
        data: (dailyLog) {
          if (dailyLog == null) {
            return const Center(child: Text('이 날짜에 저장된 기록이 없습니다.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EmotionSection(emotion: dailyLog.emotion),
                const SizedBox(height: 32),
                MemoSection(memo: dailyLog.memo),
                const SizedBox(height: 32),
                PhotoSection(images: dailyLog.images),
              ],
            ),
          );
        },
      ),
    );
  }
}
