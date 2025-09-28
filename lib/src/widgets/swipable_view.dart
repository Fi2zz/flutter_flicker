import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

/// Enumeration for swipe directions
enum SwipeDirection {
  /// Swipe forward (left-to-right or top-to-bottom)
  forward,

  /// Swipe backward (right-to-left or bottom-to-top)
  backward,
}

/// Builder function type for creating swipable view items
///
/// Takes a [BuildContext] and an item of type [T], returns a [Widget]
typedef SwipableViewBuilder<T> = Widget Function(BuildContext context, T item);

/// Callback function type for swipe events
///
/// Called when a swipe gesture is completed with the swipe direction
typedef SwipeCallback = void Function(SwipeDirection direction);

/// Validation callback function type for swipe gestures
///
/// Called before a swipe is executed to determine if the swipe should be allowed.
/// Returns true if the swipe to [nextIndex] in the given [direction] is valid.
typedef SwipeValidationCallback =
    bool Function(int nextIndex, SwipeDirection direction);

/// A custom pan gesture recognizer that delays gesture resolution to avoid conflicts
///
/// This recognizer is designed to work with swipable views by implementing
/// intelligent gesture conflict resolution. It waits for sufficient movement
/// or velocity before claiming the gesture, allowing other gesture recognizers
/// to compete fairly.
///
/// Features:
/// - Delayed gesture resolution based on movement threshold and velocity
/// - Configurable swipe threshold and scroll direction
/// - Conflict resolution to prevent gesture interference
/// - Support for both horizontal and vertical scrolling
class _DelayedPanGestureRecognizer extends PanGestureRecognizer {
  /// The minimum distance required to trigger a swipe gesture
  final double swipeThreshold;

  /// The direction of scrolling (horizontal or vertical)
  final Axis scrollDirection;

  /// The starting position of the pan gesture
  double _startPosition = 0.0;

  /// Whether the gesture conflict has been resolved
  bool _hasResolvedConflict = false;

  /// Creates a delayed pan gesture recognizer
  ///
  /// [swipeThreshold] - The minimum distance for swipe detection
  /// [scrollDirection] - The axis along which swiping is allowed
  _DelayedPanGestureRecognizer({
    required this.swipeThreshold,
    required this.scrollDirection,
  });

  /// Handles the initial pointer down event
  ///
  /// Records the starting position and resets the conflict resolution state
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _startPosition = scrollDirection == Axis.horizontal
        ? event.position.dx
        : event.position.dy;
    _hasResolvedConflict = false;
  }

  /// Handles pointer events and implements delayed gesture resolution
  ///
  /// This method analyzes the movement distance and velocity to determine
  /// when to claim the gesture. It uses two criteria:
  /// 1. Early resolution: 30% of threshold + sufficient velocity (>3.0)
  /// 2. Late resolution: 80% of threshold regardless of velocity
  @override
  void handleEvent(PointerEvent event) {
    super.handleEvent(event);
    if (event is PointerMoveEvent && !_hasResolvedConflict) {
      final currentPosition = scrollDirection == Axis.horizontal
          ? event.position.dx
          : event.position.dy;

      final totalDelta = (currentPosition - _startPosition).abs();
      final velocity = scrollDirection == Axis.horizontal
          ? event.delta.dx.abs()
          : event.delta.dy.abs();

      // Early resolution for fast gestures
      if (totalDelta > swipeThreshold * 0.3 && velocity > 3.0) {
        _hasResolvedConflict = true;
        resolve(GestureDisposition.accepted);
      }
      // Late resolution for slower but definitive gestures
      else if (totalDelta > swipeThreshold * 0.8) {
        _hasResolvedConflict = true;
        resolve(GestureDisposition.accepted);
      }
    }
  }
}

/// Controller for programmatically managing swipable view navigation
///
/// This controller provides external control over a [SwipableView] widget,
/// allowing programmatic navigation through the pages. It must be attached
/// to a SwipableView to function properly.
///
/// Features:
/// - Programmatic page navigation with smooth animations
/// - Support for multi-step sliding (jumping multiple pages)
/// - Automatic cleanup and resource management
/// - Safe operation with null-checking
///
/// Usage:
/// ```dart
/// final controller = SwipeController();
///
/// SwipableView(
///   controller: controller,
///   // ... other properties
/// )
///
/// // Navigate programmatically
/// controller.slide(1);  // Move forward one page
/// controller.slide(-2); // Move backward two pages
/// ```
class SwipeController {
  /// The page controller used for navigation
  PageController? _pageController;

  /// Function to get the current page index
  int Function()? _getCurrentIndex;

  /// Attaches this controller to a SwipableView's internal controllers
  ///
  /// This method is called internally by SwipableView and should not be
  /// called directly by user code.
  ///
  /// [pageController] - The PageController from the SwipableView
  /// [getCurrentIndex] - Function to retrieve the current page index
  void attach(PageController pageController, int Function() getCurrentIndex) {
    _pageController = pageController;
    _getCurrentIndex = getCurrentIndex;
  }

