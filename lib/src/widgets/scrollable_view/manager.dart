import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// A data manager for paginated scrollable views with grid layout
///
/// This class manages data pagination for scrollable grid views, typically
/// used for year selection in date pickers. It handles data generation,
/// caching, and pagination logic for efficient scrolling performance.
///
/// ## Features
/// - **Pagination**: Efficient loading of data in chunks
/// - **Caching**: Intelligent caching of generated page data
/// - **Grid layout**: 4-column grid layout optimization
/// - **Performance**: Lazy loading and memory management
/// - **Search**: Fast item location and scroll positioning
///
/// ## Usage
/// ```dart
/// final manager = Manager<int>(
///   startValue: 1900,
///   endValue: 2100,
///   itemHeight: 50.0,
/// );
/// ```
class Manager<T> {
  /// Number of columns in the grid layout
  static const int columns = 4;

  /// Number of items per page for pagination
  static const int itemsPerPage = 20;

  /// Number of rows per page (itemsPerPage / columns)
  static const int rowsPerPage = 5;

  /// The starting value of the data range
  final int startValue;

  /// The ending value of the data range
  final int endValue;

  /// Height of each item in the grid
  final double itemHeight;

  /// Cache for storing generated page data to avoid regeneration
  final Map<int, List<List<int>>> _pageDataCache = {};

  /// Total length of all data items
  int? _totalDataLength;

  /// All data items generated from start to end value
  List<int>? _allDataItems;

  /// Controller for managing pagination state and loading
  late PagingController<int, List<int>> _pagingController;

  /// Creates a new Manager instance
  ///
  /// Initializes the manager with the specified data range and item height.
  /// Automatically sets up the paging controller and preloads the first page.
  Manager({
    required this.startValue,
    required this.endValue,
    required this.itemHeight,
  }) {
    _initializePagingController();
  }

  /// Gets the paging controller for use with scrollable widgets
  PagingController<int, List<int>> get pagingController => _pagingController;

  /// Gets the total number of rows in the grid
  ///
  /// Calculates the total rows by dividing total data length by columns
  /// and rounding up to accommodate partial rows.
  int get totalDataRows {
    _ensureDataGenerated();
    return (_totalDataLength! / columns).ceil();
  }

  /// Initializes the paging controller with pagination logic
  ///
  /// Sets up the controller with functions to determine next page keys
  /// and fetch page data. Also preloads the first page for immediate display.
  void _initializePagingController() {
    _pagingController = PagingController<int, List<int>>(
      getNextPageKey: (state) {
        if (state.error != null) return null;
        final currentPageKey = state.keys?.isNotEmpty == true
            ? state.keys!.last
            : -1;
        final nextPageKey = currentPageKey + 1;
        final startRowIndex = nextPageKey * rowsPerPage;
        return startRowIndex >= totalDataRows ? null : nextPageKey;
      },
      fetchPage: _fetchPage,
    );

    _preloadFirstPage();
  }

  /// Preloads the first page of data for immediate display
  ///
  /// Generates the first page data and sets it in the paging controller
  /// to avoid loading delays when the widget is first displayed.
  void _preloadFirstPage() {
    try {
      final firstPageData = generatePageRows(0);
      _pagingController.value = _pagingController.value.copyWith(
        pages: [firstPageData],
        keys: [0],
        hasNextPage: totalDataRows > rowsPerPage,
        isLoading: false,
        error: null,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Error preloading first page: $error');
      }
    }
  }

  /// Ensures that all data items have been generated
  ///
  /// Lazy initialization of data - only generates the full data set
  /// when it's first needed, improving startup performance.
  void _ensureDataGenerated() {
    if (_allDataItems == null) {
      _allDataItems = generateAllData();
      _totalDataLength = _allDataItems!.length;
    }
  }

