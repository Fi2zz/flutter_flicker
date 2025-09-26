import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/l10n/i10n.dart';
import 'package:flutter_flicker/src/helpers/helpers.dart';
import 'package:flutter_flicker/src/store/context.dart';
import 'package:flutter_flicker/src/store/store.dart';
import 'package:flutter_flicker/src/widgets/painters.dart';
import 'package:flutter_flicker/src/widgets/swipable_view.dart';
import 'package:flutter_flicker/src/widgets/views.dart';

/// Header View Component
///
/// A sophisticated header widget that provides navigation controls and weekday labels
/// for the Flicker date picker. This component adapts its layout based on the current
/// view configuration and provides intuitive navigation between months.
///
/// ## Key Features
///
/// ### Navigation Controls
/// - Left/right chevron buttons for month navigation
/// - Intelligent boundary detection to prevent invalid navigation
/// - Smooth integration with swipe gestures
/// - Conditional rendering based on date constraints
///
/// ### Layout Adaptability
/// - Vertical layout: Shows only weekday headers
/// - Horizontal layout: Includes navigation controls and month titles
/// - Single/double view support with appropriate spacing
/// - Responsive design that adapts to different screen sizes
///

///
/// ## Architecture
///
/// The HeaderView integrates with:
/// - [SwipeController] for programmatic navigation
/// - [Store] for state management and date constraints
/// - [FlickerTheme] for consistent styling
/// - [TitleView] for month/year display
///
/// ## Usage
///
/// This component is typically used within the main calendar view:
/// ```dart
/// HeaderView(controller: swipeController)
/// ```
class HeaderView extends StatelessWidget {
  /// Controller for managing swipe-based navigation
  /// Used to programmatically trigger month transitions
  final SwipeController controller;

  /// Creates a header view with the specified swipe controller
  const HeaderView({super.key, required this.controller});

  /// Determines if the left navigation button should be enabled
  ///
  /// Returns false if the current display month is the same as the start date month,
  /// preventing navigation beyond the allowed date range. If no start date is set,
  /// navigation is always allowed.
  ///
  /// [store] The current store instance containing date constraints
  bool _canTapLeft(Store store) {
    if (store.startDate == null) return true;
    return !DateHelpers.isSameMonth(store.display, store.startDate!);
  }

  /// Determines if the right navigation button should be enabled
  ///
  /// Returns false if the current display month is the same as the end date month,
  /// preventing navigation beyond the allowed date range. If no end date is set,
  /// navigation is always allowed.
  ///
  /// [store] The current store instance containing date constraints
  bool _canTapRight(Store store) {
    if (store.endDate == null) return true;
    return !DateHelpers.isSameMonth(store.display, store.endDate!);
  }

  /// Builds the header view with navigation controls and weekday labels
  ///
  /// This method creates a responsive header that adapts to different view configurations:
  /// - Vertical layout: Returns only the weekday header
  /// - Horizontal layout: Includes navigation controls and month titles
  /// - Single/double view: Adjusts layout and navigation accordingly
  ///
  /// The header integrates theme colors for consistent visual styling.
  @override
  Widget build(BuildContext context) {
    final theme = Context.themeOf(context);
    final store = Context.storeOf(context);
    // Use selected text color for navigation elements to maintain visual consistency
    Color color = theme.daySelectedTextStyle.color!;

    // Build the weekday header row
    final week = _buildWeekView();
    // For vertical layouts, only show the weekday header
    if (store.isVertical) return week;

    // Create left navigation button with boundary checking
    final left = Tappable(
      tappable: _canTapLeft(store),
      onTap: () => controller.slide(store.viewCount * -1),
      child: Chevron(type: 'left', color: color),
    );

    // Create right navigation button with boundary checking
    final right = Tappable(
      tappable: _canTapRight(store),
      onTap: () => controller.slide(store.viewCount),
      child: Chevron(type: 'right', color: color),
    );

    // Determine if year selection should be enabled
    final tappable = store.isSingleView && store.startYear != store.endYear;
    Widget header = const SizedBox.shrink();

    // Build header layout based on view count
    if (store.viewCount == 2) {
      // Double view layout: Two separate month headers with navigation
      Widget children1 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          left, // Left navigation for first month
          Center(child: TitleView(date: store.display)),
          const SizedBox.shrink(), // Placeholder for symmetry
        ],
      );
      Widget children2 = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox.shrink(), // Placeholder for symmetry
          Center(child: TitleView(date: store.nextDisplay)),
          right, // Right navigation for second month
        ],
      );
      header = Row(
        children: [
          BaseView(child: children1),
          BaseView(child: children2),
        ],
      );
    } else if (store.viewCount == 1) {
      // Single view layout: Centered title with navigation buttons
      header = Row(
        children: [
          Expanded(
            flex: 4,
            child: TitleView(
              date: store.display,
              onTap: store.onSwtichView, // Enable year selection if available
              child: Triangle(
                reverse: tappable == false ? null : false,
                color: color,
              ),
            ),
          ),
          left,
          right,
        ],
      );
    }
    // Combine header and weekday row
    return Column(children: [header, week]);
  }

  /// Builds the weekday header row
  ///
  /// Creates a row of weekday abbreviations (Mon, Tue, Wed, etc.) that serves as
  /// column headers for the calendar grid. The weekdays are localized and respect
  /// the configured first day of week setting.
  ///
  /// For double view layouts, this method creates two identical weekday rows
  /// side by side to match the dual calendar layout.
  ///
  /// Returns a [Widget] containing the weekday header(s) with proper styling
  /// and layout constraints.
  Widget _buildWeekView() {
    return Builder(
      builder: (BuildContext context) {
        final theme = Context.themeOf(context);
        final store = Context.storeOf(context);
        final l10n = FlickerL10n.of(context);
        // Get localized weekday names based on first day of week setting
        List<String> data = l10n.getWeekNames(store.firstDayOfWeek);
        // Create styled text widgets for each weekday
        List<Widget> children = data
            .map(
              (date) =>
                  Center(child: Text(date, style: theme.weekDayTextStyle)),
            )
            .toList();

        // Create a non-scrollable grid for the weekday headers
        Widget child = NeverScrollableGridView(children: children);
        Widget week = BaseView(child: child);

        // For double views in horizontal layout, show two weekday rows
        if (store.isDoubleViews && store.isHorizontal) {
          return Row(children: [week, week]);
        }
        return week;
      },
    );
  }
}
