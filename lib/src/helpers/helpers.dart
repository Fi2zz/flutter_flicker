/// Comprehensive utility class for date-related operations and calculations
///
/// [DateHelpers] provides a collection of static methods for common date
/// operations used throughout the Flicker date picker. It includes caching
/// mechanisms for performance optimization and various utility functions
/// for date manipulation, comparison, and grid generation.
///
/// ## Key Features
///
/// ### Performance Optimization
/// - **Grid Caching**: Caches generated date grids to avoid recalculation
/// - **Calendar Caching**: Caches calendar ranges for improved performance
/// - **Memory Management**: Automatic cache size management to prevent memory leaks
///
/// ### Date Operations
/// - Date comparison and validation
/// - Month navigation (previous/next)
/// - Grid generation for calendar layouts
/// - Range calculations
///
/// ### Utility Functions
/// - Today's date handling
/// - Same day/month comparisons
/// - Date offset calculations
class DateHelpers {
  /// Cache for storing generated date grids to improve performance
  /// Key format: "year-month-firstDayOfWeek-viewCount"
  static final Map<String, List<List<DateTime?>>> _gridCache = {};

  /// Cache for storing generated calendar ranges
  /// Key format: "startYear-startMonth-endYear-endMonth"
  static final Map<String, List<DateTime>> _calendarCache = {};

  /// Maximum number of entries to keep in cache before cleanup
  static const int _maxCacheSize = 100;

  /// Clears all cached data to free up memory
  ///
  /// This method should be called when you want to reset the cache,
  /// typically during app lifecycle events or when memory usage is a concern.
  static void clearCache() {
    _gridCache.clear();
    _calendarCache.clear();
  }

  /// Manages cache size by removing oldest entries when limit is exceeded
  ///
  /// This internal method ensures that caches don't grow indefinitely,
  /// preventing potential memory issues in long-running applications.
  ///
  /// Parameters:
  /// - [cache]: The cache map to manage
  static void _manageCacheSize<T>(Map<String, T> cache) {
    if (cache.length > _maxCacheSize) {
      final keysToRemove = cache.keys.take(cache.length - _maxCacheSize);
      for (final key in keysToRemove) {
        cache.remove(key);
      }
    }
  }

  /// Gets today's date with time components set to zero
  ///
  /// Returns a [DateTime] object representing today's date with
  /// hour, minute, second, and millisecond set to zero for
  /// consistent date-only comparisons.
  ///
  /// Returns:
  /// A [DateTime] object representing today's date at midnight
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Returns today's date if the provided value is null, otherwise normalizes the date
  ///
  /// This method ensures that we always have a valid date to work with,
  /// defaulting to today if no date is provided. It also normalizes the
  /// time components to zero for consistent date-only operations.
  ///
  /// Parameters:
  /// - [value]: The date to normalize, or null to use today's date
  ///
  /// Returns:
  /// A normalized [DateTime] object with time components set to zero
  static DateTime maybeToday(DateTime? value) {
    if (value == null) return getToday();
    return DateTime(value.year, value.month, value.day);
  }

  /// Gets the previous month from the given date
  ///
  /// Calculates the month that comes before the provided date.
  /// Handles year transitions automatically (e.g., January -> December of previous year).
  ///
  /// Parameters:
  /// - [date]: The reference date
  ///
  /// Returns:
  /// A [DateTime] object representing the first day of the previous month
  static DateTime prevMonth(DateTime date) {
    return DateTime(date.year, date.month - 1);
  }

  /// Gets the next month from the given date
  ///
  /// Calculates the month that comes after the provided date.
  /// Handles year transitions automatically (e.g., December -> January of next year).
  ///
  /// Parameters:
  /// - [date]: The reference date
  ///
  /// Returns:
  /// A [DateTime] object representing the first day of the next month
  static DateTime nextMonth(DateTime date) {
    return DateTime(date.year, date.month + 1);
  }

  /// Gets the number of days in the month of the given date
  ///
  /// Calculates the total number of days in the month containing the
  /// provided date. Handles leap years and varying month lengths correctly.
  ///
  /// Parameters:
  /// - [date]: The date whose month's day count to determine
  ///
  /// Returns:
  /// An integer representing the number of days in the month (28-31)
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Checks if two dates are in the same month and year
  ///
  /// Compares two dates to determine if they belong to the same
  /// month and year, ignoring the day and time components.
  /// Returns false if either date is null.
  ///
  /// Parameters:
  /// - [a]: First date to compare (nullable)
  /// - [b]: Second date to compare (nullable)
  ///
  /// Returns:
  /// True if both dates are non-null and in the same month/year, false otherwise
  static bool isSameMonth(DateTime? a, DateTime? b) {
    if (a == null || b == null) {
      return false;
    }

    return a.year == b.year && a.month == b.month;
  }

