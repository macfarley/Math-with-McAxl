/// Calendar math utilities.
class CalendarMath {
  static const List<String> weekdayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// Number of days from [from] to [to] (positive = future, negative = past).
  static int daysBetween(DateTime from, DateTime to) {
    final f = DateTime(from.year, from.month, from.day);
    final t = DateTime(to.year, to.month, to.day);
    return t.difference(f).inDays;
  }

  /// Add [days] to [date] and return the result.
  static DateTime addDays(DateTime date, int days) => date.add(Duration(days: days));

  /// Subtract [days] from [date] and return the result.
  static DateTime subtractDays(DateTime date, int days) => date.subtract(Duration(days: days));

  /// Return the weekday name (Monday–Sunday) for [date].
  static String weekdayName(DateTime date) => weekdayNames[date.weekday - 1];

  /// Count occurrences of [weekday] (1=Mon … 7=Sun) between [start] and [end] inclusive.
  static int countWeekday(DateTime start, DateTime end, int weekday) {
    if (start.isAfter(end)) return 0;
    int count = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(last)) {
      if (current.weekday == weekday) count++;
      current = current.add(const Duration(days: 1));
    }
    return count;
  }

  /// Number of complete weeks between [from] and [to].
  static int weeksBetween(DateTime from, DateTime to) => daysBetween(from, to).abs() ~/ 7;

  /// Return the next occurrence of [weekday] (1=Mon … 7=Sun) on or after [date].
  static DateTime nextWeekday(DateTime date, int weekday) {
    DateTime d = DateTime(date.year, date.month, date.day);
    while (d.weekday != weekday) {
      d = d.add(const Duration(days: 1));
    }
    return d;
  }
}
