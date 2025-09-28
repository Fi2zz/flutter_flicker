import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/theme/theme.dart';
import 'store.dart';

/// Context provider for Flicker date picker components
///
/// This InheritedWidget serves as the central context provider for the Flicker
/// date picker library. It manages and distributes theme data and store state
/// throughout the widget tree, providing convenient access methods for child
/// widgets to retrieve configuration and state information.
///
/// Key responsibilities:
/// - Provides theme configuration to all child widgets
/// - Manages and distributes store state across the widget tree
/// - Offers utility methods for common operations like date formatting
/// - Ensures proper widget rebuilding when theme or store changes
///
/// ## Usage Examples
///
/// ### Basic Context setup:
/// ```dart
/// class MyDatePicker extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Create store with configuration
///     final store = Store();
///     store.initialize(FlickerProps(
///       mode: SelectionMode.single,
///       maxCount: 1,
///     ));
///
///     // Wrap your date picker with Context
///     return Context(
///       store: store,
///       child: DatePickerWidget(),
///     );
///   }
/// }
/// ```
///
/// ### Context with custom theme:
/// ```dart
/// class ThemedDatePicker extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final store = Store();
///     store.initialize(FlickerProps(
///       mode: SelectionMode.range,
///       maxCount: 2,
///     ));
///
///     // Create custom theme
///     final customTheme = FlickThemeData(
///       primaryColor: Colors.blue,
///       selectedColor: Colors.blueAccent,
///       todayColor: Colors.orange,
///       textStyle: TextStyle(fontSize: 16),
///     );
///
///     return Context(
///       store: store,
///       theme: customTheme,
///       child: CustomDatePickerWidget(),
///     );
///   }
/// }
/// ```
///
/// ### Accessing Context in child widgets:
/// ```dart
/// class DatePickerWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Access the Context
///     final flickerContext = Context.of(context);
///     if (flickerContext == null) {
///       return const Text('Context not found');
///     }
///
///     // Access store and theme
///     final store = flickerContext.store;
///     final theme = flickerContext.theme;
///
///     return Watch((context) {
///       return Column(
///         children: [
///           Text('Selection mode: ${store.mode.value}'),
///           Text('Selected dates: ${store.selection.result}'),
///           if (theme != null)
///             Text('Using custom theme'),
///           CalendarGrid(),
///         ],
///       );
///     });
///   }
/// }
/// ```
///
/// ### Using convenience methods:
/// ```dart
/// class CalendarHeader extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     // Use convenience methods for quick access
///     final store = Context.storeOf(context);
///     final theme = Context.themeOf(context);
///
///     if (store == null) {
///       return const SizedBox.shrink();
///     }
///
///     return Watch((context) {
///       final displayDate = store.displayDate.value;
///
///       return Container(
///         padding: const EdgeInsets.all(16),
///         decoration: BoxDecoration(
///           color: theme?.primaryColor ?? Colors.blue,
///         ),
///         child: Row(
///           mainAxisAlignment: MainAxisAlignment.spaceBetween,
///           children: [
///             IconButton(
///               onPressed: () => store.previousMonth(),
///               icon: const Icon(Icons.chevron_left),
///             ),
///             Text(
///               '${displayDate.year}-${displayDate.month}',
///               style: theme?.textStyle ?? const TextStyle(),
///             ),
///             IconButton(
///               onPressed: () => store.nextMonth(),
///               icon: const Icon(Icons.chevron_right),
///             ),
///           ],
///         ),
///       );
///     });
///   }
/// }
/// ```
///
/// ### Complex widget tree with multiple consumers:
/// ```dart
/// class FullDatePicker extends StatelessWidget {
///   final FlickerProps props;
///   final FlickThemeData? theme;
///
///   const FullDatePicker({
///     Key? key,
///     required this.props,
///     this.theme,
///   }) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     final store = Store();
///     store.initialize(props);
///
///     return Context(
///       store: store,
///       theme: theme,
///       child: Column(
///         children: [
///           CalendarHeader(),
///           Expanded(child: CalendarGrid()),
///           CalendarFooter(),
///         ],
///       ),
///     );
///   }
/// }
///
/// class CalendarGrid extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final store = Context.storeOf(context)!;
///     final theme = Context.themeOf(context);
///
///     return Watch((context) {
///       return GridView.builder(
///         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///           crossAxisCount: 7,
///         ),
///         itemBuilder: (context, index) {
///           // Each cell can access the same context
///           return DayCell(index: index);
///         },
///       );
///     });
///   }
/// }
///
/// class DayCell extends StatelessWidget {
///   final int index;
///
///   const DayCell({Key? key, required this.index}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     final store = Context.storeOf(context)!;
///     final theme = Context.themeOf(context);
///
///     return Watch((context) {
///       final date = _calculateDateForIndex(index);
///       final isSelected = store.selection.any(date);
///
///       return GestureDetector(
///         onTap: () => store.selectDate(date),
///         child: Container(
///           decoration: BoxDecoration(
///             color: isSelected
///               ? theme?.selectedColor ?? Colors.blue
///               : null,
///             border: Border.all(color: Colors.grey),
///           ),
///           child: Center(
///             child: Text(
///               '${date.day}',
///               style: theme?.textStyle ?? const TextStyle(),
///             ),
///           ),
///         ),
///       );
///     });
///   }
///
///   DateTime _calculateDateForIndex(int index) {
///     // Implementation for calculating date based on index
///     return DateTime.now().add(Duration(days: index));
///   }
/// }
///
/// class CalendarFooter extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final store = Context.storeOf(context)!;
///
///     return Watch((context) {
///       final selectedDates = store.selection.result;
///
///       return Container(
///         padding: const EdgeInsets.all(16),
///         child: Column(
///           children: [
///             Text('Selected: ${selectedDates.length} dates'),
///             if (selectedDates.isNotEmpty)
///               Text('Latest: ${selectedDates.last}'),
///             Row(
///               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
///               children: [
///                 ElevatedButton(
///                   onPressed: () => store.selection.reset(),
///                   child: const Text('Clear'),
///                 ),
///                 ElevatedButton(
///                   onPressed: () => _handleConfirm(selectedDates),
///                   child: const Text('Confirm'),
///                 ),
///               ],
///             ),
///           ],
///         ),
///       );
///     });
///   }
///
///   void _handleConfirm(List<DateTime> dates) {
///     print('Confirmed dates: $dates');
///   }
/// }
/// ```
///
/// ### Error handling and null safety:
/// ```dart
/// class SafeDatePickerWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final flickerContext = Context.of(context);
///
///     // Always check for null context
///     if (flickerContext == null) {
///       return const Center(
///         child: Text('Flicker Context not found. Wrap with Context widget.'),
///       );
///     }
///
///     final store = flickerContext.store;
///     final theme = flickerContext.theme;
///
///     return Watch((context) {
///       return Container(
///         decoration: BoxDecoration(
///           color: theme?.backgroundColor ?? Colors.white,
///         ),
///         child: Column(
///           children: [
///             Text('Mode: ${store.mode.value}'),
///             Text('Selected: ${store.selection.length}'),
///             // Rest of your widget tree
///           ],
///         ),
///       );
///     });
///   }
/// }
/// ```
class Context extends InheritedWidget {
  /// Optional theme data for customizing the appearance of Flicker components
  final FlickThemeData? theme;

