extension DateTimeExtension on DateTime {
  /// Checks if this DateTime is after the [other] DateTime, ignoring time.
  bool isAfterDay(DateTime other) {
    final thisDate = DateTime.utc(year, month, day);
    final otherDate = DateTime.utc(other.year, other.month, other.day);
    return thisDate.isAfter(otherDate);
  }

  /// Checks if this DateTime is the same day as the [other] DateTime.
  /// This is a common utility, good to have it here as well.
  bool isSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
