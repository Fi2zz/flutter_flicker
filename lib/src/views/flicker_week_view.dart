import 'package:flutter/material.dart';
import 'flicker_extensions.dart';
import 'flicker_size_helper.dart';

/// Week day header widget
///
/// Displays the days of the week (Mon, Tue, etc.) as column headers
/// Supports different first day of week configurations
class FlickerWeekView extends StatelessWidget {
  /// First day of week configuration
  final FirstDayOfWeek firstDayOfWeek;

  const FlickerWeekView({super.key, required this.firstDayOfWeek});

  @override
  Widget build(BuildContext context) {
    final theme = context.flickerTheme;
    List<String> data = getWeekNames(context);
    List<Widget> children = data
        .map((date) => Center(child: Text(date, style: theme.weekDayTextStyle)))
        .toList();

    Widget child = GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      childAspectRatio: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 0,
      children: children,
    );

    return BaseBox(child: child);
  }

  /// Gets localized week day names based on first day setting
  List<String> getWeekNames(BuildContext context) {
    int firstDay = context.getFirstDayOfWeek(firstDayOfWeek);
    final l10n = context.flickerL10n;
    final names = l10n.weekdayNames;
    // Reorder based on custom first day
    if (firstDay == 0) return names;
    return [...names.sublist(firstDay), ...names.sublist(0, firstDay)];
  }

  static Widget count({
    required Axis direction,
    required int viewCount,
    required FirstDayOfWeek firstDayOfWeek,
  }) {
    Widget week = FlickerWeekView(firstDayOfWeek: firstDayOfWeek);
    if (viewCount == 2 && direction == Axis.horizontal) {
      return Row(children: [week, week]);
    }

    return week;
  }
}