  /// The store instance containing all state management logic
  final Store store;

  /// Creates a new Context widget
  ///
  /// Parameters:
  /// - [theme]: Optional theme data for styling
  /// - [store]: Required store instance for state management
  /// - [child]: Required child widget to wrap
  const Context({
    super.key,
    this.theme,
    required this.store,
    required super.child,
  });

  /// Retrieves the nearest Context instance from the widget tree
  ///
  /// Returns the Context instance if found, null otherwise.
  /// This is the primary method for accessing the context from child widgets.
  ///
  /// Parameters:
  /// - [context]: The BuildContext to search from
  ///
  /// Returns:
  /// The nearest Context instance or null if not found
  static Context? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Context>();
  }

  /// Retrieves the theme data from the nearest Context
  ///
  /// Provides a convenient way to access theme configuration. If no theme
  /// is found in the context, returns a default light theme.
  ///
  /// Parameters:
  /// - [context]: The BuildContext to search from
  ///
  /// Returns:
  /// FlickThemeData instance, either from context or default light theme
  static FlickThemeData themeOf(BuildContext context) =>
      of(context)?.theme ?? FlickThemeData.light();

  /// Retrieves the store instance from the nearest Context
  ///
  /// Provides access to the state management store. If no store is found
  /// in the context, returns a new default Store instance.
  ///
  /// Parameters:
  /// - [context]: The BuildContext to search from
  ///
  /// Returns:
  /// Store instance, either from context or a new default instance
  static Store storeOf(BuildContext context) => of(context)?.store ?? Store();

  /// Determines whether the widget should notify dependents of changes
  ///
  /// This method is called by the Flutter framework to determine if dependent
  /// widgets should be rebuilt when this InheritedWidget is updated.
  ///
  /// Parameters:
  /// - [oldWidget]: The previous Context instance
  ///
  /// Returns:
  /// true if dependents should be notified, false otherwise
  @override
  bool updateShouldNotify(Context oldWidget) {
    return theme != oldWidget.theme || store != oldWidget.store;
  }
}
