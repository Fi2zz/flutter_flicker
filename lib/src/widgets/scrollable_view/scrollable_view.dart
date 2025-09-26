import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// A high-performance scrollable view with pagination support
///
/// This widget creates a scrollable grid view that efficiently handles large
/// datasets using pagination. It's optimized for displaying ranges of values
/// (like years) in a 4-column grid layout with smooth scrolling and automatic
/// positioning to initial values.
///
/// ## Features
/// - **Pagination**: Efficient loading of large datasets in chunks
/// - **Auto-positioning**: Automatically scrolls to initial value on load
/// - **Grid layout**: 4-column responsive grid with consistent item sizing
/// - **Performance**: Lazy loading and memory-efficient rendering
/// - **Customizable**: Custom item builders for flexible content
///
/// ## Usage
/// ```dart
/// ScrollableView(
///   startValue: 1900,
///   endValue: 2100,
///   initialValue: 2024,
///   itemHeight: 50.0,
///   itemBuilder: (context, item, index) {
///     return Text('$item');
///   },
/// )
/// ```
class ScrollableView extends StatefulWidget {
  /// The starting value of the data range
  final int startValue;

  /// The ending value of the data range
  final int endValue;

  /// The initial value to scroll to when the widget loads
  final int initialValue;

  /// Builder function for creating individual item widgets
  ///
  /// Called for each item in the grid with the context, item value, and
  /// column index within the row.
  final Widget Function(BuildContext context, int item, int index) itemBuilder;

  /// Height of each item in the grid
  final double itemHeight;

  /// Creates a scrollable view
  const ScrollableView({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.initialValue,
    required this.itemBuilder,
    required this.itemHeight,
  });

  @override
  State<ScrollableView> createState() => _ScrollableViewState();
}

/// State class for ScrollableView widget
class _ScrollableViewState extends State<ScrollableView> {
  /// Controller for managing scroll position and behavior
  late ScrollController _scrollController;

  /// Data manager for handling pagination and data generation
  late Manager _dataManager;

