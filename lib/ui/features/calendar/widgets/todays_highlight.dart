import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/features/add_daily_log/select_emotion_screen.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TodaysHighlight extends ConsumerWidget {
  const TodaysHighlight({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(calendarViewModelProvider.select((state) => state.selectedDay));
    final eventsMap = ref.watch(calendarViewModelProvider.select((state) => state.events));
    final eventsForDay = eventsMap[DateTime.utc(selectedDate.year, selectedDate.month, selectedDate.day)] ?? [];
    final firstLog = eventsForDay.whereType<DailyLogRecord>().firstOrNull;
    final theme = Theme.of(context);

    if (firstLog == null || firstLog.memo.isEmpty) {
      return const SizedBox.shrink();
    }

    String? emoji = '✨';
    const emotions = SelectEmotionScreen.emotions;
    final entry = emotions.firstWhere(
          (e) => e['label'] == firstLog.emotion,
      orElse: () => {'emoji': '✨'},
    );
    emoji = entry['emoji'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("오늘의 하이라이트", style: theme.textTheme.labelMedium!.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(emoji ?? '', style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMMd('ko_KR').format(selectedDate),
                      style: theme.textTheme.labelMedium!.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('"${firstLog.memo}"', style: theme.textTheme.bodyLarge, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
