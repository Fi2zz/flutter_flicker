import 'package:flutter/widgets.dart';
import 'flicker_extensions.dart';
import 'flicker_shared.dart';
import 'flicker_scrollview.dart';

/// Year selection view component
///
/// Combines year selection view with a title header
/// Used when switching from month view to year view
class FlickerYearsView extends StatelessWidget {
  /// Current date for context
  final DateTime date;

  /// Year selection callback
  final ValueChanged<int> onTapYear;

  /// Optional callback for title tap (back to month view)
  final Function() onTapTitle;

  /// Minimum selectable year
  final int startYear;

  /// Maximum selectable year
  final int endYear;

  /// Size for the component
  final Size size;
  final double itemHeight;

  /// Creates a year selection view
  ///
  /// - [date]: Current date for context
  /// - [onTapYear]: Year selection callback
  /// - [onTapTitle]: Optional callback for title tap (back to month view)
  /// - [startYear]: Minimum selectable year
  /// - [endYear]: Maximum selectable year
  /// - [size]: Size for the component
  const FlickerYearsView({
    super.key,
    required this.date,
    required this.onTapYear,
    required this.onTapTitle,
    required this.size,
    required this.itemHeight,
    required this.startYear,
    required this.endYear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: PaginationView(
        startValue: startYear,
        endValue: endYear,
        initialValue: date.year,
        itemHeight: itemHeight,
        itemBuilder: (context, year, index) {
          return Year(
            year: year,
            selected: _selected(year),
            disabled: _disabled(year),
            onTap: (value) => onTapYear(value),
          );
        },
      ),
    );
  }

  bool _selected(int year) {
    return year == date.year;
  }

  bool _disabled(int year) {
    return year < startYear || year > endYear;
  }
}

class Year extends StatelessWidget {
  const Year({
    super.key,
    required this.year,
    required this.onTap,
    required this.disabled,
    required this.selected,
  });
  final bool selected;
  final ValueChanged<int> onTap;
  final bool disabled;
  final int year;
  @override
  Widget build(BuildContext context) {
    final theme = context.flickerTheme;
    return Tappable(
      tappable: !disabled,
      onTap: () => onTap(year),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: theme.getDayDecoration(
          selected: selected,
          disabled: disabled,
        ),
        alignment: Alignment.center,
        child: Text(
          year.toString(),
          style: theme.getDayTextStyle(selected, disabled, null),
        ),
      ),
    );
  }
}
