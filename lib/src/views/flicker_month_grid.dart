import 'package:flutter/material.dart';
import 'flicker_month_controller.dart';
import 'flicker_day_cell.dart';
import 'flicker_size_helper.dart';

/// Custom day cell builder type definition
typedef FlickerDayBuilder =
    Widget Function(
      int index,
      DateTime? date, {
      bool? selected,
      bool? disabled,
      bool? isInRange,
      bool? isRangeStart,
      bool? isRangeEnd,
      bool? isToday,
    });

/// Flicker month grid component
///
/// Responsible for rendering the month's date grid, including layout and state management of date cells
class FlickerMonthGrid extends StatelessWidget {
  /// Grid data (date list)
  final List<DateTime?> gridData;

  /// Month controller
  final FlickerMonthController controller;

  /// Disabled date callback
  final bool Function(DateTime)? disabledDate;

  /// Custom day builder
  final FlickerDayBuilder? dayBuilder;

  const FlickerMonthGrid({
    super.key,
    required this.gridData,
    required this.controller,
    this.disabledDate,
    this.dayBuilder,
  });

  /// Build day cell
  Widget _buildDayCell(int index) {
    final date = gridData[index];

    // Handle empty cells
    if (date == null) {
      return FlickerDayCell(
        date: null,
        index: index,
        customBuilder: dayBuilder,
      );
    }

    // Get date state
    final selected = controller.isContained(date);
    final isRangeStart = controller.inRange(date, 'start');
    final isRangeEnd = controller.inRange(date, 'end');
    final isInRange = controller.inRange(date, 'default');
    final isDisabled = disabledDate?.call(date) == true;
    final isToday = controller.isToday(date);

    return FlickerDayCell(
      date: date,
      index: index,
      selected: selected,
      disabled: isDisabled,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
      isToday: isToday,
      onTap: isDisabled ? null : () => controller.change(date),
      customBuilder: dayBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cells = List<Widget>.generate(
      gridData.length,
      (index) => _buildDayCell(index),
    );

    return MonthBox(
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        children: cells,
      ),
    );
  }
}
