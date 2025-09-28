import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'package:signals/signals_flutter.dart';

import 'store.dart';

/// Manages calendar grid state and month navigation for the Flicker date picker
///
/// This class handles the generation and management of calendar months,
/// providing efficient caching and navigation capabilities. It uses reactive
/// signals for state management and optimizes performance by avoiding
/// unnecessary regeneration of calendar data.
///
/// Key features:
/// - Reactive calendar month management using signals
/// - Intelligent caching to prevent unnecessary regeneration
/// - Month navigation and indexing utilities
/// - Calendar grid generation for display purposes
/// - Efficient date range management
///
/// ## Usage Examples
///
/// ### Basic calendar grid generation:
/// ```dart
/// final grid = Grid();
///
/// // Generate calendar for a specific date range
/// final startDate = DateTime(2024, 1, 1);
/// final endDate = DateTime(2024, 12, 31);
/// grid.generate(startDate, endDate);
///
/// print('Total months: ${grid.length}');
/// print('First month: ${grid.first}');
/// print('Last month: ${grid.last}');
/// print('All months: ${grid.items}');
/// ```
///
/// ### Reactive calendar updates:
/// ```dart
/// final grid = Grid();
///
/// // Listen to calendar changes
/// effect(() {
///   print('Calendar updated: ${grid.items.length} months');
///   for (final month in grid.items) {
///     print('Month: ${month.year}-${month.month}');
///   }
/// });
///
/// // Generate initial calendar
/// grid.generate(DateTime(2024, 6, 1), DateTime(2024, 8, 31));
///
/// // Extend the calendar range (will trigger the effect)
/// grid.generate(DateTime(2024, 5, 1), DateTime(2024, 9, 30));
/// ```
///
/// ### Month navigation and indexing:
/// ```dart
/// final grid = Grid();
/// grid.generate(DateTime(2024, 1, 1), DateTime(2024, 12, 31));
///
/// // Find index of a specific month
/// final targetMonth = DateTime(2024, 6, 15); // Any date in June 2024
/// final index = grid.indexOf(targetMonth);
/// print('June 2024 is at index: $index');
///
/// // Check if a month exists in the grid
/// if (grid.contains(targetMonth)) {
///   print('June 2024 is in the calendar');
/// }
///
/// // Navigate to specific months
/// final juneMonth = grid.items[index];
/// print('June month: ${juneMonth.year}-${juneMonth.month}');
/// ```
///
/// ### Integration with date picker:
/// ```dart
/// class CalendarController {
///   final Grid grid = Grid();
///   final Store store;
///
///   CalendarController(this.store) {
///     _initializeCalendar();
///     _setupReactiveUpdates();
///   }
///
///   void _initializeCalendar() {
///     // Generate calendar based on current display date
///     final displayDate = store.displayDate.value;
///     final startDate = DateTime(displayDate.year - 1, 1, 1);
///     final endDate = DateTime(displayDate.year + 1, 12, 31);
///
///     grid.generate(startDate, endDate);
///   }
///
///   void _setupReactiveUpdates() {
///     // React to display date changes
///     effect(() {
///       final displayDate = store.displayDate.value;
///       _ensureMonthInRange(displayDate);
///     });
///   }
///
///   void _ensureMonthInRange(DateTime date) {
///     if (!grid.contains(date)) {
///       // Extend calendar range to include the new date
///       final currentStart = grid.first ?? date;
///       final currentEnd = grid.last ?? date;
///
///       final newStart = DateTime(
///         math.min(currentStart.year, date.year - 1), 1, 1);
///       final newEnd = DateTime(
///         math.max(currentEnd.year, date.year + 1), 12, 31);
///
///       grid.generate(newStart, newEnd);
///     }
///   }
///
///   void navigateToMonth(DateTime month) {
///     final index = grid.indexOf(month);
///     if (index != -1) {
///       // Update store display date
///       store.displayDate.value = month;
///     }
///   }
/// }
/// ```
///
/// ### Performance optimization with caching:
/// ```dart
/// final grid = Grid();
///
/// // First generation - creates new calendar
/// final start1 = DateTime(2024, 1, 1);
/// final end1 = DateTime(2024, 6, 30);
/// grid.generate(start1, end1);
/// print('Generated ${grid.length} months');
///
/// // Same range - uses cache, no regeneration
/// grid.generate(start1, end1);
/// print('Used cache, still ${grid.length} months');
///
/// // Extended range - regenerates with new range
/// final end2 = DateTime(2024, 12, 31);
/// grid.generate(start1, end2);
/// print('Extended to ${grid.length} months');
///
/// // Completely different range - regenerates
/// final start3 = DateTime(2025, 1, 1);
/// final end3 = DateTime(2025, 12, 31);
/// grid.generate(start3, end3);
/// print('New year: ${grid.length} months');
/// ```
///
/// ### Working with calendar views:
/// ```dart
/// class MonthlyCalendarView extends StatelessWidget {
///   final Grid grid;
///   final DateTime currentMonth;
///
///   const MonthlyCalendarView({
///     Key? key,
///     required this.grid,
///     required this.currentMonth,
///   }) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Watch((context) {
///       final monthIndex = grid.indexOf(currentMonth);
///
///       if (monthIndex == -1) {
///         return const Text('Month not found in calendar');
///       }
///
///       return PageView.builder(
///         itemCount: grid.length,
///         controller: PageController(initialPage: monthIndex),
///         itemBuilder: (context, index) {
///           final month = grid.items[index];
///           return MonthWidget(month: month);
///         },
///       );
///     });
///   }
/// }
///
/// class MonthWidget extends StatelessWidget {
///   final DateTime month;
///
///   const MonthWidget({Key? key, required this.month}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         Text('${month.year}-${month.month}'),
///         // Build calendar grid for this month
///         Expanded(
///           child: GridView.builder(
///             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///               crossAxisCount: 7,
///             ),
///             itemCount: DateTime(month.year, month.month + 1, 0).day,
///             itemBuilder: (context, day) {
///               final date = DateTime(month.year, month.month, day + 1);
///               return DayCell(date: date);
///             },
///           ),
///         ),
///       ],
///     );
///   }
/// }
/// ```
class Grid {
  /// Reactive signal containing the list of calendar months
  ///
  /// This signal automatically notifies listeners when the calendar
  /// months change, enabling reactive UI updates.
  late final Signal<List<DateTime>> _items = signal([]);

