import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/helpers/compute_size.dart';
import 'package:flutter_flicker/src/widgets/painters.dart';
import 'package:flutter_flicker/src/widgets/views.dart';
import 'package:flutter_flicker/src/store/context.dart';
import 'package:flutter_flicker/src/widgets/scrollable_view/scrollable_view.dart';

/// Year Selection View Component
///
/// A specialized view that provides an intuitive interface for year selection
/// within the Flicker date picker. This component appears when users tap on
/// the month/year title in the main calendar view, offering a scrollable
/// list of years for quick navigation.
///
/// ## Key Features
///
/// ### Scrollable Year List
/// - Displays years within the configured date range
/// - Smooth scrolling with proper item sizing
/// - Automatic centering on the current year
/// - Visual feedback for selection and disabled states
///
/// ### Interactive Navigation
/// - Tap-to-select year functionality
/// - Seamless transition back to month view
/// - Proper boundary handling for date constraints
///
/// ### Visual Design
/// - Consistent theming with the main calendar
/// - Clear visual hierarchy with title header
/// - Disabled state styling for out-of-range years
/// - Smooth animations and transitions
///
/// ## Architecture
///
/// The YearsView integrates with:
/// - [ScrollableView] for efficient year list rendering
/// - [Store] for state management and year selection
/// - [FlickerTheme] for consistent styling
/// - [TitleView] for header display and navigation
///
/// ## Usage
///
/// This component is typically accessed by tapping the month/year title:
/// ```dart
/// YearsView() // Automatically integrates with context
/// ```
///
/// ## Layout Structure
///
/// ```
/// YearsView
/// ├── TitleView (header with back navigation)
/// └── ScrollableView (year list)
///     └── Year widgets (individual year items)
/// ```
class YearsView extends StatelessWidget {
  /// Creates a year selection view component
  const YearsView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final theme = Context.themeOf(context);
    // Use selected text color for consistent theming
    Color color = theme.daySelectedTextStyle.color!;
    final store = Context.storeOf(context);
    
    // Helper functions for year state determination
    bool selected(int year) => year == store.display.year;
    bool disabled(int year) => year < store.startYear || year > store.endYear;
    
    // Build the scrollable year selection list
    final child = ScrollableView(
      startValue: store.startYear,
      endValue: store.endYear,
      initialValue: store.display.year,
      itemHeight: unitSize,
      itemBuilder: (context, year, index) {
        return Year(
          year: year,
          selected: selected(year),
          disabled: disabled(year),
          onTap: (value) => store.selectYear(value),
        );
      },
    );

    // Build the header with back navigation
    final title = TitleView(
      date: Context.storeOf(context).display,
      onTap: Context.storeOf(context).onSwtichView,
      child: Triangle(reverse: true, color: color), // Up arrow for back navigation
    );
    
    // Combine header and year list in a column layout
    return Column(
      children: [
        BaseView(child: title),
        StandardView(child: child),
      ],
    );
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
    final theme = Context.themeOf(context);
    return Tappable(
      tappable: !disabled,
      onTap: () => onTap(year),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: theme.getDayDecoration(
          isSelected: selected,
          isDisabled: disabled,
          isHighlighted: false,
          isInRange: false,
          isRangeStart: false,
          isRangeEnd: false,
        ),
        alignment: Alignment.center,
        child: Text(
          year.toString(),
          style: theme.getDayTextStyle(
            isSelected: selected,
            isDisabled: disabled,
            isHighlighted: false,
            isInRange: false,
            isRangeStart: false,
            isRangeEnd: false,
          ),
        ),
      ),
    );
  }
}
