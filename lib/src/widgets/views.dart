import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/l10n/i10n.dart';
import 'package:flutter_flicker/src/helpers/compute_size.dart';
import 'package:flutter_flicker/src/store/context.dart';

/// A wrapper widget that provides interactive tap behavior with visual feedback
///
/// This widget wraps any child widget to make it tappable with visual feedback.
/// It provides opacity changes during tap interactions and can be disabled
/// when needed.
///
/// ## Features
/// - **Visual feedback**: Opacity changes during tap interactions
/// - **Configurable behavior**: Can be enabled/disabled via the tappable parameter
/// - **Gesture handling**: Comprehensive tap gesture detection
///
/// ## Usage
/// ```dart
/// Tappable(
///   tappable: true,
///   onTap: () => print('Tapped!'),
///   child: Container(
///     padding: EdgeInsets.all(16),
///     child: Text('Tap me'),
///   ),
/// )
/// ```
///
/// When tapped, the widget briefly reduces opacity to provide visual feedback,
/// then returns to normal opacity when the tap is released or cancelled.
class Tappable extends StatefulWidget {
  /// Whether the widget should respond to tap gestures
  ///
  /// When false, the widget will not respond to taps and will have
  /// reduced opacity to indicate its disabled state.
  final bool tappable;

  /// Callback function invoked when the widget is tapped
  ///
  /// This callback is only triggered when [tappable] is true.
  final GestureTapCallback? onTap;

  /// The child widget to wrap with tap behavior
  final Widget child;

  /// Creates a tappable widget wrapper
  ///
  /// The [child] parameter is required. The [tappable] parameter defaults
  /// to true, and [onTap] is optional.
  const Tappable({
    super.key,
    this.tappable = true,
    this.onTap,
    required this.child,
  });

  @override
  State<Tappable> createState() => _TappableState();
}

/// State class for managing tap interactions and visual feedback
///
/// This state class handles the tap gesture lifecycle and manages the
/// visual feedback by tracking the pressed state and updating opacity accordingly.
class _TappableState extends State<Tappable> {
  /// Tracks whether the widget is currently being pressed
  late bool _isPressed = false;

  /// Handles tap down events by setting the pressed state
  void _handleTapDown(TapDownDetails details) => _setPressed(true);

  /// Handles tap up events by clearing the pressed state
  void _handleTapUp(TapUpDetails details) => _setPressed(false);

  /// Handles tap cancel events by clearing the pressed state
  void _handleTapCancel() => _setPressed(false);

  /// Updates the pressed state and triggers a rebuild for visual feedback
  ///
  /// Only updates state if the widget is tappable. This prevents
  /// unnecessary rebuilds when the widget is disabled.
  void _setPressed(bool pressed) {
    if (!widget.tappable) return;
    setState(() => _isPressed = pressed);
  }

  /// Handles tap completion by invoking the callback
  ///
  /// Only triggers the callback if the widget is tappable.
  void _handleTap() {
    if (widget.tappable) widget.onTap?.call();
  }

  /// Calculates the current opacity based on state
  ///
  /// Returns 0.4 (40% opacity) when pressed or disabled,
  /// and 1.0 (full opacity) when normal.
  double get _opacity => _isPressed || !widget.tappable ? 0.4 : 1.0;

  /// Builds the tappable widget with gesture detection and opacity feedback
  ///
  /// Wraps the child widget in a GestureDetector for tap handling and
  /// an Opacity widget for visual feedback.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap, // Handle tap completion
      onTapDown: _handleTapDown, // Handle tap start
      onTapUp: _handleTapUp, // Handle tap end
      onTapCancel: _handleTapCancel, // Handle tap cancellation
      child: Opacity(
        opacity: _opacity,
        child: widget.child,
      ), // Apply visual feedback
    );
  }
}

/// A view widget that sizes itself using the standard computed size
///
/// This widget wraps its child in a SizedBox with dimensions calculated
/// by the computeSize() function, providing consistent sizing across
/// the date picker components.
class StandardView extends StatelessWidget {
  /// The child widget to be sized
  final Widget child;

  /// Creates a standard view with computed sizing
  const StandardView({super.key, required this.child});

  /// Builds the view with standard computed dimensions
  @override
  Widget build(BuildContext context) =>
      SizedBox.fromSize(size: computeSize(), child: child);
}

/// A view widget that sizes itself using the base size configuration
///
/// This widget provides a fixed base size for components that need
/// consistent dimensions regardless of view configuration.
class BaseView extends StatelessWidget {
  /// The child widget to be sized
  final Widget child;

  /// Creates a base view with fixed base sizing
  const BaseView({super.key, required this.child});

  /// Builds the view with base dimensions
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: baseSize, child: child);
  }
}

/// A view widget that computes its size based on context and configuration
///
/// This widget dynamically calculates its size based on the provided
/// compute source and current store configuration (view count, scroll direction).
/// It's used for components that need to adapt their size based on the
/// date picker's current state.
class ComputedView extends StatelessWidget {
  /// The source type for size computation
  final ComputeSource source;

  /// The child widget to be sized
  final Widget child;

  /// Creates a computed view with dynamic sizing
  const ComputedView({super.key, required this.child, required this.source});

  /// Builds the view with dynamically computed dimensions
  ///
  /// Retrieves the current store configuration and computes the appropriate
  /// size based on the source type, view count, and scroll direction.
  @override
  Widget build(BuildContext context) {
    final store = Context.storeOf(context);
    Size size = computeSize(source, store.viewCount, store.scrollDirection);
    return SizedBox.fromSize(size: size, child: child);
  }
}