  /// Gets the current list of calendar months
  List<DateTime> get items => _items.value;

  /// Gets the total number of months in the current calendar
  int get length => _items.value.length;

  /// Gets the first month in the current calendar, or null if empty
  DateTime? get first => _items.value.first;

  /// Gets the last month in the current calendar, or null if empty
  DateTime? get last => _items.value.last;

  /// Cache variables to track the last generated date range
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  /// Generates a calendar for the specified date range with caching
  ///
  /// This method creates a list of months between the start and end dates.
  /// It includes intelligent caching to avoid regenerating the same calendar
  /// when the date range hasn't changed significantly.
  ///
  /// Parameters:
  /// - [startDate]: The beginning of the date range
  /// - [endDate]: The end of the date range
  void generateCalendar(DateTime? startDate, DateTime? endDate) {
    startDate = DateHelpers.offsetToday(startDate, -3);
    endDate = DateHelpers.offsetToday(endDate, 3);

    // Check if we can reuse the existing calendar
    if (_lastStartDate != null &&
        _lastEndDate != null &&
        DateHelpers.isSameMonth(_lastStartDate, startDate) &&
        DateHelpers.isSameMonth(_lastEndDate, endDate)) {
      return; // No need to regenerate
    }

    // Generate new calendar and update cache
    _items.value = DateHelpers.generateCalendar(startDate, endDate);
    _lastStartDate = startDate;
    _lastEndDate = endDate;
  }

  /// Generates a calendar centered around a specific date
  ///
  /// Creates a calendar spanning 6 months (3 before and 3 after) around
  /// the provided center date. This is useful for creating a focused
  /// calendar view with reasonable navigation range.
  ///
  /// Parameters:
  /// - [centerDate]: The date to center the calendar around
  void fromDate(DateTime centerDate) {
    generateCalendar(
      DateTime(centerDate.year, centerDate.month - 3),
      DateTime(centerDate.year, centerDate.month + 3),
    );
  }

  /// Finds the index of a specific month in the current calendar
  ///
  /// Searches for a month that matches the provided date and returns
  /// its index in the calendar list. Uses month-level comparison,
  /// ignoring the day component.
  ///
  /// Parameters:
  /// - [date]: The date to search for (only month/year are considered)
  ///
  /// Returns:
  /// The index of the matching month, or -1 if not found
  int findIndex(DateTime? date) {
    if (date == null) return -1;
    return _items.value.indexWhere((m) => DateHelpers.isSameMonth(m, date));
  }

  /// Retrieves the month at a specific index
  ///
  /// Safely accesses a month from the calendar list at the given index.
  /// Includes bounds checking to prevent index out of range errors.
  ///
  /// Parameters:
  /// - [index]: The index of the month to retrieve
  ///
  /// Returns:
  /// The DateTime representing the month, or null if index is invalid
  DateTime? at(int index) {
    if (index < 0 || index >= _items.value.length) return null;
    return _items.value[index];
  }

  /// Generates the calendar grid cells for a specific month
  ///
  /// Creates a 2D grid structure representing the calendar layout for
  /// the given month. This includes proper positioning of dates within
  /// weeks and handles empty cells for days outside the month.
  ///
  /// Parameters:
  /// - [current]: The month to generate the grid for
  /// - [store]: The store instance containing configuration settings
  ///
  /// Returns:
  /// A 2D list where each inner list represents a week, and each
  /// element is either a DateTime (for actual days) or null (for empty cells)
  List<List<DateTime?>> generateCells(DateTime current, Store store) {
    return DateHelpers.generateGrid(
      current,
      store.firstDayOfWeek,
      store.viewCount,
    );
  }

  /// Disposes of reactive signals to prevent memory leaks
  ///
  /// This method should be called when the Grid instance is no longer needed
  /// to properly clean up signal subscriptions and prevent memory leaks.
  /// It disposes of the internal items signal.
  void dispose() => _items.dispose();
}
