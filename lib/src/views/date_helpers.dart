/// Date utility class providing comprehensive date calculation and validation functionality
class DateHelpers {
  /// Gets today's date with time set to 00:00:00
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns specified date or today if null, with time set to 00:00:00
  static DateTime maybeToday(DateTime? value) {
    if (value == null) return getToday();
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime prevMonth(DateTime date) {
    return DateTime(date.year, date.month - 1);
  }

  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1);
  }

  static DateTime calcMonth(DateTime date, int step) {
    return DateTime(date.year, date.month + step);
  }

  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Checks if two dates are in the same month
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  static bool isDayInMonth(DateTime date, int day) {
    return day >= 1 && day <= getDaysInMonth(date);
  }

  /// Checks if two dates represent the same calendar day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Calculates a date 6 months in the future or past
  ///
  /// [date] - Starting date (uses today if null)
  /// [step] - Direction multiplier (1 = 6 months future, -1 = 6 months past)
  /// Returns the calculated date
  static DateTime maybe6monthFromNow(DateTime? date, int step) {
    final today = maybeToday(date);
    step *= 6;
    return DateTime(today.year, today.month + step, today.day);
  }

  /// Generates calendar grid data for display
  ///
  /// Creates a 2D array representing calendar weeks with proper padding
  /// to ensure weeks start on the specified first day of week
  ///
  /// [date] - The reference date (usually first day of month)
  /// [firstDayOfWeek] - The day that should appear as first column (0=Monday, 6=Sunday)
  /// [viewCount] - Number of months to generate (for multi-month view)
  static List<List<DateTime?>> generateGrid(
    DateTime date,
    int firstDayOfWeek,
    int viewCount,
  ) {
    assert(
      firstDayOfWeek >= 0 && firstDayOfWeek <= 6,
      'firstDayOfWeek must be between 0 and 6',
    );
    return List.generate(viewCount, (index) {
      int year = date.year;
      int month = date.month + index;
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);
      final daysBefore = (first.weekday - firstDayOfWeek + 7) % 7;
      final daysAfter = (firstDayOfWeek + 6 - last.weekday + 7) % 7;
      List<DateTime?> dates = List.generate(last.day, (i) {
        return DateTime(year, month, first.day + i);
      });

      final left = List.generate(daysBefore, (_) => null);
      final right = List.generate(daysAfter, (_) => null);
      return [...left, ...dates, ...right];
    });
  }

  /// Generates calendar data
  ///
  /// Generates all months within the date range from [start] to [end]
  static List<DateTime> generateCalendar(DateTime start, DateTime end) {
    final months = <DateTime>[];
    for (var year = start.year; year <= end.year; year++) {
      final monthStart = year == start.year ? start.month : 1;
      final monthEnd = year == end.year ? end.month : 12;
      for (var month = monthStart; month <= monthEnd; month++) {
        months.add(DateTime(year, month));
      }
    }
    return months;
    // return generateMonths(from, to);
  }
}
