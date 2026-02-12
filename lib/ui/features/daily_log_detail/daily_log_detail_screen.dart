import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailyLogDetailScreen extends ConsumerWidget {
  final DateTime date;

  const DailyLogDetailScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyLogDetailProvider(date));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('M월 d일 EEEE', 'ko_KR').format(date)),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to edit screen
            },
            child: const Text('수정하기'),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.dailyLog == null
              ? const Center(child: Text('기록을 찾을 수 없습니다.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TODO: Emotion Widget
                      // TODO: Memo Widget
                      // TODO: Photo Pager Widget
                    ],
                  ),
                ),
    );
  }
}
