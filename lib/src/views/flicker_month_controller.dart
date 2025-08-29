import 'package:flutter/foundation.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';

typedef Selected = List<DateTime>;

enum FlickerSelectionMode {
  /// Single date selection - user can select only one date
  single,

  /// Date range selection - user can select a start and end date
  range,

  /// Multiple date selection - user can select multiple individual dates
  many,
}

/// Unified controller for Flicker month view
///
/// Combines date selection logic and grid generation functionality
/// into a single cohesive controller class.
class FlickerMonthController {
  // ========================================
  // Selection Related Fields
  // ========================================

  final ValueChanged<Selected> sync;
  final bool Function(DateTime)? disabled;
  final VoidCallback? rebuild;
  late FlickerSelectionMode mode = FlickerSelectionMode.single;
  late Selected selection = [];

  // ========================================
  // Grid Generation Fields
  // ========================================

  /// Date grid data
  late List<DateTime> _grid;

  /// Last start date used for generation (for caching optimization)
  DateTime? _lastStartDate;

  /// Last end date used for generation (for caching optimization)
  DateTime? _lastEndDate;

  // ========================================
  // Constructor
  // ========================================

  FlickerMonthController({
    required this.sync,
    required this.disabled,
    this.rebuild,
  });

  // ========================================
  // Grid Generation Methods
  // ========================================

  /// Get the date grid
  List<DateTime> get grid => _grid;

  /// Generate date grid (internal method)
  ///
  /// Uses guard pattern to avoid regenerating identical grids:
  /// - If start and end dates are the same as last time, skip generation
  /// - Otherwise call DateHelpers.generateCalendar to generate new grid
  ///
  /// [startDate] Grid start date
  /// [endDate] Grid end date
  void _generate(DateTime startDate, DateTime endDate) {
    // Guard: skip generation if parameters haven't changed
    if (_lastStartDate != null &&
        _lastEndDate != null &&
        DateHelpers.isSameMonth(_lastStartDate!, startDate) &&
        DateHelpers.isSameMonth(_lastEndDate!, endDate)) {
      return;
    }

    // Generate new grid and update cache
    _grid = DateHelpers.generateCalendar(startDate, endDate);
    _lastStartDate = startDate;
    _lastEndDate = endDate;
  }

  /// Generate grid based on optional start and end dates
  ///
  /// Supports four generation modes:
  /// 1. Both start and end dates provided: use specified range
  /// 2. Only start date provided: 6 months forward from start date
  /// 3. Only end date provided: 6 months backward from end date
  /// 4. Neither provided: centered around current month, 6 months each direction
  ///
  /// [startDate] Optional start date
  /// [endDate] Optional end date
  void generate({DateTime? startDate, DateTime? endDate}) {
    final DateTime start;
    final DateTime end;

    switch ((startDate != null, endDate != null)) {
      case (true, true):
        // Both dates provided
        start = startDate!;
        end = endDate!;
        break;
      case (true, false):
        // Only start date provided
        start = startDate!;
        end = DateTime(startDate.year, startDate.month + 6);
        break;
      case (false, true):
        // Only end date provided
        start = DateTime(endDate!.year, endDate.month - 6);
        end = endDate;
        break;
      case (false, false):
        // Neither provided, use default range
        final now = DateTime.now();
        start = DateTime(now.year, now.month - 6);
        end = DateTime(now.year, now.month + 6);
        break;
    }

    _generate(start, end);
  }

  /// Regenerate grid centered around the specified date
  ///
  /// Generates a grid centered around [centerDate], 6 months in each direction
  ///
  /// [centerDate] Center date
  void from(DateTime centerDate) {
    _generate(
      DateTime(centerDate.year, centerDate.month - 6),
      DateTime(centerDate.year, centerDate.month + 6),
    );
  }

  // ========================================
  // Grid Query Methods
  // ========================================

  /// Find the index of the specified date in the grid
  ///
  /// [date] Date to search for, can be null
  ///
  /// Returns:
  /// - Index when found
  /// - -1 when not found or date is null
  int findIndex(DateTime? date) {
    if (date == null) return -1;
    return _grid.indexWhere((m) => DateHelpers.isSameMonth(m, date));
  }

  /// Get date by index
  ///
  /// [index] Grid index
  ///
  /// Returns:
  /// - Corresponding DateTime when index is valid
  /// - null when index is invalid
  DateTime? at(int index) {
    if (index < 0 || index >= _grid.length) return null;
    return _grid[index];
  }

  /// Check if the specified date exists in the grid
  ///
  /// [date] Date to check
  ///
  /// Returns:
  /// - true: date exists in the grid
  /// - false: date does not exist in the grid
  bool has(DateTime date) {
    return _grid.any((gridDate) => DateHelpers.isSameMonth(gridDate, date));
  }

