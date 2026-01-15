import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:domain/entities/event.dart';
import 'calendar_view_model.dart';

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
    final calendarViewModel = ref.read(calendarViewModelProvider.notifier);

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
          // 3. '오늘' 버튼을 AppBar 오른쪽에 추가합니다.
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _onTodayButtonPressed,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text('오늘: ${DateTime.now().day}일'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => calendarViewModel.addEvent(const Event('새로운 메모')),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            locale: 'ko_KR',
            firstDay: _firstDay,
            lastDay: _lastDay,
            focusedDay: calendarState.focusedDay,
            selectedDayPredicate: (day) => isSameDay(calendarState.selectedDay, day),
            eventLoader: calendarViewModel.getEventsForDay,
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
                calendarViewModel.onDaySelected(selectedDay, focusedDay);
                final pageIndex = selectedDay.difference(_firstDay).inDays;
                _pageController.jumpToPage(pageIndex);
              }
            },
            onPageChanged: calendarViewModel.onPageChanged,
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
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                final newSelectedDay = _firstDay.add(Duration(days: index));
                if (!isSameDay(calendarState.selectedDay, newSelectedDay)) {
                  calendarViewModel.onDaySelected(newSelectedDay, newSelectedDay);
                }
              },
              itemBuilder: (context, index) {
                final date = _firstDay.add(Duration(days: index));
                final events = calendarViewModel.getEventsForDay(date);
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.month}월 ${date.day}일 기록',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: events.isEmpty
                            ? const Center(child: Text('작성된 기록이 없습니다.'))
                            : ListView.builder(
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final event = events[index];
                                  return ListTile(
                                    leading: const Icon(Icons.circle, size: 12),
                                    title: Text(event.title),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: _lastDay.difference(_firstDay).inDays + 1,
            ),
          ),
        ],
      ),
    );
  }
}
