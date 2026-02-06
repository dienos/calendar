import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domain/entities/daily_record.dart';
import 'package:domain/entities/daily_log_record.dart';
import '../add_memo/add_memo_screen.dart';
import '../memo_list/memo_list_screen.dart';

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

    final pageViewWidget = PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        final newSelectedDay = _firstDay.add(Duration(days: index));
        if (!isSameDay(calendarState.selectedDay, newSelectedDay)) {
          ref.read(calendarViewModelProvider.notifier).onDaySelected(newSelectedDay, newSelectedDay);
        }
      },
      itemBuilder: (context, index) {
        final date = _firstDay.add(Duration(days: index));
        final records = calendarState.events[DateTime.utc(date.year, date.month, date.day)] ?? [];

        final String titleText;
        final today = DateTime.now();

        final memoRecords = records.whereType<DailyLogRecord>().toList();
        final summaryWidgets = <Widget>[];

        if (memoRecords.isNotEmpty) {
          summaryWidgets.add(
            ListTile(
              leading: const Icon(Icons.notes),
              title: Text('${memoRecords.length}개의 메모'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MemoListScreen(
                      date: date,
                      memos: memoRecords,
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
                    : ListView(
                        children: summaryWidgets,
                      ),
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
                      '${DateTime.now().day}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddMemoScreen(
                selectedDate: calendarState.selectedDay,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final calendarWidget = TableCalendar<DailyRecord>(
            locale: 'ko_KR',
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: calendarState.focusedDay,
            selectedDayPredicate: (day) => isSameDay(calendarState.selectedDay, day),
            eventLoader: (day) {
              return calendarState.events[DateTime.utc(day.year, day.month, day.day)] ?? [];
            },
            headerStyle: const HeaderStyle(titleCentered: true, formatButtonVisible: false),
            daysOfWeekHeight: 30,
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(calendarState.selectedDay, selectedDay)) {
                ref.read(calendarViewModelProvider.notifier).onDaySelected(selectedDay, focusedDay);
                final pageIndex = selectedDay.difference(_firstDay).inDays;
                _pageController.jumpToPage(pageIndex);
              }
            },
            onPageChanged: ref.read(calendarViewModelProvider.notifier).onPageChanged,
            calendarFormat: CalendarFormat.month,
            pageAnimationDuration: const Duration(milliseconds: 400),
            pageAnimationCurve: Curves.easeInOut,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      width: 6.0, height: 6.0,
                    ),
                  );
                }
                return null;
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
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: calendarWidget,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: pageViewWidget,
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