  /// Checks if two dates represent the same day
  ///
  /// Compares two dates to determine if they represent the exact
  /// same day (year, month, and day), ignoring time components.
  ///
  /// Parameters:
  /// - [a]: First date to compare
  /// - [b]: Second date to compare
  ///
  /// Returns:
  /// True if both dates represent the same day, false otherwise
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if the given date is today
  ///
  /// Determines whether the provided date represents today's date
  /// by comparing it with the current date.
  ///
  /// Parameters:
  /// - [date]: The date to check
  ///
  /// Returns:
  /// True if the date is today, false otherwise
  static bool isToday(DateTime date) {
    return isSameDay(date, getToday());
  }

  /// Gets a date 100 years before the given date (or today if null)
  ///
  /// Calculates a date that is 100 years in the past from the provided
  /// date. If no date is provided, uses today's date as the reference.
  /// Useful for setting minimum date boundaries in date pickers.
  ///
  /// Parameters:
  /// - [date]: The reference date (nullable)
  ///
  /// Returns:
  /// A [DateTime] object 100 years before the reference date
  static DateTime maybe100yearsAgo(DateTime? date) {
    final today = maybeToday(date);
    return DateTime(today.year - 100, today.month, today.day);
  }

  /// Gets a date 100 years after the given date (or today if null)
  ///
  /// Calculates a date that is 100 years in the future from the provided
  /// date. If no date is provided, uses today's date as the reference.
  /// Useful for setting maximum date boundaries in date pickers.
  ///
  /// Parameters:
  /// - [date]: The reference date (nullable)
  ///
  /// Returns:
  /// A [DateTime] object 100 years after the reference date
  static DateTime maybe100yearsAfter(DateTime? date) {
    final today = maybeToday(date);
    return DateTime(today.year + 100, today.month, today.day);
  }

  /// Generates a calendar grid for the specified date range with caching
  ///
  /// Creates a 2D grid structure representing calendar months, where each
  /// inner list represents a week and contains DateTime objects for days
  /// or null for empty cells. The grid is optimized with caching for
  /// improved performance on repeated calls.
  ///
  /// Parameters:
  /// - [date]: The starting date for grid generation
  /// - [firstDayOfWeek]: First day of week (0=Sunday, 1=Monday, ..., 6=Saturday)
  /// - [viewCount]: Number of months to include in the grid
  ///
  /// Returns:
  /// A list of lists where each inner list represents a week,
  /// containing DateTime objects for actual days and null for empty cells
  ///
  /// Throws:
  /// AssertionError if firstDayOfWeek is not between 0 and 6
  ///
  /// Example:
  /// ```dart
  /// // Generate grid for 2 months starting from January 2024, week starts on Monday
  /// var grid = DateHelpers.generateGrid(DateTime(2024, 1), 1, 2);
  /// ```
  static List<List<DateTime?>> generateGrid(
    DateTime date,
    int firstDayOfWeek,
    int viewCount,
  ) {
    assert(
      firstDayOfWeek >= 0 && firstDayOfWeek <= 6,
      'firstDayOfWeek must be between 0 and 6',
    );

    // Create cache key for this specific grid configuration
    final cacheKey = '${date.year}-${date.month}-$firstDayOfWeek-$viewCount';

    // Return cached result if available
    if (_gridCache.containsKey(cacheKey)) {
      return _gridCache[cacheKey]!;
    }

    // Generate new grid and cache it
    final result = _generateGrid(date, firstDayOfWeek, viewCount);
    _gridCache[cacheKey] = result;

    // Manage cache size to prevent memory issues
    _manageCacheSize(_gridCache);

    return result;
  }

  /// Offsets today's date by the specified number of months
  ///
  /// If a date is provided, returns it unchanged. Otherwise, calculates
  /// a new date by adding the specified month offset to today's date.
  /// Useful for setting default dates relative to the current date.
  ///
  /// Parameters:
  /// - [date]: The date to return if not null
  /// - [offset]: Number of months to offset from today (can be negative)
  ///
  /// Returns:
  /// The provided date if not null, otherwise today's date plus the offset
  ///
  /// Example:
  /// ```dart
  /// // Get date 3 months from today
  /// DateTime futureDate = DateHelpers.offsetToday(null, 3);
  ///
  /// // Return existing date unchanged
  /// DateTime existingDate = DateHelpers.offsetToday(DateTime(2024, 6, 15), 3);
  /// // Returns DateTime(2024, 6, 15)
  /// ```
  static DateTime offsetToday(DateTime? date, int offset) {
    if (date != null) return date;
    date = maybeToday(date);
    return DateTime(date.year, date.month + offset, date.day);
  }