  /// Generates rows of data for a specific page
  ///
  /// Creates a 2D array where each inner array represents a row of items.
  /// Uses caching to avoid regenerating the same page data multiple times.
  ///
  /// [pageKey] The page number to generate data for
  /// Returns a list of rows, where each row contains up to [columns] items
  List<List<int>> generatePageRows(int pageKey) {
    _ensureDataGenerated();

    // Return cached data if available
    if (_pageDataCache.containsKey(pageKey)) {
      return _pageDataCache[pageKey]!;
    }

    final startRowIndex = pageKey * rowsPerPage;
    final endRowIndex = (startRowIndex + rowsPerPage).clamp(0, totalDataRows);

    final pageRows = <List<int>>[];

    // Generate each row for this page
    for (int rowIndex = startRowIndex; rowIndex < endRowIndex; rowIndex++) {
      final startItemIndex = rowIndex * columns;
      final endItemIndex = (startItemIndex + columns).clamp(
        0,
        _allDataItems!.length,
      );

      if (startItemIndex < _allDataItems!.length) {
        pageRows.add(_allDataItems!.sublist(startItemIndex, endItemIndex));
      }
    }

    // Cache the generated data
    _pageDataCache[pageKey] = pageRows;
    return pageRows;
  }

  /// Finds the row index for an item matching the given predicate
  ///
  /// Searches through all data items and returns the row index of the first
  /// item that matches the predicate function.
  ///
  /// [predicate] Function to test each item
  /// Returns the row index (0-based) or 0 if not found
  int findRowIndexForItem(bool Function(int item) predicate) {
    _ensureDataGenerated();

    for (int i = 0; i < _allDataItems!.length; i++) {
      if (predicate(_allDataItems![i])) {
        return i ~/ columns; // Integer division to get row index
      }
    }
    return 0; // Default to first row if not found
  }

  /// Calculates the scroll offset for a given row index
  ///
  /// [rowIndex] The row index to calculate offset for
  /// Returns the pixel offset from the top of the scrollable area
  double calculateScrollOffset(int rowIndex) {
    return rowIndex * itemHeight;
  }

  /// Finds the row index for a specific target item
  ///
  /// [targetItem] The item to search for
  /// Returns the row index containing the target item
  int findRowIndexForValue(T targetItem) {
    return findRowIndexForItem((item) => item == targetItem);
  }

  /// Calculates the scroll offset needed to show a specific target item
  ///
  /// [targetItem] The item to scroll to
  /// Returns the pixel offset to scroll to show the target item
  double calculateScrollOffsetForValue(T targetItem) {
    final rowIndex = findRowIndexForValue(targetItem);
    return calculateScrollOffset(rowIndex);
  }

  /// Fetches page data asynchronously for the paging controller
  ///
  /// This method is called by the paging controller when new pages are needed.
  /// It delegates to [generatePageRows] for the actual data generation.
  ///
  /// [pageKey] The page number to fetch
  /// Returns a Future containing the page rows
  Future<List<List<int>>> _fetchPage(int pageKey) async {
    try {
      final pageRows = generatePageRows(pageKey);
      return pageRows;
    } catch (error) {
      rethrow;
    }
  }

  /// Refreshes all data and clears caches
  ///
  /// Clears the page cache, resets data generation, and refreshes
  /// the paging controller. Use this when the data range changes.
  void refresh() {
    _pageDataCache.clear();
    _allDataItems = null;
    _totalDataLength = null;
    _pagingController.refresh();
  }

  /// Forces generation of all data rows
  ///
  /// Ensures that the complete data set has been generated.
  /// This can be useful for preloading data.
  void generateAllDataRows() {
    _ensureDataGenerated();
  }

  /// Disposes of resources used by the manager
  ///
  /// Cleans up the paging controller to prevent memory leaks.
  /// Call this when the manager is no longer needed.
  void dispose() {
    _pagingController.dispose();
  }

  /// Generates the complete data set from start to end value
  ///
  /// Creates a list of integers from [startValue] to [endValue], then
  /// pads the list to ensure it's divisible by [itemsPerPage] for
  /// consistent pagination.
  ///
  /// Returns a list of all data items
  List<int> generateAllData() {
    int start = startValue;
    int end = endValue;

    // Generate the main data range
    final result = <int>[];
    for (int i = start; i <= end; i++) {
      result.add(i);
    }

    // Pad to make divisible by itemsPerPage for consistent pagination
    final remainder = result.length % itemsPerPage;
    if (remainder != 0) {
      final itemsToAdd = itemsPerPage - remainder;
      for (int i = 0; i < itemsToAdd; i++) {
        result.add(end + 1 + i);
      }
    }

    return result;
  }
}
