import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

/// Swipe direction enumeration
enum SwipeDirection {
  /// Forward swipe (next page)
  forward,

  /// Backward swipe (previous page)
  backward,
}

/// Generic swipable view builder function type
///
/// Receives the current item's index and data, returns the corresponding Widget
typedef GenericSwipableViewBuilder<T> =
    Widget Function(BuildContext context, T item);

/// Swipe callback function type
///
/// Called when a swipe gesture is detected, receives the swipe direction
typedef SwipeCallback = void Function(SwipeDirection direction);

/// Swipe validation callback function type
///
/// Called before a swipe gesture is executed to determine if the swipe is allowed
/// Returns true if the swipe in the given direction should be allowed, false otherwise
typedef SwipeValidationCallback =
    bool Function(int nextIndex, SwipeDirection direction);

/// Custom pan gesture recognizer that allows child gestures to compete
class _DelayedPanGestureRecognizer extends PanGestureRecognizer {
  final double swipeThreshold;
  final Axis scrollDirection;

  double _startPosition = 0.0;
  bool _hasResolvedConflict = false;

  _DelayedPanGestureRecognizer({
    required this.swipeThreshold,
    required this.scrollDirection,
  });

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    _startPosition = scrollDirection == Axis.horizontal
        ? event.position.dx
        : event.position.dy;
    _hasResolvedConflict = false;
  }

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

      // Only claim victory if this is clearly a page swipe gesture
      // - Significant movement in scroll direction
      // - High velocity indicating swipe intent
      if (totalDelta > swipeThreshold * 0.3 && velocity > 3.0) {
        _hasResolvedConflict = true;
        resolve(GestureDisposition.accepted);
      } else if (totalDelta > swipeThreshold * 0.8) {
        // If movement is very large, also claim it
        _hasResolvedConflict = true;
        resolve(GestureDisposition.accepted);
      }
    }
  }
}

/// Generic swipable view controller
///
/// Used for programmatic control of swipable view page switching, supports forward and backward swiping.
/// The controller automatically checks if the target page is disabled, avoiding swiping to invalid pages.
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// final controller = GenericSwipableController();
///
/// // Use in GenericSwipableView
/// GenericSwipableView(
///   controller: controller,
///   // ... other parameters
/// )
///
/// // Control swiping
/// controller.slide(1);   // Swipe forward 1 page
/// controller.slide(-1);  // Swipe backward 1 page
/// controller.slide(3);   // Swipe forward 3 pages
/// ```
class GenericSwipableController {
  PageController? _pageController;
  int Function()? _getCurrentIndex;

  /// Attach controller to GenericSwipableView
  ///
  /// This method is called internally by GenericSwipableView, users typically don't need to call it directly.
  ///
  /// - [pageController]: PageView controller
  /// - [disabledAt]: Function to check if specified index is disabled
  /// - [getCurrentIndex]: Function to get current page index
  void attach(PageController pageController, int Function() getCurrentIndex) {
    _pageController = pageController;
    _getCurrentIndex = getCurrentIndex;
  }

  /// Release controller resources
  ///
  /// This method is called internally by GenericSwipableView, users typically don't need to call it directly.
  void dispose() {
    _pageController = null;
    _getCurrentIndex = null;
  }

