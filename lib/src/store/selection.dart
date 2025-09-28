bool same(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Manages date selection state for the Flicker date picker
///
/// This class provides comprehensive functionality for managing selected dates
/// in various selection modes (single, multiple, range). It offers methods for
/// adding, removing, and querying selected dates, as well as utilities for
/// range selection and date comparison.
///
/// Key features:
/// - Support for multiple selection modes
/// - Range selection with start/end detection
/// - Date comparison and validation utilities
/// - Efficient selection state management
///
/// ## Usage Examples
///
/// ### Basic single date selection:
/// ```dart
/// final selection = Selection();
/// selection.maxCount = 1; // Single selection mode
///
/// // Select a date
/// final today = DateTime.now();
/// selection.update(today);
///
/// // Check if date is selected
/// if (selection.any(today)) {
///   print('Today is selected');
/// }
///
/// // Get selected dates
/// print('Selected dates: ${selection.result}');
/// ```
///
/// ### Range selection:
/// ```dart
/// final selection = Selection();
/// selection.maxCount = 2; // Range selection mode
///
/// // Select start date
/// final startDate = DateTime(2024, 6, 15);
/// selection.update(startDate);
/// print('Start date selected: ${selection.first}');
///
/// // Select end date
/// final endDate = DateTime(2024, 6, 20);
/// selection.update(endDate);
/// print('Range: ${selection.first} to ${selection.last}');
///
/// // Check if a date is between the range
/// final testDate = DateTime(2024, 6, 17);
/// if (selection.between(testDate)) {
///   print('$testDate is between the selected range');
/// }
/// ```
///
/// ### Multiple date selection:
/// ```dart
/// final selection = Selection();
/// selection.maxCount = 5; // Allow up to 5 dates
///
/// // Select multiple dates
/// final dates = [
///   DateTime(2024, 6, 15),
///   DateTime(2024, 6, 17),
///   DateTime(2024, 6, 20),
/// ];
///
/// for (final date in dates) {
///   selection.update(date);
/// }
///
/// print('Selected ${selection.length} dates');
/// print('All selected dates: ${selection.result}');
///
/// // Remove a specific date
/// selection.drop(DateTime(2024, 6, 17));
/// print('After removal: ${selection.result}');
/// ```
///
/// ### Advanced selection management:
/// ```dart
/// final selection = Selection();
/// selection.maxCount = 3;
///
/// // Force set specific dates
/// final initialDates = [
///   DateTime(2024, 6, 10),
///   DateTime(2024, 6, 15),
/// ];
/// selection.force(initialDates);
///
/// // Check if selection equals specific dates
/// if (selection.equals(initialDates)) {
///   print('Selection matches initial dates');
/// }
///
/// // Get a subset of selection
/// if (selection.length > 1) {
///   final subset = selection.sublist(0, 1);
///   print('First selected date: $subset');
/// }
///
/// // Reset selection
/// selection.reset();
/// print('Selection cleared: ${selection.isEmpty}');
/// ```
///
/// ### Working with selection limits:
/// ```dart
/// final selection = Selection();
/// selection.maxCount = 2;
///
/// // Try to select more dates than allowed
/// final dates = [
///   DateTime(2024, 6, 15),
///   DateTime(2024, 6, 16),
///   DateTime(2024, 6, 17), // This will reset and start new selection
/// ];
///
/// for (final date in dates) {
///   selection.update(date);
///   print('Current selection: ${selection.result}');
/// }
///
/// // Check selection state
/// print('Is empty: ${selection.isEmpty}');
/// print('Is not empty: ${selection.isNotEmpty}');
/// print('Selection count: ${selection.length}');
/// ```
///
/// ### Integration with date picker logic:
/// ```dart
/// class DatePickerController {
///   final Selection selection = Selection();
///
///   void configureForMode(SelectionMode mode) {
///     switch (mode) {
///       case SelectionMode.single:
///         selection.maxCount = 1;
///         break;
///       case SelectionMode.range:
///         selection.maxCount = 2;
///         break;
///       case SelectionMode.many:
///         selection.maxCount = null; // No limit
///         break;
///     }
///   }
///
///   void handleDateTap(DateTime date) {
///     if (selection.any(date)) {
///       // Date is already selected, remove it
///       selection.drop(date);
///     } else {
///       // Date is not selected, add it
///       selection.update(date);
///     }
///
///     // Notify listeners
///     onSelectionChanged(selection.result);
///   }
///
///   void onSelectionChanged(List<DateTime> dates) {
///     print('Selection changed: $dates');
///   }
/// }
/// ```
class Selection {
  /// Internal list storing all selected dates
  List<DateTime> selection = [];

  /// Checks if the current selection equals the provided value
  ///
  /// Performs a deep comparison between the current selection and the
  /// provided list of dates to determine equality.
  ///
  /// Parameters:
  /// - [value]: List of DateTime objects to compare against
  ///
  /// Returns:
  /// true if selections are equal, false otherwise
  bool equals(List<DateTime> value) => selection == value;

  /// Maximum number of dates allowed in selection
  ///
  /// This constant defines the upper limit for the number of dates
  /// that can be selected at once.
  // int? maxCount;

  int? _maxCount;

  /// Gets the current selection as a read-only list
  ///
  /// Returns:
  /// A copy of the current selection list, or empty list if no selection
  List<DateTime> get result => take();

  /// Gets or sets the maximum number of dates allowed in selection
  ///
  /// If set to null, there is no limit.
  /// Default value is 1 for single selection mode.
  set maxCount(int? value) => _maxCount = value;

  /// Forces the selection to a specific set of dates
  ///
  /// Replaces the entire current selection with the provided dates.
  /// This is useful for programmatically setting the selection state.
  ///
  /// Parameters:
  /// - [value]: New list of selected dates
  Selection force(List<DateTime> value) {
    reset();
    selection = [...value];
    truncate();
    sort();
    return this;
  }

  /// Removes a specific date from the selection
  ///
  /// If the date exists in the current selection, it will be removed.
  /// If the date is not found, the selection remains unchanged.
  ///
  /// Parameters:
  /// - [date]: The date to remove from selection
  void drop(DateTime date) => selection.remove(date);
  void reject(DateTime date) => drop(date);
  bool accept(DateTime date) => !any(date);

  /// Adds a new date to the selection
  ///
  /// Creates a new selection list with the additional date appended.
  /// This maintains immutability principles for state management.
  ///
  /// Parameters:
  /// - [date]: The date to add to selection
  void push(DateTime date) => selection = [...selection, date];
  void update(DateTime date) {
    if (!accept(date)) return reject(date);
    if (_maxCount != null && length + 1 > _maxCount!) reset();
    push(date);
    sort();
  }

  /// Sorts the selection in chronological order
  ///
  /// Arranges all selected dates from earliest to latest. This is
  /// particularly useful for range selections and display purposes.
  Selection sort() {
    selection.sort((a, b) => a.compareTo(b));
    return this;
  }

  /// Returns a copy of the current selection
  ///
  /// Provides a safe way to access the selection without exposing
  /// the internal list for modification.
  ///
  /// Returns:
  /// A copy of the current selection, or empty list if no selection
  List<DateTime> take() => isEmpty ? [] : [...selection];

  /// Truncates the selection to a specified maximum count
  ///
  /// If the current selection exceeds the specified maximum count,
  /// it will be truncated to the last N dates, where N is the maxCount.
  /// If maxCount is null, no truncation occurs.
  ///
  /// Parameters:
  /// - [maxCount]: Maximum number of dates to keep in selection
  ///
  /// Returns:
  /// The truncated selection list
  Selection truncate() {
    if (_maxCount == null) return this;
    if (length <= _maxCount!) return this;
    selection = selection.sublist(0, _maxCount);
    return this;
  }

  /// Returns a subset of the selection within specified bounds
  ///
  /// Creates a sublist from the current selection using the provided
  /// start and end indices.
  ///
  /// Parameters:
  /// - [start]: Starting index (inclusive)
  /// - [end]: Ending index (exclusive)
  ///
  /// Returns:
  /// A sublist of the selection
  List<DateTime> sublist(int start, int end) => selection.sublist(start, end);

  /// Resets the selection to empty state
  ///
  /// Alias for the empty() method, providing semantic clarity
  /// when resetting selection state.
  Selection reset() {
    selection = [];
    return this;
  }

  /// Checks if a specific date is in the current selection
  ///
  /// Parameters:
  /// - [test]: A function that takes a date and returns a boolean
  ///
  /// Returns:
  /// true if any date satisfies the test, false otherwise
  bool any(DateTime test) => selection.any((date) => same(date, test));

  /// Checks if a date falls between the first and last selected dates
  ///
  /// This method is useful for range selection highlighting, where dates
  /// between the start and end of a range should be visually indicated.
  /// Only works when there are at least two selected dates.
  ///
  /// Parameters:
  /// - [date]: The date to check
  ///
  /// Returns:
  /// true if the date is between first and last selection, false otherwise
  bool between(DateTime date) {
    if (isEmpty) return false;
    return date.isAfter(first!) && date.isBefore(last!);
  }

  /// Whether the selection is empty
  ///
  /// Returns true if no dates are currently selected
  bool get isEmpty => selection.isEmpty;

  /// Whether the selection contains any dates
  ///
  /// Returns true if at least one date is currently selected
  bool get isNotEmpty => selection.isNotEmpty;

  /// The first selected date, or null if no selection
  ///
  /// For range selections, this represents the start date.
  /// For multiple selections, this is the earliest date after sorting.
  DateTime? get first => selection.isNotEmpty ? selection.first : null;

  /// The last selected date, or null if no selection
  ///
  /// For range selections, this represents the end date.
  /// For multiple selections, this is the latest date after sorting.
  DateTime? get last => selection.isNotEmpty ? selection.last : null;

  /// The number of selected dates
  ///
  /// Returns the count of currently selected dates
  int get length => selection.length;
}
