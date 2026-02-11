import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/utils/date_utils.dart';
import 'package:domain/entities/daily_log_record.dart';
import '../add_daily_log/select_emotion_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarViewModelProvider);
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);
    final theme = Theme.of(context);

    String? getPrimaryEmojiForDay(DateTime day) {
      final events = calendarViewModel.getEventsForDay(day);
      final firstLog = events.whereType<DailyLogRecord>().firstOrNull;
      if (firstLog != null) {
        const emotions = SelectEmotionScreen.emotions;
        final entry = emotions.firstWhere(
          (e) => e['label'] == firstLog.emotion,
          orElse: () => {'emoji': ''},
        );
        return entry['emoji'];
      }
      return null;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _CalendarHeader(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: TableCalendar<DailyLogRecord>(
                  daysOfWeekHeight: 20,
                  locale: 'ko_KR',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: calendarState.focusedDay,
                  selectedDayPredicate: (day) =>
                      day.isSameDayAs(calendarState.selectedDay),
                  headerVisible: false,
                  daysOfWeekVisible: true,
                  calendarFormat: CalendarFormat.month,
                  eventLoader: (day) => calendarViewModel
                      .getEventsForDay(day)
                      .whereType<DailyLogRecord>()
                      .toList(),
                  onDaySelected: (selectedDay, focusedDay) {
                    calendarViewModel.onDaySelected(selectedDay, focusedDay);

                     Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SelectEmotionScreen(selectedDate: selectedDay),
                      ),
                    );
                  },
                  onPageChanged: (focusedDay) {
                    calendarViewModel.onPageChanged(focusedDay);
                  },
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    weekendStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final emoji = getPrimaryEmojiForDay(day);
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}', style: theme.textTheme.bodyMedium),
                            if (emoji != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(emoji, style: const TextStyle(fontSize: 18)),
                              ),
                          ],
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final emoji = getPrimaryEmojiForDay(day);
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${day.day}',
                                  style: theme.textTheme.bodyMedium!
                                      .copyWith(color: theme.colorScheme.primary)),
                              if (emoji != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      final emoji = getPrimaryEmojiForDay(day);
                      return Container(
                        margin: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                           borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${day.day}',
                                  style: theme.textTheme.bodyMedium!
                                      .copyWith(color: theme.colorScheme.onPrimary)),
                              if (emoji != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_outlined, color: theme.colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text('날짜를 탭하여 기분을 기록하세요',
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: theme.colorScheme.primary)),
                ],
              ),
              const SizedBox(height: 24),
              const _TodaysHighlight(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '캘린더'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '일기'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: 0, 
        onTap: (index) {},
      ),
    );
  }
}

class _CalendarHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final calendarState = ref.watch(calendarViewModelProvider);
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.MMMM('ko_KR').format(calendarState.focusedDay),
              style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
            ),
            Text(
              DateFormat.y('ko_KR').format(calendarState.focusedDay),
              style: theme.textTheme.titleMedium!.copyWith(color: theme.colorScheme.primary),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
                onPressed: () {
                   final newFocusedDay =
                      DateTime(calendarState.focusedDay.year, calendarState.focusedDay.month - 1);
                    calendarViewModel.onPageChanged(newFocusedDay);
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                onPressed: () {
                  final newFocusedDay =
                      DateTime(calendarState.focusedDay.year, calendarState.focusedDay.month + 1);
                    calendarViewModel.onPageChanged(newFocusedDay);
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _TodaysHighlight extends ConsumerWidget {
  const _TodaysHighlight();

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