  /// Disposes of the controller and cleans up resources
  ///
  /// This method is called automatically when the SwipableView is disposed.
  /// After calling this method, the controller can no longer be used for navigation.
  void dispose() {
    _pageController = null;
    _getCurrentIndex = null;
  }

  /// Slides the view by the specified number of steps
  ///
  /// Positive values move forward, negative values move backward.
  /// Each step represents one page. The navigation is animated with
  /// a smooth easing curve.
  ///
  /// [step] - Number of pages to move (positive = forward, negative = backward)
  ///
  /// Example:
  /// ```dart
  /// controller.slide(1);   // Move to next page
  /// controller.slide(-1);  // Move to previous page
  /// controller.slide(3);   // Jump forward 3 pages
  /// ```
  void slide(int step) {
    if (_pageController == null || _getCurrentIndex == null) {
      return;
    }
    if (step > 0) {
      // Move forward step by step
      for (int i = 0; i < step; i++) {
        _pageController!.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (step < 0) {
      // Move backward step by step
      for (int i = 0; i < -step; i++) {
        _pageController!.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }
}

/// A highly customizable swipable view widget for navigating through a list of items
///
/// SwipableView provides a smooth, gesture-driven interface for browsing through
/// a collection of items. It supports both horizontal and vertical swiping with
/// configurable thresholds, validation callbacks, and programmatic control.
///
/// Features:
/// - Gesture-based navigation with customizable swipe thresholds
/// - Support for both horizontal and vertical scrolling
/// - Programmatic control via SwipeController
/// - Swipe validation to prevent invalid navigation
/// - Smooth animations and transitions
/// - Custom item builders for flexible UI design
/// - Index change callbacks for state management
///
/// Usage:
/// ```dart
/// SwipableView<String>(
///   items: ['Page 1', 'Page 2', 'Page 3'],
///   initialIndex: 0,
///   onIndexChange: (index) => print('Current page: $index'),
///   builder: (context, item) => Center(child: Text(item)),
///   onSwipe: (direction) => print('Swiped $direction'),
///   canSwipe: (nextIndex, direction) => nextIndex >= 0 && nextIndex < items.length,
/// )
/// ```
class SwipableView<T> extends StatefulWidget {
  /// The list of items to display in the swipable view
  final List<T> items;

  /// The initial index to display when the widget is first built
  final int initialIndex;

  /// Optional controller for programmatic navigation
  final SwipeController? controller;

  /// Callback function called when the current index changes
  final void Function(int) onIndexChange;

  /// Optional callback function called when a swipe gesture is completed
  final SwipeCallback? onSwipe;

  /// Optional validation function to determine if a swipe should be allowed
  final SwipeValidationCallback? canSwipe;

  /// Builder function for creating the UI for each item
  final SwipableViewBuilder<T> builder;

  /// The direction of scrolling (horizontal or vertical)
  final Axis scrollDirection;

  /// The minimum distance required to trigger a swipe gesture
  final double swipeThreshold;

  /// Creates a SwipableView widget
  ///
  /// [items] - The list of items to display
  /// [initialIndex] - The starting index (will be clamped to valid range)
  /// [onIndexChange] - Callback for index changes
  /// [builder] - Function to build each item's UI
  /// [controller] - Optional controller for programmatic navigation
  /// [onSwipe] - Optional callback for swipe events
  /// [canSwipe] - Optional validation for swipe gestures
  /// [scrollDirection] - Direction of scrolling (defaults to horizontal)
  /// [swipeThreshold] - Minimum swipe distance (defaults to 80.0)
  const SwipableView({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onIndexChange,
    required this.builder,
    this.controller,
    this.onSwipe,
    this.canSwipe,
    this.scrollDirection = Axis.horizontal,
    this.swipeThreshold = 80.0,
  });

  @override
  State<SwipableView<T>> createState() => _SwipableViewState<T>();
}

/// State class for SwipableView widget
///
/// Manages the internal state of the swipable view including page navigation,
/// gesture handling, and controller management. This class handles all the
/// complex logic for swipe detection, validation, and smooth transitions.
class _SwipableViewState<T> extends State<SwipableView<T>> {
  /// Controller for managing page navigation
  late PageController _pageController;

  /// Current active page index
  late int _currentIndex;

  /// Starting position of the current pan gesture
  double _panStartPosition = 0.0;

  /// Whether a pan gesture is currently in progress
  bool _isPanning = false;

  /// Initializes the page controller and sets up the initial state
  ///
  /// This method clamps the initial index to a valid range, creates the
  /// PageController, and attaches any provided external controller.
  void _initController() {
    int initialPage = widget.initialIndex.clamp(0, widget.items.length - 1);
    _currentIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
    widget.controller?.attach(_pageController, () => _currentIndex);
  }

  /// Navigates to the previous page with smooth animation
  void _prev() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Navigates to the next page with smooth animation
  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Handles the start of a pan gesture
  ///
  /// Records the starting position and sets the panning state to true.
  /// The position is tracked according to the configured scroll direction.
  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = widget.scrollDirection == Axis.horizontal
        ? details.localPosition.dx
        : details.localPosition.dy;
    _isPanning = true;
  }

  /// Handles pan gesture updates and determines when to trigger navigation
  ///
  /// This method analyzes the pan movement to determine if a swipe should
  /// be triggered. It checks:
  /// 1. Movement distance exceeds the swipe threshold
  /// 2. Velocity is sufficient (> 1.0)
  /// 3. Swipe validation passes (if provided)
  ///
  /// When conditions are met, it triggers navigation and calls callbacks.
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isPanning) return;

    final currentPosition = widget.scrollDirection == Axis.horizontal
        ? details.localPosition.dx
        : details.localPosition.dy;

    final delta = currentPosition - _panStartPosition;
    final velocity = widget.scrollDirection == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;

    // Check if swipe threshold and velocity requirements are met
    if (delta.abs() > widget.swipeThreshold && velocity.abs() > 1.0) {
      final isForward = delta < 0; // Negative delta = forward swipe
      final isReverse = delta > 0; // Positive delta = backward swipe

      if (isForward) {
        // Validate forward swipe
        final canSwipeForward =
            widget.canSwipe?.call(_currentIndex + 1, SwipeDirection.forward) ??
            true;
        if (canSwipeForward) {
          widget.onSwipe?.call(SwipeDirection.forward);
          _next();
          _isPanning = false;
        }
      } else if (isReverse) {
        // Validate backward swipe
        final canSwipeBackward =
            widget.canSwipe?.call(_currentIndex - 1, SwipeDirection.backward) ??
            true;
        if (canSwipeBackward) {
          widget.onSwipe?.call(SwipeDirection.backward);
          _prev();
          _isPanning = false;
        }
      }
    }
  }

  /// Handles the end of a pan gesture
  ///
  /// Resets the panning state to false, allowing new gestures to be processed.
  void _handlePanEnd(DragEndDetails details) {
    _isPanning = false;
  }

  /// Handles page change events from the PageView
  ///
  /// Updates the current index state and notifies the parent widget
  /// through the onIndexChange callback.
  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
    widget.onIndexChange(index);
  }