  /// Initializes the widget state
  ///
  /// Sets up the scroll controller and data manager, then schedules
  /// an automatic scroll to the initial value after the widget is built.
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _dataManager = Manager(
      startValue: widget.startValue,
      endValue: widget.endValue,
      itemHeight: widget.itemHeight,
    );
    // Schedule scroll to initial value after widget is built
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToValue(widget.initialValue),
    );
  }

  /// Cleans up resources when the widget is disposed
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Builds the scrollable view widget
  ///
  /// Creates a responsive layout with pagination support. Uses LayoutBuilder
  /// to get constraints for proper item sizing, and PagingListener to handle
  /// pagination state and loading.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return PagingListener(
          controller: _dataManager.pagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, List<int>>(
              state: state,
              fetchNextPage: fetchNextPage,
              scrollController: _scrollController,
              padding: EdgeInsets.zero,
              builderDelegate: PagedChildBuilderDelegate<List<int>>(
                // Hide all loading/error indicators for clean appearance
                firstPageProgressIndicatorBuilder: _shrink,
                newPageProgressIndicatorBuilder: _shrink,
                firstPageErrorIndicatorBuilder: _shrink,
                newPageErrorIndicatorBuilder: _shrink,
                noItemsFoundIndicatorBuilder: _shrink,
                noMoreItemsIndicatorBuilder: _shrink,
                itemBuilder: (ctx, row, index) => _builder(ctx, row, c),
              ),
            );
          },
        );
      },
    );
  }

  /// Returns an empty widget for hiding indicators
  ///
  /// Used to hide loading and error indicators for a cleaner appearance.
  Widget _shrink(_) {
    return const SizedBox.shrink();
  }

  /// Scrolls to a specific target value
  ///
  /// Calculates the target page and row index, loads necessary pages,
  /// then scrolls to the calculated offset. Handles errors gracefully
  /// by still attempting to scroll even if page loading fails.
  ///
  /// [targetValue] The value to scroll to
  void _scrollToValue(int targetValue) {
    final targetRowIndex = _dataManager.findRowIndexForValue(targetValue);
    final targetPage = targetRowIndex ~/ Manager.rowsPerPage;

    _loadPagesUpTo(targetPage, _dataManager)
        .then((_) {
          final offset = _dataManager.calculateScrollOffsetForValue(
            targetValue,
          );
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(offset);
          }
        })
        .catchError((error) {
          // Even if page loading fails, try to scroll to the calculated position
          final offset = _dataManager.calculateScrollOffsetForValue(
            targetValue,
          );
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(offset);
          }
        });
  }

  /// Loads all pages up to the target page
  ///
  /// Pre-generates the target page data and then sequentially loads
  /// all pages from 0 to the target page to ensure smooth scrolling.
  ///
  /// [targetPage] The page number to load up to
  /// [dataManager] The data manager instance
  Future<void> _loadPagesUpTo(int targetPage, Manager dataManager) async {
    try {
      // Pre-generate target page data for faster access
      dataManager.generatePageRows(targetPage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error pre-generating target page data: $e');
      }
    }

    // Load all pages sequentially up to target
    for (int page = 0; page <= targetPage; page++) {
      if (await _isPageLoaded(page)) {
        continue; // Skip already loaded pages
      }

      await _loadSinglePage(page);
    }
  }

  /// Checks if a specific page is already loaded
  ///
  /// Determines if the paging controller has enough items to cover
  /// the specified page number.
  ///
  /// [page] The page number to check
  /// Returns true if the page is loaded, false otherwise
  Future<bool> _isPageLoaded(int page) async {
    final pagingController = _dataManager.pagingController;
    final currentLength = pagingController.items?.length ?? 0;
    final requiredRowsForPage = (page + 1) * Manager.rowsPerPage;
    return currentLength >= requiredRowsForPage;
  }

  /// Loads a single page with timeout and error handling
  ///
  /// Uses a completer and listener pattern to wait for the page to load.
  /// Includes timeout protection and proper cleanup of listeners.
  ///
  /// [page] The page number to load
  Future<void> _loadSinglePage(int page) async {
    final pagingController = _dataManager.pagingController;
    final completer = Completer<void>();
    late VoidCallback listener;

    // Set up listener to detect when page is loaded
    listener = () {
      if (_isPageLoadedSync(page)) {
        pagingController.removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    };

    try {
      pagingController.addListener(listener);

      // Trigger page loading
      if (page == 0) {
        pagingController.refresh(); // Refresh for first page
      } else {
        pagingController.fetchNextPage(); // Fetch for subsequent pages
      }

      // Wait for completion with timeout
      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException(
            'Page load timeout',
            const Duration(seconds: 3),
          );
        },
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading page $page: $e');
      }
    } finally {
      // Always clean up listener
      pagingController.removeListener(listener);
    }
  }

  /// Synchronously checks if a page is loaded
  ///
  /// Similar to [_isPageLoaded] but returns immediately without async.
  ///
  /// [page] The page number to check
  /// Returns true if the page is loaded, false otherwise
  bool _isPageLoadedSync(int page) {
    final pagingController = _dataManager.pagingController;
    final currentLength = pagingController.items?.length ?? 0;
    final requiredRowsForPage = (page + 1) * Manager.rowsPerPage;
    return currentLength >= requiredRowsForPage;
  }

  /// Builds a row widget from a list of items
  ///
  /// Creates a horizontal row with evenly distributed items. Each item
  /// is sized according to the available width divided by the number of columns.
  /// Empty spaces are filled with sized boxes to maintain consistent layout.
  ///
  /// [context] The build context
  /// [row] List of items for this row
  /// [constraints] Layout constraints for sizing calculations
  /// Returns a Row widget containing the items
  Widget _builder(
    BuildContext context,
    List<int> row,
    BoxConstraints constraints,
  ) {
    final itemWidth = constraints.maxWidth / Manager.columns;
    final rowItems = <Widget>[];

    // Build each column in the row
    for (int i = 0; i < Manager.columns; i++) {
      if (i < row.length) {
        // Build actual item widget
        final item = row[i];
        rowItems.add(
          SizedBox(
            width: itemWidth,
            height: widget.itemHeight,
            child: widget.itemBuilder(context, item, i),
          ),
        );
      } else {
        // Fill empty space to maintain grid alignment
        rowItems.add(SizedBox(width: itemWidth, height: widget.itemHeight));
      }
    }

    return Row(children: rowItems);
  }
}
