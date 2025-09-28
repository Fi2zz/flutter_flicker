/// Defines the first day of the week for calendar display
///
/// This enum provides options for configuring which day should appear
/// as the first column in the calendar grid.
enum FirstDayOfWeek {
  /// Sunday as the first day of the week
  sunday,

  /// Monday as the first day of the week
  monday,

  /// Saturday as the first day of the week
  saturday,

  /// Use the locale's default first day of the week
  locale,
}

/// Defines the current view type of the calendar
///
/// This enum determines whether the calendar is showing a detailed
/// month view with individual days or a year overview for navigation.
enum ViewType {
  /// Detailed month view showing individual days
  month,

  /// Year overview for quick navigation between months
  year,
}

/// Defines the selection behavior of the date picker
///
/// This enum controls how users can select dates and how many
/// dates can be selected simultaneously.
enum SelectionMode {
  /// Allow selection of only one date at a time
  single,

  /// Allow selection of a date range (start and end date)
  range,

  /// Allow selection of multiple individual dates
  many,
}

/// Tracks the source of selection changes for proper event handling
///
/// This enum helps distinguish between different types of changes
/// to ensure appropriate responses and state updates.
enum ChangeSource {
  /// Change triggered by year selection in year view
  selectYear,

  /// Change triggered by date selection in month view
  selectDate,

  /// Change triggered during initial setup/configuration
  initialize,
}
