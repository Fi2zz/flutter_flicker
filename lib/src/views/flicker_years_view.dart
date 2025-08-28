import 'package:flutter/widgets.dart';
import 'flicker_shared.dart';
import 'flicker_swipable_view.dart';
import 'flicker_extensions.dart';
import 'flicker_date_title.dart';

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

  /// Create year selection view
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

  /// Edge append page count
  static const int _preloads = 2;

  /// Year pages list
  final List<List<int>> _yearPages = [];

  /// Swipe controller
  final SwipeController _controller = SwipeController();

  /// Whether it's first layout
  bool _firstLayout = true;

  /// Loading lock to prevent recursive loading
  bool _loading = false;

  /// Current page index
  int _currentPageIndex = 0;

  /// Last constraints for dynamic appending
  late BoxConstraints _lastConstraints;

  /// Calculate row count based on parent constraints
  ///
  /// - [constraint]: Parent constraints
  /// Returns the number of displayable rows
  int _calcRows(BoxConstraints constraint) {
    final cellWidth = constraint.maxWidth / _columns;
    final cellHeight = cellWidth / 2; // 高 = 宽/2
    return (constraint.maxHeight / cellHeight).floor();
  }

  /// Calculate items per page
  int _perPage(BoxConstraints c) => _calcRows(c) * _columns;

  /// Initialize year pages
  ///
  /// Calculate initial year range based on parent constraints and date restrictions
  void _initYearPages(BoxConstraints c) {
    final now = DateTime.now().year;
    final perPage = _perPage(c);

    // Calculate year range based on startYear and endYear if provided
    int startYearValue, endYearValue;
    if (widget.startYear != null && widget.endYear != null) {
      startYearValue = widget.startYear! - perPage;
      endYearValue = widget.endYear! + perPage;
    } else {
      // Default range: 3 pages before and after current year
      startYearValue = now - 3 * perPage;
      endYearValue = now + 3 * perPage;
    }

    debugPrint('startYearValue: $startYearValue, endYearValue: $endYearValue');

    // Generate all years
    final allYears = List.generate(
      endYearValue - startYearValue + 1,
      (i) => startYearValue + i,
    );

    // Split into pages
    _yearPages.clear();
    for (int i = 0; i < allYears.length; i += perPage) {
      final end = (i + perPage).clamp(0, allYears.length);
      _yearPages.add(allYears.sublist(i, end));
    }
  }

  /// Calculate default scroll page
  ///
  /// Calculate initial page based on current selected year
  int _targetPage(BoxConstraints c) {
    final targetYear = widget.date.year;

    // Find which page contains the target year
    for (int i = 0; i < _yearPages.length; i++) {
      final page = _yearPages[i];
      if (page.isNotEmpty &&
          targetYear >= page.first &&
          targetYear <= page.last) {
        return i;
      }
    }

    // If not found, return middle page
    return (_yearPages.length / 2).floor();
  }

  /// Append year pages when needed
  ///
  /// When user scrolls to boundary, automatically append more years
  /// If startDate and endDate are set, no appending is done
  /// - [c]: Parent constraints
  /// - [prepend]: true for prepending, false for appending
  void _appendPages(BoxConstraints c, {bool prepend = false}) {
    if (_loading) return;

    // If startYear and endYear are set, disable dynamic appending
    if (widget.startYear != null && widget.endYear != null) return;

    _loading = true;
    final perPage = _perPage(c);

    setState(() {
      if (prepend && _yearPages.isNotEmpty) {
        final firstYear = _yearPages.first.first;
        final newPages = <List<int>>[];

        for (int i = 0; i < _preloads; i++) {
          final pageStartYear = firstYear - (i + 1) * perPage;
          final pageYears = List.generate(perPage, (j) => pageStartYear + j);
          newPages.insert(0, pageYears);
        }

        _yearPages.insertAll(0, newPages);
        _currentPageIndex += _preloads; // Adjust current index
      } else if (!prepend && _yearPages.isNotEmpty) {
        final lastYear = _yearPages.last.last;

        for (int i = 0; i < _preloads; i++) {
          final pageStartYear = lastYear + 1 + i * perPage;
          final pageYears = List.generate(perPage, (j) => pageStartYear + j);
          _yearPages.add(pageYears);
        }
      }
    });

    // Unlock
    WidgetsBinding.instance.addPostFrameCallback((_) => _loading = false);
  }

  /// Handle index change from SwipableView
  void _handleIndexChange(int index) {
    _currentPageIndex = index;

    // Check if we need to append pages
    if (index < _preloads) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appendPages(_lastConstraints, prepend: true);
      });
    } else if (index >= _yearPages.length - _preloads) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appendPages(_lastConstraints, prepend: false);
      });
    }
  }

  /// Check if swipe is allowed
  bool _canSwipe(int index, SwipeDirection direction) {
    if (direction == SwipeDirection.forward) {
      return index < _yearPages.length - 1;
    } else {
      return index > 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: gridViewWidth,
          height: gridBasicSize,
          child: FlickerDateTitle(
            date: widget.date,
            onTap: widget.onTapTitle,
            roate: true,
            showTriangle: true,
          ),
        ),
        SizedBox(
          width: gridViewWidth,
          height: gridViewHeight + gridBasicSize,
          child: _buildYearGrid(),
        ),
      ],
    );
  }

  /// Build the year grid component
  Widget _buildYearGrid() {
    // Use LayoutBuilder to get parent constraints
    return LayoutBuilder(
      builder: (context, constraints) {
        _lastConstraints = constraints;

        // Initialize only on first layout
        if (_firstLayout) {
          _initYearPages(constraints);
          _currentPageIndex = _targetPage(constraints);
          _firstLayout = false;
        }

        if (_yearPages.isEmpty) {
          return const SizedBox.shrink();
        }

        return SwipableView<List<int>>(
          items: _yearPages,
          initialIndex: _currentPageIndex,
          controller: _controller,
          scrollDirection: Axis.vertical,
          onIndexChange: _handleIndexChange,
          canSwipe: _canSwipe,
          builder: (context, yearPage) =>
              _buildPage(context, yearPage, constraints),
        );
      },
    );
  }

  /// Build single year page grid
  ///
  /// - [yearPage]: List of years for this page
  /// - [constraints]: Parent constraints
  Widget _buildPage(
    BuildContext context,
    List<int> yearPage,
    BoxConstraints constraints,
  ) {
    final theme = context.flickerTheme;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        childAspectRatio: 2,
      ),
      itemCount: yearPage.length,
      itemBuilder: (_, index) {
        final year = yearPage[index];
        final isSelected = year == widget.date.year;

        // Disable if out of range
        final isDisabled =
            widget.startYear != null && year < widget.startYear! ||
            widget.endYear != null && year > widget.endYear!;

        return Tappable(
          tappable: isDisabled == false,
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
      },
    );
  }
}
