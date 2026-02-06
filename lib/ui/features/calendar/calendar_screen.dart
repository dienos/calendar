import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/daily_log_record.dart';
import '../../../utils/ui_utils.dart';
import '../../../utils/date_utils.dart'; // Import the new date utils
import '../add_daily_log/select_emotion_screen.dart';
import '../daily_log_list/daily_log_list_screen.dart';
import '../../common/widgets/calendar_day_cell.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;

  final DateTime _firstDay = DateTime.utc(2020, 1, 1);
  final DateTime _lastDay = DateTime.utc(2030, 12, 31);

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final initialPage = today.difference(_firstDay).inDays;
    _pageController = PageController(initialPage: initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getEmojiForEmotion(String emotionLabel) {
    const emotions = SelectEmotionScreen.emotions;
    final entry = emotions.firstWhere(
      (e) => e['label'] == emotionLabel,
      orElse: () => {'emoji': ''},
    );
    return entry['emoji']!;
  }

  void _onTodayButtonPressed() {
    final today = DateTime.now();
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);
    calendarViewModel.onDaySelected(today, today);
    final pageIndex = today.difference(_firstDay).inDays;
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarViewModelProvider);
    final now = DateTime.now();

    final pageViewWidget = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        final newSelectedDay = _firstDay.add(Duration(days: index));
        if (!newSelectedDay.isSameDayAs(calendarState.selectedDay)) {
          ref.read(calendarViewModelProvider.notifier).onDaySelected(newSelectedDay, newSelectedDay);
        }
      },
      itemBuilder: (context, index) {
        final date = _firstDay.add(Duration(days: index));
        final records = calendarState.events[DateTime.utc(date.year, date.month, date.day)] ?? [];
        final dailyLogRecords = records.whereType<DailyLogRecord>().toList();
        final summaryWidgets = <Widget>[];

        if (dailyLogRecords.isNotEmpty) {
          summaryWidgets.add(
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text('${dailyLogRecords.length}개의 기록'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DailyLogListScreen(
                      date: date,
                      logs: dailyLogRecords,
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8.0),
              Expanded(
                child: records.isEmpty
                    ? const Center(child: Text('작성된 기록이 없습니다.'))
                    : ListView(children: summaryWidgets),
              ),
            ],
          ),
        );
      },
      itemCount: _lastDay.difference(_firstDay).inDays + 1,
    );

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              child: const Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
            const ListTile(leading: Icon(Icons.info_outline), title: Text('About')),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: _onTodayButtonPressed,
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      '${now.day}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final calendarWidget = TableCalendar<DailyRecord>(
            locale: 'ko_KR',
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: calendarState.focusedDay,
            selectedDayPredicate: (day) => day.isSameDayAs(calendarState.selectedDay),
            eventLoader: ref.read(calendarViewModelProvider.notifier).getEventsForDay,
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false, headerPadding: EdgeInsets.zero),
            daysOfWeekHeight: 30,
            rowHeight: 65,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              disabledTextStyle: TextStyle(color: Colors.grey),
              selectedDecoration: BoxDecoration(color: Colors.transparent),
              todayDecoration: BoxDecoration(color: Colors.transparent),
              defaultDecoration: BoxDecoration(color: Colors.transparent),
              weekendDecoration: BoxDecoration(color: Colors.transparent),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (selectedDay.isAfterDay(now)) {
                showAppSnackBar(context, '미래의 날짜는 기록할 수 없습니다.');
                if (!selectedDay.isSameDayAs(calendarState.selectedDay)) {
                  ref.read(calendarViewModelProvider.notifier).onDaySelected(selectedDay, focusedDay);
                }
                return;
              }

              if (!selectedDay.isSameDayAs(calendarState.selectedDay)) {
                ref.read(calendarViewModelProvider.notifier).onDaySelected(selectedDay, focusedDay);
                final pageIndex = selectedDay.difference(_firstDay).inDays;
                _pageController.jumpToPage(pageIndex);
              }

              final events = ref.read(calendarViewModelProvider.notifier).getEventsForDay(selectedDay);
              if (events.isEmpty) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SelectEmotionScreen(selectedDate: selectedDay)),
                );
              } else {
                final dailyLogs = events.whereType<DailyLogRecord>().toList();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DailyLogListScreen(date: selectedDay, logs: dailyLogs)),
                );
              }
            },
            onPageChanged: ref.read(calendarViewModelProvider.notifier).onPageChanged,
            calendarFormat: CalendarFormat.month,
            calendarBuilders: CalendarBuilders(
              prioritizedBuilder: (context, day, focusedDay) {
                final dailyLog = ref.read(calendarViewModelProvider.notifier).getEventsForDay(day).whereType<DailyLogRecord>().firstOrNull;
                final emoji = dailyLog != null ? _getEmojiForEmotion(dailyLog.emotion) : null;
                final isFuture = day.isAfterDay(now);

                Widget circleContent;
                if (emoji != null) {
                  circleContent = Text(emoji, style: const TextStyle(fontSize: 24));
                } else {
                  circleContent = Icon(Icons.add, color: isFuture ? Colors.grey.shade300 : Colors.grey, size: 24);
                }

                return CalendarDayCell(
                  dayNumber: day.day,
                  circleContent: circleContent,
                  isSelected: day.isSameDayAs(calendarState.selectedDay),
                  isToday: day.isSameDayAs(now),
                  isFuture: isFuture,
                );
              },
            ),
          );

          if (orientation == Orientation.portrait) {
            return Column(
              children: [
                calendarWidget,
                Expanded(child: pageViewWidget),
              ],
            );
          } else {
            return Row(
              children: [
                Flexible(flex: 1, child: SingleChildScrollView(child: calendarWidget)),
                Expanded(flex: 1, child: pageViewWidget),
              ],
            );
          }
        },
      ),
    );
  }
}
