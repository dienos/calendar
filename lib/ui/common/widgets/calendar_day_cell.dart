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
      // The styling now ONLY depends on whether it's today or a future date.
      // The isSelected flag is completely ignored.
      if (isToday) {
        return theme.colorScheme.primary.withOpacity(0.2);
      }
      if (isFuture) {
        return Colors.grey.shade100;
      }
      return Colors.grey.shade200;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // The border is always null. No change on click.
            border: null, 
            // The background color no longer changes on click.
            color: getBackgroundColor(), 
          ),
          child: Center(child: circleContent),
        ),
        const SizedBox(height: 4),
        Text(
          '$dayNumber',
          style: TextStyle(
            fontSize: 12,
            color: isFuture
                ? Colors.grey.shade400
                : isToday
                    ? theme.colorScheme.primary
                    : Colors.black87,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
