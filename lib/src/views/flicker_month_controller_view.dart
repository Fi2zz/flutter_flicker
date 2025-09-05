import 'package:flutter/widgets.dart';
import 'flicker_view_title.dart';
import 'flicker_shared.dart';
import 'flicker_size_helper.dart';
import 'date_helpers.dart';

/// Flicker month controller view component
///
/// Responsible for rendering month navigation controller, including title and left/right navigation buttons
class FlickerMonthControllerView extends StatelessWidget {
  /// Currently displayed date
  final DateTime displayDate;
  
  /// View count (1 or 2)
  final int viewCount;
  
  /// Scroll direction
  final Axis scrollDirection;
  
  /// Start date limit
  final DateTime? startDate;
  
  /// End date limit
  final DateTime? endDate;
  
  /// Whether left button can be tapped
  final bool canTapLeft;
  
  /// Whether right button can be tapped
  final bool canTapRight;
  
  /// Left button tap callback
  final GestureTapCallback? onTapLeft;
  
  /// Right button tap callback
  final GestureTapCallback? onTapRight;
  
  /// Year view callback
  final ValueChanged<DateTime>? onShowYearView;

  const FlickerMonthControllerView({
    super.key,
    required this.displayDate,
    required this.viewCount,
    required this.scrollDirection,
    this.startDate,
    this.endDate,
    this.canTapLeft = true,
    this.canTapRight = true,
    this.onTapLeft,
    this.onTapRight,
    this.onShowYearView,
  });

  /// Calculate whether to show triangle (year selector)
  bool _computeShowTriangle() {
    final noRange = startDate == null || endDate == null;
    return !noRange && startDate!.year != endDate!.year;
  }

  /// Build title widget
  Widget _buildTitleWidget({
    required DateTime date,
    bool showTriangle = false,
    VoidCallback? onTap,
    int flex = 1,
    bool centerred = false,
  }) {
    return FlickerViewTitle(
      date: date,
      onTap: onTap,
      roate: false,
      showTriangle: showTriangle,
      flex: flex,
      centerred: centerred,
    );
  }

  /// Build left and right navigation buttons
  Map<String, Widget> _buildChevronControls() {
    final left = Chevron.left(
      touchable: canTapLeft,
      onTap: onTapLeft ?? () {},
    );
    final right = Chevron.right(
      touchable: canTapRight,
      onTap: onTapRight ?? () {},
    );
    return {'left': left, 'right': right};
  }

  /// Build single view layout
  Widget _buildSingleView(Widget left, Widget right) {
    final showTriangle = _computeShowTriangle();

    return Row(
      children: [
        _buildTitleWidget(
          date: displayDate,
          showTriangle: showTriangle,
          onTap: showTriangle ? () => onShowYearView?.call(displayDate) : null,
          flex: 4,
        ),
        left,
        right,
      ],
    );
  }

  /// Build double view layout
  Widget _buildDoubleView(Widget left, Widget right) {
    return Row(
      children: [
        BaseBox(
          child: Row(
            children: [
              left,
              _buildTitleWidget(date: displayDate, centerred: true),
              const SizedBox.shrink(),
            ],
          ),
        ),
        BaseBox(
          child: Row(
            children: [
              const SizedBox.shrink(),
              _buildTitleWidget(
                date: DateHelpers.nextMonth(displayDate),
                centerred: true,
              ),
              right,
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Don't show controller when scrolling vertically
    if (scrollDirection == Axis.vertical) {
      return const SizedBox.shrink();
    }

    final chevrons = _buildChevronControls();
    final left = chevrons['left']!;
    final right = chevrons['right']!;

    return viewCount == 1
        ? _buildSingleView(left, right)
        : _buildDoubleView(left, right);
  }
}