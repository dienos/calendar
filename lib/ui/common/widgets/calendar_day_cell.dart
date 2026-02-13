import 'package:flutter/material.dart';

class CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final Widget circleContent;
  final bool isSelected; // This will no longer be used for styling
  final bool isToday;
  final bool isFuture;

  const CalendarDayCell({
    super.key,
    required this.dayNumber,
    required this.circleContent,
    required this.isSelected,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color getBackgroundColor() {
      if (isToday) {
        return theme.colorScheme.primary.withOpacity(0.2);
      }
      return theme.colorScheme.onSurface.withOpacity(0.05);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(shape: BoxShape.circle, border: null, color: getBackgroundColor()),
          child: Center(child: circleContent),
        ),
        const SizedBox(height: 4),
        Text(
          '$dayNumber',
          style: TextStyle(
            fontSize: 12,
            color: isFuture
                ? theme.colorScheme.onSurface.withOpacity(0.3)
                : isToday
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