  /// Internal method to generate the actual calendar grid structure
  ///
  /// This private method performs the core logic for creating a calendar grid.
  /// It calculates the proper positioning of dates within weeks, handling
  /// empty cells before and after the actual month days based on the
  /// specified first day of week.
  ///
  /// Parameters:
  /// - [date]: Starting date for grid generation
  /// - [firstDayOfWeek]: First day of week configuration
  /// - [viewCount]: Number of months to generate
  ///
  /// Returns:
  /// A 2D list structure representing the calendar grid
  static List<List<DateTime?>> _generateGrid(
    DateTime date,
    int firstDayOfWeek,
    int viewCount,
  ) {
    return List.generate(viewCount, (index) {
      // Calculate year and month for current iteration
      int year = date.year;
      int month = date.month + index;

      // Get first and last day of the month
      final first = DateTime(year, month, 1);
      final last = DateTime(year, month + 1, 0);

      // Calculate empty cells before the first day
      final daysBefore = (first.weekday - firstDayOfWeek + 7) % 7;

      // Calculate empty cells after the last day
      final daysAfter = (firstDayOfWeek + 6 - last.weekday + 7) % 7;

      // Generate all actual days in the month
      List<DateTime?> dates = List.generate(last.day, (i) {
        return DateTime(year, month, first.day + i);
      });

      // Create empty cells for days before the month starts
      final left = List.generate(daysBefore, (_) => null);

      // Create empty cells for days after the month ends
      final right = List.generate(daysAfter, (_) => null);

      // Combine all parts: empty cells + actual dates + empty cells
      return [...left, ...dates, ...right];
    });
  }

  /// Generates a list of months within the specified date range with caching
  ///
  /// Creates a chronological list of DateTime objects representing the first
  /// day of each month within the given range. This is useful for creating
  /// month navigation lists and calendar overviews.
  ///
  /// Parameters:
  /// - [start]: Starting date of the range
  /// - [end]: Ending date of the range
  ///
  /// Returns:
  /// A list of DateTime objects representing the first day of each month
  /// in the specified range
  ///
  /// Example:
  /// ```dart
  /// // Get all months from January 2024 to June 2024
  /// var months = DateHelpers.generateCalendar(
  ///   DateTime(2024, 1),
  ///   DateTime(2024, 6)
  /// );
  /// // Returns [DateTime(2024, 1, 1), DateTime(2024, 2, 1), ...]
  /// ```
  static List<DateTime> generateCalendar(DateTime start, DateTime end) {
    // Create cache key for this date range
    final cacheKey = '${start.year}-${start.month}-${end.year}-${end.month}';

    // Return cached result if available
    if (_calendarCache.containsKey(cacheKey)) {
      return _calendarCache[cacheKey]!;
    }

    // Generate new calendar and cache it
    final result = _buildRangeCalendar(start, end);
    _calendarCache[cacheKey] = result;

    // Manage cache size to prevent memory issues
    _manageCacheSize(_calendarCache);

    return result;
  }

  /// Internal method to build a calendar range without caching
  ///
  /// This private method performs the actual work of generating a list
  /// of months between two dates. It iterates through years and months
  /// to create a comprehensive list of DateTime objects.
  ///
  /// Parameters:
  /// - [start]: Starting date of the range
  /// - [end]: Ending date of the range
  ///
  /// Returns:
  /// A list of DateTime objects for each month in the range
  static List<DateTime> _buildRangeCalendar(DateTime start, DateTime end) {
    final months = <DateTime>[];

    // Iterate through each year in the range
    for (var year = start.year; year <= end.year; year++) {
      // Determine month boundaries for current year
      final monthStart = year == start.year ? start.month : 1;
      final monthEnd = year == end.year ? end.month : 12;

      // Add each month in the current year to the list
      for (var month = monthStart; month <= monthEnd; month++) {
        months.add(DateTime(year, month));
      }
    }
    return months;
  }

  static bool before(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.isBefore(b);
  }
  static bool after(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.isAfter(b);
  }
}