  /// Swipe to next or previous page
  ///
  /// - [step]: Number of swipe steps, positive numbers indicate forward swiping, negative numbers indicate backward swiping
  ///   - `slide(1)`: Next page
  ///   - `slide(-1)`: Previous page
  ///   - `slide(3)`: Swipe forward 3 pages
  ///   - `slide(-2)`: Swipe backward 2 pages
  ///
  /// If the target page is disabled or the controller is not properly initialized, the swipe operation will be ignored.
  /// Swipe animation duration is 300 milliseconds, using easeOut easing curve.
  void slide(int step) {
    if (_pageController == null || _getCurrentIndex == null) {
      return;
    }
    // Check if target page is disabled
    if (step > 0) {
      for (int i = 0; i < step; i++) {
        _pageController!.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } else if (step < 0) {
      for (int i = 0; i < -step; i++) {
        _pageController!.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }
}

/// Generic swipable view component
///
/// Supports horizontal and vertical swiping, provides custom data source and disabled item functionality.
/// Uses PageView and GestureDetector to implement custom swipe control.
///
/// ## Usage Examples
///
/// ### Basic Usage
/// ```dart
/// GenericSwipableView<String>(
///   items: ['Item 1', 'Item 2', 'Item 3'],
///   initialIndex: 0,
///   onIndexChange: (index) => print('Current index: $index'),
///   builder: (context, item) => Text(item),
/// )
/// ```
///
/// ### Using External Controller and Swipe Detection
/// ```dart
/// final controller = GenericSwipableController();
///
/// GenericSwipableView<int>(
///   controller: controller,
///   items: [1, 2, 3, 4, 5],
///   initialIndex: 2,
///   onIndexChange: (index) => print('Index: $index'),
///   onSwipe: (direction) {
///     if (direction == SwipeDirection.forward) {
///       print('Swiped forward');
///     } else {
///       print('Swiped backward');
///     }
///   },
///   canSwipe: (nextIndex, direction) {
///     // Custom logic to determine if swipe is allowed
///     if (direction == SwipeDirection.forward && nextIndex < items.length) {
///       return true; // Allow forward swipe if not at end
///     } else if (direction == SwipeDirection.backward && nextIndex >= 0) {
///       return true; // Allow backward swipe if not at beginning
///     }
///     return false; // Prevent swipe otherwise
///   },
///   builder: (context, item) => Container(
///     child: Text('$item'),
///   ),
/// )
///
/// // Programmatic swipe control
/// controller.slide(1);  // Next page
/// controller.slide(-1); // Previous page
/// ```
class GenericSwipableView<T> extends StatefulWidget {
  /// Data source list
  final List<T> items;

  /// Initial display index
  final int initialIndex;

  /// External controller for programmatic swipe control
  final GenericSwipableController? controller;

  /// Optional item disable function
  ///
  /// Returns true if the item is disabled, false if available.
  /// Disabled items will prevent swiping to that page.
  final bool Function(T)? disabledItem;

  /// Index change callback function
  ///
  /// This function is called when the user swipes to switch pages, passing in the new index.
  final void Function(int) onIndexChange;

  /// Swipe direction callback function
  ///
  /// This function is called when a swipe gesture is detected, passing in the swipe direction.
  /// Called before the page actually changes.
  final SwipeCallback? onSwipe;

  /// Swipe validation callback function
  ///
  /// This function is called before a swipe gesture is executed to determine if the swipe is allowed.
  /// Returns true if the swipe in the given direction should be allowed, false otherwise.
  /// If not provided, swipes are allowed by default (subject to other constraints like disabled items).
  final SwipeValidationCallback? canSwipe;

  /// Custom builder function
  ///
  /// Used to build the view content for each item, receiving the current item's data.
  final GenericSwipableViewBuilder<T> builder;

  /// Swipe direction
  ///
  /// [Axis.horizontal] indicates horizontal swiping (default), [Axis.vertical] indicates vertical swiping.
  final Axis scrollDirection;

  /// Swipe threshold
  ///
  /// Minimum swipe distance required to trigger page switching, defaults to 80.0.
  final double swipeThreshold;

  /// Create generic swipable view
  ///
  /// ## Parameter Description
  /// - [items]: Data source list (required)
  /// - [initialIndex]: Initial display index (required)
  /// - [onIndexChange]: Index change callback (required)
  /// - [builder]: Custom builder (required)
  /// - [disabledItem]: Item disable function (optional)
  /// - [controller]: External controller (optional)
  /// - [onSwipe]: Swipe direction callback (optional)
  /// - [canSwipe]: Swipe validation callback (optional)
  /// - [scrollDirection]: Swipe direction (default horizontal)
  /// - [swipeThreshold]: Swipe threshold (default 80.0)
  const GenericSwipableView({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onIndexChange,
    required this.builder,
    this.disabledItem,
    this.controller,
    this.onSwipe,
    this.canSwipe,
    this.scrollDirection = Axis.horizontal,
    this.swipeThreshold = 80.0,
  });

  @override
  State<GenericSwipableView<T>> createState() => _GenericSwipableViewState<T>();
}

class _GenericSwipableViewState<T> extends State<GenericSwipableView<T>> {
  late PageController _pageController;
  late int _currentIndex;

  // Swipe state tracking
  double _panStartPosition = 0.0;
  bool _isPanning = false;

  /// Initialize page controller
  void _initController() {
    int initialPage = widget.initialIndex.clamp(0, widget.items.length - 1);
    _currentIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
    widget.controller?.attach(_pageController, () => _currentIndex);
  }

  /// Switch to previous page
  void _prev() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Switch to next page
  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// Handle swipe start gesture
  void _handlePanStart(DragStartDetails details) {
    _panStartPosition = widget.scrollDirection == Axis.horizontal
        ? details.localPosition.dx
        : details.localPosition.dy;
    _isPanning = true;
  }

  /// Handle swipe update gesture, implement real-time swipe detection
  void _handlePanUpdate(DragUpdateDetails details) {
    if (!_isPanning) return;

    final currentPosition = widget.scrollDirection == Axis.horizontal
        ? details.localPosition.dx
        : details.localPosition.dy;

    final delta = currentPosition - _panStartPosition;
    final velocity = widget.scrollDirection == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;

    // Only handle swipe if it's a significant movement in the scroll direction
    // and the velocity indicates a clear swipe intention
    if (delta.abs() > widget.swipeThreshold && velocity.abs() > 1.0) {
      final isForward = delta < 0; // Forward swipe (next page)
      final isReverse = delta > 0; // Reverse swipe (previous page)

      // Check if swipe should be prevented
      if (isForward) {
        // Check if forward swipe is allowed
        final canSwipeForward =
            widget.canSwipe?.call(_currentIndex + 1, SwipeDirection.forward) ??
            true;
        if (canSwipeForward) {
          // Call onSwipe callback before page change
          widget.onSwipe?.call(SwipeDirection.forward);
          _next();
          _isPanning = false; // Prevent duplicate triggers
        }
      } else if (isReverse) {
        // Check if backward swipe is allowed
        final canSwipeBackward =
            widget.canSwipe?.call(_currentIndex - 1, SwipeDirection.backward) ??
            true;
        if (canSwipeBackward) {
          // Call onSwipe callback before page change
          widget.onSwipe?.call(SwipeDirection.backward);
          _prev();
          _isPanning = false; // Prevent duplicate triggers
        }
      }
    }
  }

  /// Handle swipe end gesture
  void _handlePanEnd(DragEndDetails details) {
    _isPanning = false;
  }

  /// Handle page change
  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onIndexChange(index);
  }

  /// Build single item
  Widget _buildItem(BuildContext context, int index) {
    if (index < 0 || index >= widget.items.length) {
      return const SizedBox.shrink();
    }
    return widget.builder(context, widget.items[index]);
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(GenericSwipableView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initial index has changed
    if (oldWidget.initialIndex != widget.initialIndex) {
      final newIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
      _currentIndex = newIndex;
      _pageController.jumpToPage(newIndex);
    }

    // Check if data source has changed
    if (oldWidget.items != widget.items) {
      // Ensure current index is still valid
      final validIndex = _currentIndex.clamp(0, widget.items.length - 1);
      if (validIndex != _currentIndex) {
        _currentIndex = validIndex;
        _pageController.jumpToPage(validIndex);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();
    Widget child = PageView.builder(
      controller: _pageController,
      scrollDirection: widget.scrollDirection,
      itemCount: null,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: _handlePageChanged,
      itemBuilder: _buildItem,
    );
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
