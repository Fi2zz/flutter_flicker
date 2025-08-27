import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/utils/constants.dart';
import 'package:flutter_flicker/src/views/flicker_date_title.dart';
import 'package:flutter_flicker/src/views/flicker_swipable_years_view.dart';

/// Year selection view wrapper
///
/// Combines year selection view with a title header
/// Used when switching from month view to year view
class FlickerYearsView extends StatelessWidget {
  /// Current date for context
  final DateTime date;

  /// Callback when a year is selected
  final Function(int) onSelect;

  /// Optional callback for title tap (back to month view)
  final Function()? onTapTitle;

  const FlickerYearsView({
    super.key,
    required this.onTapTitle,
    required this.date,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    Widget header = SizedBox.fromSize(
      size: fixedSize,
      child: FlickerDateTitle(date: date, onTap: onTapTitle, roate: true),
    );
    Widget body = SizedBox.fromSize(
      size: yearSize,
      child: FlickerSwipableYearsView(
        onSelect: (year) => onSelect(year),
        value: date.year,
      ),
    );
    return Column(children: [header, body]);
  }
}
