import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class StatisticsRangePickerDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const StatisticsRangePickerDialog({super.key, required this.initialStartDate, required this.initialEndDate});

  @override
  State<StatisticsRangePickerDialog> createState() => _StatisticsRangePickerDialogState();
}

class _StatisticsRangePickerDialogState extends State<StatisticsRangePickerDialog> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final DateTime _firstDay = DateTime.now().subtract(const Duration(days: 180));
  final DateTime _lastDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialEndDate;
    _rangeStart = widget.initialStartDate;
    _rangeEnd = widget.initialEndDate;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      _rangeStart = start != null ? DateTime(start.year, start.month, start.day) : null;
      _rangeEnd = end != null ? DateTime(end.year, end.month, end.day) : null;
    });
  }

  void _selectPreset(int days) {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(Duration(days: days - 1));
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('기간 설정', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Presets
            Row(
              children: [
                Expanded(
                  child: _PresetButton(label: '7일', onTap: () => _selectPreset(7), isSelected: _isPresetSelected(7)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PresetButton(label: '30일', onTap: () => _selectPreset(30), isSelected: _isPresetSelected(30)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calendar
            TableCalendar(
              locale: 'ko_KR',
              firstDay: _firstDay,
              lastDay: _lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_rangeStart, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              onRangeSelected: _onRangeSelected,
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
              ),
              calendarStyle: CalendarStyle(
                rangeHighlightColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                rangeStartDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                rangeEndDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_rangeStart != null && _rangeEnd != null) {
                    Navigator.of(context).pop(DateTimeRange(start: _rangeStart!, end: _rangeEnd!));
                  } else if (_rangeStart != null) {
                    // Single day selection treated as range
                    Navigator.of(context).pop(DateTimeRange(start: _rangeStart!, end: _rangeStart!));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('적용하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPresetSelected(int days) {
    if (_rangeStart == null || _rangeEnd == null) return false;
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days - 1));
    return isSameDay(_rangeStart, start) && isSameDay(_rangeEnd, end);
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _PresetButton({required this.label, required this.onTap, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }
}
