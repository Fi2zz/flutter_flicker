import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';
import 'package:flutter_flicker/src/views/flicker.dart';
import 'package:flutter_flicker/src/views/flicker_size_helper.dart';

/// FlickerController class to manage view state
///
/// This controller manages the internal state of the Flicker date picker,
/// including the current view type and display date.
class FlickerController extends ChangeNotifier {
  ViewType _viewType = ViewType.month;
  DateTime _display = DateHelpers.maybeToday(null);
  DateTime? _startDate;
  DateTime? _endDate;
  int _viewCount = 1;
  Axis _scrollDirection = Axis.horizontal;

  /// Current view type
  ViewType get viewType => _viewType;

  /// Current display date
  DateTime get display => _display;

  /// Minimum selectable date
  DateTime? get startDate => _startDate;

  /// Maximum selectable date
  DateTime? get endDate => _endDate;

  Size get size => computeSize(viewCount, scrollDirection);

  /// Initialize controller with date range
  void initialize({
    DateTime? startDate,
    DateTime? endDate,
    int? viewCount,
    Axis? scrollDirection,
  }) {
    _startDate = startDate;
    _endDate = endDate;
    _viewCount = _normalizeViewCount(viewCount, scrollDirection);
    _scrollDirection = scrollDirection ?? Axis.horizontal;
  }

  /// Start year for year selection view
  int get startYear {
    int start = DateHelpers.maybe100yearsAgo(_startDate).year;
    return (endYear - start == 1) ? start - 1 : start;
  }

  /// End year for year selection view
  int get endYear {
    return DateHelpers.maybe100yearsAfter(_endDate).year;
  }

  /// Get view count
  int get viewCount => _viewCount;

  /// Get scroll direction
  Axis get scrollDirection => _scrollDirection;

  /// Normalize viewCount based on scrollDirection
  static int _normalizeViewCount(int? viewCount, Axis? scrollDirection) {
    // If scrollDirection is vertical, viewCount must be 2
    if (scrollDirection == Axis.vertical) {
      return 2;
    }
    // If viewCount is not 1 or 2, convert to 1
    if (viewCount != 1 && viewCount != 2) {
      return 1;
    }
    return viewCount ?? 1;
  }

  /// Show month view
  void showMonthView() {
    _viewType = ViewType.month;
    notifyListeners();
  }

  /// Show year view with specified date
  void showYearView(DateTime date) {
    _display = date;
    _viewType = ViewType.year;
    notifyListeners();
  }

  /// Select a year and return to month view
  void selectYear(int year) {
    _display = _display.copyWith(year: year);
    _viewType = ViewType.month;
    notifyListeners();
  }

  /// Update display date
  void updateDisplay(DateTime date) {
    _display = date;
    notifyListeners();
  }
}