  // ========================================
  // Selection Logic Methods
  // ========================================


  bool isToday(DateTime date) {
    return DateHelpers.isToday(date);
  }

  /// Checks if a date falls within a selected range
  ///
  /// [date] - The date to check
  /// Returns true if date is between the first and last selected dates
  bool inRange(DateTime date, [String? type]) {
    if (selection.isEmpty || mode != FlickerSelectionMode.range) return false;
    final start = selection.first;
    final end = selection.last;
    if (type == 'start') return DateHelpers.isSameDay(date, start);
    if (type == 'end') return DateHelpers.isSameDay(date, end);
    return date.isAfter(start) && date.isBefore(end);
  }

  /// Checks if a date is currently selected
  ///
  /// [date] - The date to check
  /// Returns true if this date is in the selected dates list
  bool isContained(DateTime date) {
    if (selection.isEmpty) return false;
    return selection.any((d) => DateHelpers.isSameDay(d, date));
  }

  void update(Selected selected) {
    if (selection == selected) return;
    selection = selected;
  }

  void change(DateTime date) {
    switch (mode) {
      case FlickerSelectionMode.single:
        handleSingle(date);
        break;
      case FlickerSelectionMode.many:
        handleMany(date);
        break;
      case FlickerSelectionMode.range:
        handleRange(date);
        break;
    }

    sync(selection);
    rebuild?.call();
  }

  bool get isEmpty => selection.isEmpty;

  DateTime? get first {
    if (selection.isEmpty) return null;
    return selection.first;
  }

  DateTime? get last {
    if (selection.isEmpty) return null;
    return selection.last;
  }

  void handleSingle(DateTime date) {
    if (isContained(date)) {
      selection = [];
    } else {
      selection = [date];
    }
  }

  void handleMany(DateTime date) {
    if (isContained(date)) {
      selection.remove(date);
    } else {
      selection.add(date);
    }
    if (selection.length > 1) selection.sort((a, b) => a.compareTo(b));
  }

  void handleRange(DateTime date) {
    if (selection.length >= 2) selection = [];
    if (isContained(date)) {
      selection.remove(date);
    } else {
      selection.add(date);
    }
    if (selection.length == 2) selection.sort((a, b) => a.compareTo(b));
  }

  void onWidgetUpdate(Selected value, FlickerSelectionMode? mode) {
    if (this.mode != mode) this.mode = mode ?? FlickerSelectionMode.single;
    if (selection == value) return;
    // Selected next = selection;
    Selected next = List.from(value);
    if (next.isEmpty) {
      selection = next;
      return;
    }
    switch (this.mode) {
      case FlickerSelectionMode.single:
        if (disabled != null) {
          next.removeWhere((element) => disabled!(element));
        }
        if (next.isNotEmpty) {
          next = [next.last];
        }
        update(next);
        break;
      case FlickerSelectionMode.many:
        if (disabled != null) {
          next.removeWhere((element) => disabled!(element));
        }
        update(next);
        break;

      case FlickerSelectionMode.range:
        next = next.take(2).toList();
        if (disabled != null) {
          // Limit to maximum 2 dates for range mode
          next = next..removeWhere((date) => disabled!(date));
          // If we have exactly 2 dates, validate the range
          if (next.length == 2) {
            final startDate = next.first;
            final endDate = next.last;
            // For small ranges (≤7 days), check each day individually
            final daysDifference = endDate.difference(startDate).inDays;
            if (daysDifference <= 7) {
              bool hasDisabledDate = false;
              for (int i = 1; i < daysDifference; i++) {
                final checkDate = startDate.add(Duration(days: i));
                if (disabled!(checkDate)) {
                  hasDisabledDate = true;
                  break;
                }
              }
              // If disabled dates found in small range, keep only start date
              if (hasDisabledDate) {
                next = [startDate];
              }
            } else {
              // For larger ranges, use sampling approach for better performance
              // Check every 7th day and a few random days in between
              bool hasDisabledDate = false;
              final sample = <DateTime>[];
              // Add weekly samples
              for (int i = 7; i < daysDifference; i += 7) {
                sample.add(startDate.add(Duration(days: i)));
              }

              // Add a few random samples for better coverage
              if (daysDifference > 14) {
                sample.add(startDate.add(Duration(days: daysDifference ~/ 3)));
                sample.add(
                  startDate.add(Duration(days: (daysDifference * 2) ~/ 3)),
                );
              }

              // Check samples
              for (final sampleDate in sample) {
                if (disabled!(sampleDate)) {
                  hasDisabledDate = true;
                  break;
                }
              }
              // If disabled dates likely exist, keep only start date
              if (hasDisabledDate) {
                next = [startDate];
              }
            }
          }
        }
        update(next);
        break;
    }
  }
}