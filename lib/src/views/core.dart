import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/store/store.dart';
import 'package:signals/signals_flutter.dart';
import 'package:flutter_flicker/src/store/context.dart';
import 'package:flutter_flicker/src/theme/theme.dart';
import 'package:flutter_flicker/src/widgets/views.dart';
import 'month_view.dart';
import 'years_view.dart';

/// FlickerBuilder - Main Widget Builder and State Coordinator
///
/// This widget serves as the core builder for the Flicker date picker,
/// managing state, view transitions, and providing the necessary context
/// for child widgets. It orchestrates the interaction between different
/// view modes and handles the overall lifecycle of the date picker.
///
/// ## Architecture
///
/// The FlickerBuilder follows a reactive architecture pattern:
/// - Uses a centralized [Store] for state management
/// - Employs the signals pattern for reactive updates
/// - Provides theme context through the widget tree
/// - Manages view transitions with smooth animations
///
/// ## View Modes
///
/// The builder supports two primary view modes:
/// - **Month View**: The main calendar grid showing days of a month
/// - **Years View**: A scrollable list for year selection
///
/// Transitions between these views are animated and user-friendly.
///
/// ## State Management
///
/// The widget maintains its own [Store] instance that:
/// - Initializes with props from the parent Flicker widget
/// - Manages selection state and view mode
/// - Handles date navigation and validation
/// - Provides reactive updates to child widgets
///
/// ## Example Usage
///
/// This widget is typically not used directly but is instantiated
/// by the main [Flicker] widget:
///
/// ```dart
/// Core(
///   props: FlickerProps(...),
///   theme: FlickerTheme.dark(),
/// )
/// ```
class Core extends StatefulWidget {
  /// Configuration properties passed from the parent Flicker widget
  ///
  /// This contains all the user-specified configuration including:
  /// - Selection mode and current values
  /// - Date constraints (start/end dates)
  /// - Callback functions
  /// - Display preferences
  /// - Custom builders
  final FlickerProps props;

  /// Optional theme override for styling the date picker
  ///
  /// If provided, this theme will be used instead of any inherited theme.
  /// The theme controls colors, typography, spacing, and other visual aspects.
  final FlickerTheme? theme;

  /// Creates a Core widget
  ///
  /// [props] contains the configuration from the parent Flicker widget
  /// [theme] optionally overrides the default theme
  const Core({super.key, required this.props, this.theme});

  @override
  State<Core> createState() => _CoreState();
}

/// Private state class for Core
///
/// Manages the widget's lifecycle, state initialization, and view building.
/// This class is responsible for:
/// - Creating and managing the Store instance
/// - Handling widget lifecycle events
/// - Building the appropriate view based on current state
/// - Coordinating animations between view modes
class _CoreState extends State<Core> {
  /// Central store instance for state management
  ///
  /// This store contains all the reactive state for the date picker,
  /// including current selection, display date, view mode, and more.
  /// It uses the signals pattern for efficient reactive updates.
  final Store _store = Store();

  @override
  void initState() {
    super.initState();
    _store.initialize(widget.props);
  }

  @override
  void didUpdateWidget(covariant Core oldWidget) {
    super.didUpdateWidget(oldWidget);
    _store.initialize(widget.props);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  /// Main builder method that constructs the date picker UI
  ///
  /// This method creates the complete date picker interface with:
  /// - Animated transitions between month and years views
  /// - Proper theme application and styling
  /// - Responsive sizing based on configuration
  /// - Smooth opacity animations for view switching
  ///
  /// The method uses a [Stack] to overlay the two view modes and
  /// animates their opacity for smooth transitions.
  ///
  /// [context] provides access to theme and localization data
  Widget _builder(BuildContext context) {
    return RootView(
      children: [
        TransparencableView(
          transparent: _store.isMonthView == false,
          child: const MonthView(),
        ),
        TransparencableView(
          transparent: _store.isYearsView == false,
          child: const YearsView(),
        ),
      ],
    );
  }

  /// Builds the complete Core widget with context providers
  ///
  /// This method wraps the date picker in the necessary context providers
  /// to make theme and store data available throughout the widget tree.
  /// It also sets up reactive watching for automatic rebuilds when state changes.
  ///
  /// The build method:
  /// 1. Creates a Context provider with theme and store
  /// 2. Sets up reactive watching with store dependencies
  /// 3. Delegates actual UI building to the _builder method
  ///
  /// Returns a [Widget] with proper context and reactive capabilities
  @override
  Widget build(BuildContext context) {
    return Context(
      theme: widget.theme?.data, // Apply custom theme if provided
      store: _store, // Provide store for descendant widgets
      child: Watch(
        _builder,
        dependencies: _store.dependencies,
      ), // Reactive updates
    );
  }
}