  /// Builds a widget for the item at the specified index
  ///
  /// Returns an empty SizedBox if the index is out of bounds,
  /// otherwise uses the provided builder function to create the widget.
  Widget _buildItem(BuildContext context, int index) {
    if (index < 0 || index >= widget.items.length) {
      return const SizedBox.shrink();
    }
    return widget.builder(context, widget.items[index]);
  }

  /// Initializes the widget state
  ///
  /// Sets up the page controller and initial state when the widget is created.
  @override
  void initState() {
    super.initState();
    _initController();
  }

  /// Handles widget updates when properties change
  ///
  /// Responds to changes in initialIndex or items list by updating
  /// the current index and jumping to the appropriate page.
  @override
  void didUpdateWidget(SwipableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle initial index changes
    if (oldWidget.initialIndex != widget.initialIndex) {
      final newIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
      _currentIndex = newIndex;
      _pageController.jumpToPage(newIndex);
    }

    // Handle items list changes
    if (oldWidget.items != widget.items) {
      final validIndex = _currentIndex.clamp(0, widget.items.length - 1);
      if (validIndex != _currentIndex) {
        _currentIndex = validIndex;
        _pageController.jumpToPage(validIndex);
      }
    }
  }

  /// Disposes of resources when the widget is destroyed
  ///
  /// Cleans up the controller and page controller to prevent memory leaks.
  @override
  void dispose() {
    widget.controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Builds the swipable view widget
  ///
  /// Creates a PageView wrapped in a RawGestureDetector for custom swipe handling.
  /// The PageView is configured with:
  /// - Custom page controller for navigation
  /// - Disabled physics to prevent default scrolling
  /// - Infinite item count for seamless navigation
  /// - Custom gesture recognizer for swipe detection
  ///
  /// Returns an empty widget if no items are provided.
  @override
  Widget build(BuildContext context) {
    // Return empty widget if no items to display
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // Create the PageView with custom configuration
    Widget child = PageView.builder(
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      itemCount: null, // Infinite scrolling
      physics:
          const NeverScrollableScrollPhysics(), // Disable default scrolling
      onPageChanged: _handlePageChanged,
      itemBuilder: _buildItem,
    );

    // Wrap with custom gesture detector for swipe handling
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _DelayedPanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_DelayedPanGestureRecognizer>(
              () => _DelayedPanGestureRecognizer(
                swipeThreshold: widget.swipeThreshold,
                scrollDirection: widget.scrollDirection,
              ),
              (_DelayedPanGestureRecognizer instance) {
                instance
                  ..onStart = _handlePanStart
                  ..onUpdate = _handlePanUpdate
                  ..onEnd = _handlePanEnd;
              },
            ),
      },
      child: child,
    );
  }
}
