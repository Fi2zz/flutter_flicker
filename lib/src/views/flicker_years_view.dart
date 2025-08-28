import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'flicker_date_title.dart';
import 'flicker_extensions.dart';
import 'flicker_shared.dart';

/// Year selection view component
///
/// Combines year selection view with a title header
/// Used when switching from month view to year view
class FlickerYearsView extends StatefulWidget {
  /// Current date for context
  final DateTime date;

  /// Year selection callback
  final ValueChanged<int> onSelect;

  /// Optional callback for title tap (back to month view)
  final Function() onTapTitle;

  /// Minimum selectable year
  final int? startYear;

  /// Maximum selectable year
  final int? endYear;

  /// Size for the component
  final Size size;

  /// Creates a year selection view
  ///
  /// - [date]: Current date for context
  /// - [onSelect]: Year selection callback
  /// - [onTapTitle]: Optional callback for title tap (back to month view)
  /// - [startYear]: Minimum selectable year
  /// - [endYear]: Maximum selectable year
  /// - [size]: Size for the component
  const FlickerYearsView({
    super.key,
    required this.date,
    required this.onSelect,
    required this.onTapTitle,
    required this.size,
    this.startYear,
    this.endYear,
  });
  @override
  State<FlickerYearsView> createState() => _FlickerYearsViewState();
}

class _FlickerYearsViewState extends State<FlickerYearsView> {
  /// Grid column count (4 columns per row)
  static const int _columns = 4;

  /// Items per page for pagination
  static const int _itemsPerPage = 20;

  /// Paging controller for infinite scroll (using List<int> for rows)
  late PagingController<int, List<int>> _pagingController;

  /// Scroll controller
  final ScrollController _scrollController = ScrollController();

  /// All year rows data (pre-generated for efficient scrolling)
  final List<List<int>> _allYearRows = [];

  @override
  void initState() {
    super.initState();
    // Calculate year range to ensure we can scroll to all valid years
    // Use startYear if provided, otherwise start from 100 years before current year
    final startYear = widget.startYear ?? DateTime.now().year - 100;
    final endYear = widget.endYear ?? DateTime.now().year + 100;

    // Generate all years and group into rows
    _generateAllYearRows(startYear, endYear);

    // Initialize paging controller with all data
    _pagingController = PagingController(firstPageKey: 0);
    _pagingController.addPageRequestListener(_fetchPage);
    // After initialization, scroll to the current year's position
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentYear());
  }

  /// Generates all year rows from start to end year
  void _generateAllYearRows(int startYear, int endYear) {
    final years = <int>[];

    // Generate all years in the range
    for (int year = startYear; year <= endYear; year++) {
      years.add(year);
    }

    // Group years into rows of _columns
    _allYearRows.clear();
    for (int i = 0; i < years.length; i += _columns) {
      final end = (i + _columns).clamp(0, years.length);
      _allYearRows.add(years.sublist(i, end));
    }
  }

  /// Finds the row index containing the target year
  int _findRowIndexForYear(int targetYear) {
    for (int i = 0; i < _allYearRows.length; i++) {
      if (_allYearRows[i].contains(targetYear)) {
        return i;
      }
    }
    return 0; // Default to first row if not found
  }

  /// Scrolls to current year's position
  void _scrollToCurrentYear() {
    final targetRowIndex = _findRowIndexForYear(widget.date.year);

    // Estimate item height and scroll to position
    final estimatedItemHeight = 60.0; // Approximate height per row
    final offset = targetRowIndex * estimatedItemHeight;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(offset);
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetches page data for infinite scroll pagination
  void _fetchPage(int pageKey) {
    try {
      final rowsPerPage = (_itemsPerPage / _columns).ceil();
      final startIndex = pageKey * rowsPerPage;
      final endIndex = (startIndex + rowsPerPage).clamp(0, _allYearRows.length);

      // Check if we've reached the end of data
      if (startIndex >= _allYearRows.length) {
        _pagingController.appendLastPage([]);
        return;
      }

      final pageRows = _allYearRows.sublist(startIndex, endIndex);

      // Check if this is the last page
      final isLastPage = endIndex >= _allYearRows.length;

      if (isLastPage) {
        _pagingController.appendLastPage(pageRows);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(pageRows, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: widget.size.width,
          height: gridBasicSize,
          child: FlickerDateTitle(
            date: widget.date,
            onTap: widget.onTapTitle,
            roate: true,
            showTriangle: true,
          ),
        ),
        SizedBox.fromSize(size: widget.size, child: _buildYearGrid()),
      ],
    );
  }

  /// Builds the year grid component using PagedListView with custom grid layout
  Widget _buildYearGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PagedListView<int, List<int>>(
          scrollController: _scrollController,
          pagingController: _pagingController,
          padding: EdgeInsets.zero,
          builderDelegate: PagedChildBuilderDelegate<List<int>>(
            itemBuilder: (context, yearRow, index) =>
                _buildGridRow(context, yearRow, constraints),
          ),
        );
      },
    );
  }

  /// Builds a grid row containing multiple year items
  Widget _buildGridRow(
    BuildContext context,
    List<int> yearRow,
    BoxConstraints constraints,
  ) {
    final itemWidth = constraints.maxWidth / _columns;
    final rowItems = <Widget>[];

    for (int i = 0; i < _columns; i++) {
      if (i < yearRow.length) {
        rowItems.add(
          SizedBox(
            width: itemWidth,
            height: gridBasicSize,
            child: _buildYearItem(context, yearRow[i]),
          ),
        );
      } else {
        // Add empty space for incomplete rows
        rowItems.add(SizedBox(width: itemWidth, height: gridBasicSize));
      }
    }

    return Row(children: rowItems);
  }

  /// Builds a single year item
  ///
  /// - [year]: The year to display
  Widget _buildYearItem(BuildContext context, int year) {
    final theme = context.flickerTheme;
    final isSelected = year == widget.date.year;

    // Disable if year is out of the allowed range
    final isDisabled =
        (widget.startYear != null && year < widget.startYear!) ||
        (widget.endYear != null && year > widget.endYear!);

    return Tappable(
      tappable: !isDisabled,
      onTap: () => widget.onSelect(year),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: theme.getDayDecoration(
          selected: isSelected,
          disabled: isDisabled,
        ),
        alignment: Alignment.center,
        child: Text(
          year.toString(),
          style: theme.getDayTextStyle(isSelected, isDisabled, null),
        ),
      ),
    );
  }
}
