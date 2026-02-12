import 'package:dienos_calendar/providers.dart';
import 'package:dienos_calendar/ui/features/add_daily_log/add_daily_log_screen_view_model.dart';
import 'package:dienos_calendar/ui/features/add_daily_log/select_emotion_screen.dart';
import 'package:dienos_calendar/utils/date_utils.dart';
import 'package:domain/entities/daily_log_record.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarState = ref.watch(calendarViewModelProvider);
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);
    final theme = Theme.of(context);
    final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    String? getDisplaySvgPathForDay(DateTime day) {
      final events = calendarViewModel.getEventsForDay(day);
      final firstLog = events.whereType<DailyLogRecord>().firstOrNull;
      if (firstLog != null) {
        final entry = emotions.firstWhere(
          (e) => e['label'] == firstLog.emotion,
          orElse: () => {},
        );
        return entry['svgPath'];
      }
      return null;
    }

    Widget buildCalendarDay(DateTime day, {BoxDecoration? decoration}) {
      final svgPath = getDisplaySvgPathForDay(day);
      final isToday = isSameDay(day, today);

      return Container(
        margin: const EdgeInsets.all(4.0),
        decoration: decoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.day}',
                style: isToday
                    ? theme.textTheme.bodyMedium!
                        .copyWith(color: theme.colorScheme.primary)
                    : theme.textTheme.bodyMedium,
              ),
              SizedBox(
                height: 24.0,
                child: Center(
                  child: svgPath != null
                      ? SvgPicture.asset(svgPath, width: 22, height: 22)
                      : SvgPicture.asset("assets/svgs/empty.svg", width: 22, height: 22),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TableCalendar(
        rowHeight: 60,
        daysOfWeekHeight: 20,
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: calendarState.focusedDay,
        selectedDayPredicate: (day) =>
            calendarState.selectedDay != null &&
            day.isSameDayAs(calendarState.selectedDay!),
        headerVisible: false,
        daysOfWeekVisible: true,
        calendarFormat: CalendarFormat.month,
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
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.transparent),
          selectedDecoration: BoxDecoration(color: Colors.transparent),
          defaultDecoration: BoxDecoration(color: Colors.transparent),
          weekendDecoration: BoxDecoration(color: Colors.transparent),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              buildCalendarDay(day),
          todayBuilder: (context, day, focusedDay) {
            return buildCalendarDay(
              day,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return buildCalendarDay(
              day,
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(12),
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
