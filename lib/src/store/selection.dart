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

  /// Forces the selection to a specific set of dates
  ///
  /// Replaces the entire current selection with the provided dates.
  /// This is useful for programmatically setting the selection state.
  ///
  /// Parameters:
  /// - [value]: New list of selected dates
  void force(List<DateTime> value) => selection = value;

  /// Removes a specific date from the selection
  ///
  /// If the date exists in the current selection, it will be removed.
  /// If the date is not found, the selection remains unchanged.
  ///
  /// Parameters:
  /// - [date]: The date to remove from selection
  void drop(DateTime date) => selection.remove(date);

  /// Adds a new date to the selection
  ///
  /// Creates a new selection list with the additional date appended.
  /// This maintains immutability principles for state management.
  ///
  /// Parameters:
  /// - [date]: The date to add to selection
  void push(DateTime date) => selection = [...selection, date];

  /// Sorts the selection in chronological order
  ///
  /// Arranges all selected dates from earliest to latest. This is
  /// particularly useful for range selections and display purposes.
  void sort() => selection.sort((a, b) => a.compareTo(b));

  /// Returns a copy of the current selection
  ///
  /// Provides a safe way to access the selection without exposing
  /// the internal list for modification.
  ///
  /// Returns:
  /// A copy of the current selection, or empty list if no selection
  List<DateTime> take() => isEmpty ? [] : selection;

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
  void reset() => selection = [];

  /// Checks if a specific date is in the current selection
  ///
  /// Parameters:
  /// - [test]: A function that takes a date and returns a boolean
  ///
  /// Returns:
  /// true if any date satisfies the test, false otherwise
  bool any(bool Function(DateTime date) test) => selection.any(test);

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
