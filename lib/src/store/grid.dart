import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'store.dart';
import 'package:signals/signals_flutter.dart';

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
  void generateCalendar(DateTime startDate, DateTime endDate) {
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
