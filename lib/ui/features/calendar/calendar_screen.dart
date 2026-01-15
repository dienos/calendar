import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../src/models/event.dart';
import 'calendar_view_model.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calendarViewModelProvider);
    final viewModel = ref.read(calendarViewModelProvider.notifier);
    final selectedEvents = viewModel.getEventsForDay(state.selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 Flutter 캘린더'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(context, viewModel);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: state.focusedDay,
            selectedDayPredicate: (day) => isSameDay(state.selectedDay, day),
            onDaySelected: viewModel.onDaySelected,
            onPageChanged: viewModel.onPageChanged,
            eventLoader: viewModel.getEventsForDay,
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      width: 6.0,
                      height: 6.0,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'UPCOMING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(selectedEvents[index].title),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, CalendarViewModel viewModel) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이벤트 추가'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: '이벤트 내용을 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  viewModel.addEvent(Event(textController.text));
                }
                Navigator.of(context).pop();
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }
}
