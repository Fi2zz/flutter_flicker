import 'package:flutter/foundation.dart';
import 'date_helpers.dart';

typedef Selected = List<DateTime>;
typedef Disabled = bool Function(DateTime date);
typedef Sync = void Function(Selected selected);
typedef Rebuild = void Function();

/// Constants for date range validation
class _DateRangeConstants {
  /// Maximum days for detailed range checking
  static const int smallRangeThreshold = 7;

  /// Sampling interval for large ranges (days)
  static const int samplingInterval = 7;

  /// Minimum days for additional sampling
  static const int additionalSamplingThreshold = 14;

  /// Maximum dates allowed in range mode
  static const int maxRangeDates = 2;
}

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

  /// Handle single date selection mode
  Selected handleSingle(DateTime date) {
    if (_isDateDisabled(date)) return selection;
    return [date];
  }

  /// Handle multiple date selection mode
  Selected handleMany(DateTime date) {
    if (_isDateDisabled(date)) return selection;

    final newSelection = List<DateTime>.from(selection);
    return _toggleDateInSelection(newSelection, date);
  }

  /// Toggle a date in the selection list (add if not present, remove if present)
  Selected _toggleDateInSelection(
    List<DateTime> currentSelection,
    DateTime date,
  ) {
    final index = _findDateIndex(currentSelection, date);

    if (index != -1) {
      currentSelection.removeAt(index);
    } else {
      currentSelection.add(date);
    }

    return currentSelection;
  }

  /// Find the index of a date in a selection list
  int _findDateIndex(List<DateTime> dateList, DateTime date) {
    return dateList.indexWhere((d) => DateHelpers.isSameDay(d, date));
  }

  /// Handle range date selection mode
  Selected handleRange(DateTime date) {
    if (_isDateDisabled(date)) return selection;

    if (_isEmptySelection()) {
      return [date];
    } else if (_isSingleDateSelection()) {
      return _handleSecondDateInRange(date);
    } else {
      return [date]; // Reset range with new start date
    }
  }

  /// Check if a date is disabled
  bool _isDateDisabled(DateTime date) {
    return disabled!(date);
  }

  /// Check if the selection is empty
  bool _isEmptySelection() {
    return selection.isEmpty;
  }

  /// Check if the selection contains exactly one date
  bool _isSingleDateSelection() {
    return selection.length == 1;
  }

  /// Handle the second date selection in range mode
  Selected _handleSecondDateInRange(DateTime date) {
    final startDate = selection.first;

    if (DateHelpers.isSameDay(startDate, date)) {
      return [date]; // Same date selected twice, keep as single selection
    }

    return _createValidDateRange(startDate, date);
  }

  /// Create a valid date range based on two dates (ordered correctly)
  Selected _createValidDateRange(DateTime firstDate, DateTime secondDate) {
    if (secondDate.isBefore(firstDate)) {
      return _validateDateRange(secondDate, firstDate);
    } else {
      return _validateDateRange(firstDate, secondDate);
    }
  }

  void onWidgetUpdate(Selected value, FlickerSelectionMode? mode) {
    _updateMode(mode);
    if (_isSelectionUnchanged(value)) return;

    final processedSelection = _processNewSelection(value);
    update(processedSelection);
  }

  /// Check if the selection has actually changed
  bool _isSelectionUnchanged(Selected value) {
    return selection == value;
  }

  /// Process new selection value based on current mode and constraints
  Selected _processNewSelection(Selected value) {
    if (value.isEmpty) return value;

    final next = List<DateTime>.from(value);
    return _processSelectionByMode(next);
  }

  /// Update selection mode if changed
  void _updateMode(FlickerSelectionMode? mode) {
    if (this.mode != mode) {
      this.mode = mode ?? FlickerSelectionMode.single;
    }
  }

  /// Process selection based on current mode
  Selected _processSelectionByMode(Selected next) {
    switch (mode) {
      case FlickerSelectionMode.single:
        return _processSingleMode(next);
      case FlickerSelectionMode.many:
        return _processManyMode(next);
      case FlickerSelectionMode.range:
        return _processRangeMode(next);
    }
  }

  /// Process single selection mode
  Selected _processSingleMode(Selected next) {
    _removeDisabledDates(next);
    return next.isNotEmpty ? [next.last] : next;
  }

  /// Process many selection mode
  Selected _processManyMode(Selected next) {
    _removeDisabledDates(next);
    return next;
  }

  /// Process range selection mode
  Selected _processRangeMode(Selected next) {
    final limitedSelection = _limitRangeSelection(next);
    return _validateRangeSelection(limitedSelection);
  }

  /// Limit range selection to maximum allowed dates
  Selected _limitRangeSelection(Selected dates) {
    return dates.take(_DateRangeConstants.maxRangeDates).toList();
  }

  /// Validate range selection against disabled dates
  Selected _validateRangeSelection(Selected dates) {
    if (disabled == null) return dates;

    _removeDisabledDates(dates);
    if (dates.length == 2) {
      return _validateDateRange(dates.first, dates.last);
    }
    return dates;
  }

  /// Remove disabled dates from selection
  void _removeDisabledDates(Selected dates) {
    if (disabled != null) {
      dates.removeWhere((date) => disabled!(date));
    }
  }

  /// Validate date range and return valid selection
  Selected _validateDateRange(DateTime startDate, DateTime endDate) {
    final daysDifference = _calculateDaysDifference(startDate, endDate);

    if (_isSmallRange(daysDifference)) {
      return _validateSmallRange(startDate, endDate, daysDifference);
    } else {
      return _validateLargeRange(startDate, endDate, daysDifference);
    }
  }

  /// Calculate the number of days between two dates
  int _calculateDaysDifference(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  /// Check if the range is considered small for validation purposes
  bool _isSmallRange(int daysDifference) {
    return daysDifference <= _DateRangeConstants.smallRangeThreshold;
  }

  /// Validate small date range (≤7 days) by checking each day
  Selected _validateSmallRange(
    DateTime startDate,
    DateTime endDate,
    int daysDifference,
  ) {
    if (_hasDisabledDatesInRange(startDate, daysDifference)) {
      return [startDate]; // Keep only start date if disabled dates found
    }
    return [startDate, endDate]; // All dates valid
  }

  /// Check if there are any disabled dates in a small range
  bool _hasDisabledDatesInRange(DateTime startDate, int daysDifference) {
    for (int i = 1; i < daysDifference; i++) {
      final checkDate = startDate.add(Duration(days: i));
      if (disabled!(checkDate)) {
        return true;
      }
    }
    return false;
  }

  /// Validate large date range (>7 days) using sampling approach
  Selected _validateLargeRange(
    DateTime startDate,
    DateTime endDate,
    int daysDifference,
  ) {
    final sampleDates = _generateSampleDates(startDate, daysDifference);

    if (_hasDisabledDatesInSamples(sampleDates)) {
      return [startDate]; // Keep only start date if disabled dates likely exist
    }
    return [startDate, endDate]; // No disabled dates found in samples
  }

  /// Check if any of the sample dates are disabled
  bool _hasDisabledDatesInSamples(List<DateTime> sampleDates) {
    return sampleDates.any((date) => disabled!(date));
  }

  /// Generate sample dates for large range validation
  List<DateTime> _generateSampleDates(DateTime startDate, int daysDifference) {
    final sample = <DateTime>[];

    _addWeeklySamples(sample, startDate, daysDifference);
    _addAdditionalSamples(sample, startDate, daysDifference);

    return sample;
  }

  /// Add weekly interval samples to the sample list
  void _addWeeklySamples(
    List<DateTime> sample,
    DateTime startDate,
    int daysDifference,
  ) {
    for (
      int i = _DateRangeConstants.samplingInterval;
      i < daysDifference;
      i += _DateRangeConstants.samplingInterval
    ) {
      sample.add(startDate.add(Duration(days: i)));
    }
  }

  /// Add additional samples for better coverage in large ranges
  void _addAdditionalSamples(
    List<DateTime> sample,
    DateTime startDate,
    int daysDifference,
  ) {
    if (daysDifference > _DateRangeConstants.additionalSamplingThreshold) {
      sample.add(startDate.add(Duration(days: daysDifference ~/ 3)));
      sample.add(startDate.add(Duration(days: (daysDifference * 2) ~/ 3)));
    }
  }
}
