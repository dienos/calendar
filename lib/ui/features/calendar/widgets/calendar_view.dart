import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/features/add_daily_log/add_daily_log_screen_view_model.dart';
import 'package:dienos_calendar/ui/features/add_daily_log/select_emotion_screen.dart';
import 'package:dienos_calendar/utils/date_utils.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarViewModelProvider);
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);
    final theme = Theme.of(context);
    final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    String? getPrimaryEmojiForDay(DateTime day) {
      final events = calendarViewModel.getEventsForDay(day);
      final firstLog = events.whereType<DailyLogRecord>().firstOrNull;
      if (firstLog != null) {
        final entry = emotions.firstWhere(
          (e) => e['label'] == firstLog.emotion,
          orElse: () => {'emoji': ''},
        );
        return entry['emoji'];
      }
      return null;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TableCalendar<DailyLogRecord>(
        rowHeight: 52,
        daysOfWeekHeight: 20,
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: calendarState.focusedDay,
        selectedDayPredicate: (day) {
          if (isSameDay(day, today)) {
            return false;
          }
          return calendarState.selectedDay != null &&
              day.isSameDayAs(calendarState.selectedDay!);
        },
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
                  AddDailyLogScreen(selectedDate: selectedDay),
            ),
          );
        },
        onPageChanged: (focusedDay) {
          calendarViewModel.onPageChanged(focusedDay);
        },
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
          weekendStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.5),
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
    );
  }
}