/// The root container view for the date picker
///
/// This widget serves as the main container for all date picker components.
/// It applies the theme decoration, standard padding, and uses a computed
/// size for the root layout. All child widgets are stacked within this container.
class RootView extends StatelessWidget {
  /// List of child widgets to be stacked in the root container
  final List<Widget> children;

  /// Creates a root view container
  const RootView({super.key, required this.children});

  /// Builds the root container with theme decoration and computed sizing
  ///
  /// Applies:
  /// - Theme decoration from the current context
  /// - Standard padding (16px vertical, 12px horizontal)
  /// - Root-computed sizing
  /// - Stack layout for child widgets
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Context.themeOf(context).decoration, // Apply theme decoration
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 12.0,
      ), // Standard padding
      child: ComputedView(
        source: ComputeSource.root, // Use root size computation
        child: Stack(children: children), // Stack all child widgets
      ),
    );
  }
}

/// A view widget that can animate between visible and transparent states
///
/// This widget provides smooth opacity transitions for showing/hiding content.
/// When transparent, it also ignores pointer events to prevent interaction
/// with hidden content.
///
/// ## Features
/// - **Smooth transitions**: 300ms animated opacity changes
/// - **Pointer management**: Disables interactions when transparent
/// - **Ease curves**: Uses easeInOut curve for natural animations
/// - **State-driven**: Controlled by the transparent boolean parameter
///
/// ## Usage
/// ```dart
/// TransparencableView(
///   transparent: isHidden,
///   child: MyWidget(),
/// )
/// ```
class TransparencableView extends StatelessWidget {
  /// The child widget to show/hide
  final Widget child;

  /// Whether the widget should be transparent (hidden)
  ///
  /// When true, the widget animates to 0% opacity and ignores pointer events.
  /// When false, the widget animates to 100% opacity and accepts interactions.
  final bool transparent;

  /// Creates a transparencable view
  const TransparencableView({
    super.key,
    required this.child,
    this.transparent = false,
  });

  /// Builds the view with animated opacity and pointer control
  ///
  /// Uses AnimatedOpacity for smooth transitions and IgnorePointer
  /// to manage interaction states based on visibility.
  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(milliseconds: 300); // Animation duration
    return AnimatedOpacity(
      opacity: transparent ? 0.0 : 1.0, // Target opacity based on state
      duration: duration,
      curve: Curves.easeInOut, // Smooth animation curve
      child: IgnorePointer(
        ignoring: transparent,
        child: child,
      ), // Disable interactions when hidden
    );
  }
}

/// A title view widget that displays formatted month/year information
///
/// This widget renders the current month and year as a title, with optional
/// tap functionality and additional child widgets (like dropdown indicators).
/// It uses localized formatting and applies theme styling.
///
/// ## Features
/// - **Localized formatting**: Uses context-aware month/year formatting
/// - **Theme integration**: Applies title text style from current theme
/// - **Interactive**: Optional tap callback for navigation or mode switching
/// - **Extensible**: Supports additional child widgets (e.g., dropdown arrows)
///
/// ## Usage
/// ```dart
/// TitleView(
///   date: DateTime.now(),
///   onTap: () => switchToYearView(),
///   child: Triangle(reverse: false, color: Colors.blue),
/// )
/// ```
class TitleView extends StatelessWidget {
  /// The date to display in the title (month and year)
  final DateTime date;

  /// Optional callback invoked when the title is tapped
  ///
  /// Commonly used for switching between month and year views.
  final Function()? onTap;

  /// Optional child widget to display alongside the title
  ///
  /// Typically used for dropdown indicators or navigation arrows.
  final Widget? child;

  /// Creates a title view
  const TitleView({super.key, required this.date, this.onTap, this.child});

  /// Builds a tappable title with additional child widget
  ///
  /// Creates a horizontal row layout with the title text and child widget,
  /// wrapped in a Tappable widget for interaction handling.
  Widget _buildTapableTitle(Widget title) {
    List<Widget> children = [title, child!];
    final core = Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Center align vertically
      mainAxisAlignment: MainAxisAlignment.start, // Align to start horizontally
      children: children,
    );
    return Tappable(onTap: onTap, child: core);
  }

  /// Builds the title view with formatted date text
  ///
  /// Creates a text widget with localized month/year formatting and
  /// theme styling. If a child widget is provided, wraps everything
  /// in a tappable container.
  @override
  Widget build(BuildContext context) {
    final theme = Context.themeOf(context);
    Widget title = Text(
      FlickerL10n.of(context).formatMonth(date), // Localized month/year format
      style: theme.titleTextStyle, // Apply theme title style
    );
    // If child widget provided, make the title tappable with child
    if (child != null) return _buildTapableTitle(title);
    return title; // Return simple title if no child
  }
}

/// A non-scrollable grid view optimized for calendar layouts
///
/// This widget creates a 7-column grid (for days of the week) with square
/// cells and disabled scrolling. It's specifically designed for calendar
/// month views where scrolling should be handled by parent widgets.
///
/// ## Features
/// - **Fixed layout**: 7 columns for weekday layout
/// - **Square cells**: 1:1 aspect ratio for consistent appearance
/// - **No scrolling**: Prevents internal scrolling conflicts
/// - **Performance optimized**: Efficient for calendar grids
class NeverScrollableGridView extends StatelessWidget {
  /// List of widgets to display in the grid
  final List<Widget> children;

  /// Creates a non-scrollable grid view
  const NeverScrollableGridView({super.key, required this.children});

  /// Builds the grid view with calendar-optimized settings
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      crossAxisCount: 7, // 7 columns for weekdays
      childAspectRatio: 1.0, // Square cells
      children: children,
    );
  }
}
