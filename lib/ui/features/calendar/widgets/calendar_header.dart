import 'package:dienos_calendar/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends ConsumerWidget {
  const CalendarHeader({super.key});

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
              style: theme.textTheme.headlineMedium!
                  .copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground),
            ),
            Text(
              DateFormat.y('ko_KR').format(calendarState.focusedDay),
              style: theme.textTheme.titleSmall!.copyWith(color: theme.colorScheme.primary),
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
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
                onPressed: () {
                  final newFocusedDay = DateTime(
                      calendarState.focusedDay.year, calendarState.focusedDay.month - 1);
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
                  borderRadius: BorderRadius.circular(12)),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                onPressed: () {
                  final newFocusedDay = DateTime(
                      calendarState.focusedDay.year, calendarState.focusedDay.month + 1);
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
