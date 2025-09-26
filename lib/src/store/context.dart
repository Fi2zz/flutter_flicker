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
