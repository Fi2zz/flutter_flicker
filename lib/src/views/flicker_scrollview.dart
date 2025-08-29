import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_flicker/src/views/flicker_scrollview_data_manager.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Integer range grid pagination view widget
///
/// Provides a reusable infinite scroll pagination view with grid layout
/// specifically designed for integer ranges (e.g., years, numbers).
class FlickerScrollView extends StatefulWidget {
  /// Start value of the integer range (inclusive)
  final int startValue;

  /// End value of the integer range (inclusive)
  final int endValue;

  /// Target value to scroll to initially
  final int initialValue;

  /// Builder function for individual grid items
  final Widget Function(BuildContext context, int item, int index) itemBuilder;

  /// Height of each grid item
  final double itemHeight;

  /// Creates an integer range grid pagination view
  ///
  /// - [startValue]: Start value of the integer range (inclusive)
  /// - [endValue]: End value of the integer range (inclusive)
  /// - [initialValue]: Target value to scroll to initially
  /// - [itemBuilder]: Builder function for individual grid items
  /// - [itemHeight]: Height of each grid item
  const FlickerScrollView({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.initialValue,
    required this.itemBuilder,
    required this.itemHeight,
  });

  @override
  State<FlickerScrollView> createState() => _FlickerScrollViewState();
}

class _FlickerScrollViewState extends State<FlickerScrollView> {
  late ScrollController _scrollController;
  late DataManager _dataManager;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _dataManager = DataManager(
      startValue: widget.startValue,
      endValue: widget.endValue,
      estimatedItemHeight: widget.itemHeight,
    );

    // Scroll to initial value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToValue(widget.initialValue);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PagingListener(
          controller: _dataManager.pagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, List<int>>(
              state: state,
              fetchNextPage: fetchNextPage,
              scrollController: _scrollController,
              padding: EdgeInsets.zero,
              builderDelegate: PagedChildBuilderDelegate<List<int>>(
                itemBuilder: (context, row, index) =>
                    _buildGridRow(context, row, constraints),
                firstPageProgressIndicatorBuilder: (_) => const SizedBox.shrink(),
                newPageProgressIndicatorBuilder: (_) => const SizedBox.shrink(),
                firstPageErrorIndicatorBuilder: (_) => const SizedBox.shrink(),
                newPageErrorIndicatorBuilder: (_) => const SizedBox.shrink(),
                noItemsFoundIndicatorBuilder: (_) => const SizedBox.shrink(),
                noMoreItemsIndicatorBuilder: (_) => const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }

  /// Scrolls to the initial target value (only works with int type)
  void _scrollToValue(int targetValue) {
    final targetRowIndex = _dataManager.findRowIndexForValue(targetValue);
    final targetPage = targetRowIndex ~/ DataManager.rowsPerPage;

    debugPrint('targetRowIndex: $targetRowIndex targetPage: $targetPage');

    // Load pages up to the target page
    _loadPagesUpTo(targetPage, _dataManager)
        .then((_) {
          debugPrint('_loadPagesUpTo completed successfully');
          final offset = _dataManager.calculateScrollOffsetForValue(
            targetValue,
          );
          debugPrint('offset: $offset');
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(offset);
          }
        })
        .catchError((error) {
          debugPrint('_loadPagesUpTo failed with error: $error');
          final offset = _dataManager.calculateScrollOffsetForValue(
            targetValue,
          );
          debugPrint('Fallback offset: $offset');
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(offset);
          }
        });
  }

  /// Loads pages up to the specified page index
  Future<void> _loadPagesUpTo(int targetPage, DataManager dataManager) async {
    debugPrint('_loadPagesUpTo: targetPage=$targetPage');

    try {
      dataManager.generatePageRows(targetPage);
      debugPrint('Target page $targetPage data pre-generated');
    } catch (e) {
      debugPrint('Error pre-generating target page data: $e');
    }

    for (int page = 0; page <= targetPage; page++) {
      if (await _isPageLoaded(page)) {
        debugPrint('Page $page already loaded, skipping');
        continue;
      }

      debugPrint('Loading page $page...');
      await _loadSinglePage(page);
    }

    debugPrint('_loadPagesUpTo completed for targetPage: $targetPage');
  }

  /// Checks if a specific page is already loaded
  Future<bool> _isPageLoaded(int page) async {
    final pagingController = _dataManager.pagingController;
    final currentLength = pagingController.items?.length ?? 0;
    final requiredRowsForPage = (page + 1) * DataManager.rowsPerPage;
    return currentLength >= requiredRowsForPage;
  }

  /// Loads a single page with timeout and error handling
  Future<void> _loadSinglePage(int page) async {
    final pagingController = _dataManager.pagingController;
    final completer = Completer<void>();
    late VoidCallback listener;

    listener = () {
      if (_isPageLoadedSync(page)) {
        debugPrint('Page $page loaded successfully');
        pagingController.removeListener(listener);
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    };

    try {
      pagingController.addListener(listener);

      if (page == 0) {
        pagingController.refresh();
      } else {
        pagingController.fetchNextPage();
      }

      await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('Page $page load timeout');
          throw TimeoutException(
            'Page load timeout',
            const Duration(seconds: 3),
          );
        },
      );
    } catch (e) {
      debugPrint('Error loading page $page: $e');
    } finally {
      pagingController.removeListener(listener);
    }
  }

  /// Synchronously checks if a page is loaded (helper method)
  bool _isPageLoadedSync(int page) {
    final pagingController = _dataManager.pagingController;
    final currentLength = pagingController.items?.length ?? 0;
    final requiredRowsForPage = (page + 1) * DataManager.rowsPerPage;
    return currentLength >= requiredRowsForPage;
  }

  /// Builds a grid row containing multiple items
  Widget _buildGridRow(
    BuildContext context,
    List<int> row,
    BoxConstraints constraints,
  ) {
    final itemWidth = constraints.maxWidth / DataManager.columns;
    final rowItems = <Widget>[];

    for (int i = 0; i < DataManager.columns; i++) {
      if (i < row.length) {
        final item = row[i];
        rowItems.add(
          SizedBox(
            width: itemWidth,
            height: widget.itemHeight,
            child: widget.itemBuilder(context, item, i),
          ),
        );
      } else {
        // Add empty space for incomplete rows
        rowItems.add(SizedBox(width: itemWidth, height: widget.itemHeight));
      }
    }

    return Row(children: rowItems);
  }
}
