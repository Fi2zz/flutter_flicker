import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Abstract base class for pagination data management with grid layout support
///
/// Handles data generation, grouping into rows, and pagination logic
/// for infinite scroll pagination with grid layouts.
// abstract
class DataManager<T> {
  /// Hard-coded configuration values for year grid pagination
  static const int columns = 4;
  static const int itemsPerPage = 20;
  static const int rowsPerPage = 5; // itemsPerPage / columns

  final int startValue;

  /// End value of the range (inclusive)
  final int endValue;

  /// Height of each grid item
  final double estimatedItemHeight;

  /// Cache for generated data rows by page
  final Map<int, List<List<int>>> _pageDataCache = {};

  /// Total data length (calculated once)
  int? _totalDataLength;

  /// All data items (generated once and cached)
  List<int>? _allDataItems;

  /// Paging controller for infinite scroll
  late PagingController<int, List<int>> _pagingController;

  /// Creates a pagination data manager
  DataManager({
    required this.startValue,
    required this.endValue,
    required this.estimatedItemHeight,
  }) {
    _initializePagingController();
  }

  /// Abstract method to generate all data items
  /// Subclasses must implement this method to provide data generation logic
  // List<T> generateAllData();

  /// Gets the paging controller
  PagingController<int, List<int>> get pagingController => _pagingController;

  /// Gets total number of data rows
  int get totalDataRows {
    _ensureDataGenerated();
    return (_totalDataLength! / columns).ceil();
  }

  /// Initializes the paging controller
  void _initializePagingController() {
    _pagingController = PagingController<int, List<int>>(
      getNextPageKey: (state) {
        if (state.error != null) return null;
        final currentPageKey = state.keys?.isNotEmpty == true ? state.keys!.last : -1;
        final nextPageKey = currentPageKey + 1;
        final startRowIndex = nextPageKey * rowsPerPage;
        return startRowIndex >= totalDataRows ? null : nextPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  /// Ensures data is generated and cached
  void _ensureDataGenerated() {
    if (_allDataItems == null) {
      _allDataItems = generateAllData();
      _totalDataLength = _allDataItems!.length;
    }
  }

  /// Generates data rows for a specific page on demand
  List<List<int>> generatePageRows(int pageKey) {
    _ensureDataGenerated();

    // Check cache first
    if (_pageDataCache.containsKey(pageKey)) {
      return _pageDataCache[pageKey]!;
    }

    final startRowIndex = pageKey * rowsPerPage;
    final endRowIndex = (startRowIndex + rowsPerPage).clamp(0, totalDataRows);

    final pageRows = <List<int>>[];

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

    // Cache the generated page
    _pageDataCache[pageKey] = pageRows;
    return pageRows;
  }

  /// Finds the row index containing the target item
  ///
  /// - [predicate]: Function to test if an item matches the target
  /// Returns the row index, or 0 if not found
  int findRowIndexForItem(bool Function(int item) predicate) {
    _ensureDataGenerated();

    for (int i = 0; i < _allDataItems!.length; i++) {
      if (predicate(_allDataItems![i])) {
        return i ~/ columns; // Convert item index to row index
      }
    }
    return 0; // Default to first row if not found
  }

  /// Calculates scroll offset for a specific row index
  ///
  /// - [rowIndex]: Target row index
  /// Returns the estimated scroll offset
  double calculateScrollOffset(int rowIndex) {
    return rowIndex * estimatedItemHeight;
  }

  /// Finds the row index containing a specific item value
  ///
  /// - [targetItem]: Target item to find
  /// Returns the row index, or 0 if not found
  int findRowIndexForValue(T targetItem) {
    return findRowIndexForItem((item) => item == targetItem);
  }

  /// Calculates scroll offset for a specific item value
  ///
  /// - [targetItem]: Target item
  /// Returns the estimated scroll offset
  double calculateScrollOffsetForValue(T targetItem) {
    final rowIndex = findRowIndexForValue(targetItem);
    return calculateScrollOffset(rowIndex);
  }

  /// Fetches page data for infinite scroll pagination
  Future<List<List<int>>> _fetchPage(int pageKey) async {
    try {
      final pageRows = generatePageRows(pageKey);
      return pageRows;
    } catch (error) {
      rethrow;
    }
  }

  /// Refreshes the pagination data
  void refresh() {
    // Clear caches
    _pageDataCache.clear();
    _allDataItems = null;
    _totalDataLength = null;
    _pagingController.refresh();
  }

  /// Generates all data rows (for backward compatibility)
  void generateAllDataRows() {
    // This method is kept for backward compatibility
    // but now it just ensures data is generated
    _ensureDataGenerated();
  }

  /// Disposes the paging controller
  void dispose() {
    _pagingController.dispose();
  }

  List<int> generateAllData() {
    int start = startValue;
    int end = endValue;

    final result = <int>[];
    for (int i = start; i <= end; i++) {
      result.add(i);
    }

    // Ensure the data count is divisible by itemsPerPage
    final remainder = result.length % itemsPerPage;
    if (remainder != 0) {
      // Add additional items to make it divisible by itemsPerPage
      final itemsToAdd = itemsPerPage - remainder;
      for (int i = 0; i < itemsToAdd; i++) {
        result.add(end + 1 + i);
      }
    }

    return result;
  }
}
