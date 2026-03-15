/// Time math utilities: add/subtract durations, format durations, etc.
class TimeMath {
  /// Add [hours], [minutes], [seconds] to a [DateTime] and return the result.
  static DateTime addDuration(DateTime base, {int hours = 0, int minutes = 0, int seconds = 0}) {
    return base.add(Duration(hours: hours, minutes: minutes, seconds: seconds));
  }

  /// Subtract [hours], [minutes], [seconds] from a [DateTime].
  static DateTime subtractDuration(DateTime base, {int hours = 0, int minutes = 0, int seconds = 0}) {
    return base.subtract(Duration(hours: hours, minutes: minutes, seconds: seconds));
  }

  /// Return the absolute difference between two DateTimes as a Duration.
  static Duration difference(DateTime a, DateTime b) => a.difference(b).abs();

  /// Format a Duration as "Xh Ym Zs".
  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final parts = <String>[];
    if (h > 0) parts.add('${h}h');
    if (m > 0) parts.add('${m}m');
    if (s > 0 || parts.isEmpty) parts.add('${s}s');
    return parts.join(' ');
  }

  /// Convert total minutes to hours and minutes.
  static (int hours, int minutes) minutesToHoursMinutes(int totalMinutes) {
    return (totalMinutes ~/ 60, totalMinutes.remainder(60));
  }

  /// Parse a time string "HH:MM" into hours and minutes.
  static (int hours, int minutes) parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) throw FormatException('Invalid time format: $time');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Add two time strings "HH:MM" and return result as "HH:MM".
  static String addTimes(String t1, String t2) {
    final (h1, m1) = parseTime(t1);
    final (h2, m2) = parseTime(t2);
    final totalMinutes = h1 * 60 + m1 + h2 * 60 + m2;
    final h = totalMinutes ~/ 60;
    final m = totalMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
