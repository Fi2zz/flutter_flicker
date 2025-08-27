import 'package:flutter/widgets.dart';
import 'shared.dart';
// import '../theme/theme.dart';
import 'flicker_extensions.dart';

/// Year selection view component
///
/// Provides year grid selection functionality, supports vertical scrolling and infinite loading
class FlickerSwipableYearsView extends StatefulWidget {
  /// Currently selected year
  final int? value;

  /// Year selection callback
  final ValueChanged<int> onSelect;

  /// Create year selection view
  ///
  /// - [value]: Currently selected year
  /// - [onSelect]: Year selection callback
  const FlickerSwipableYearsView({
    super.key,
    this.value,
    required this.onSelect,
  });
  @override
  State<FlickerSwipableYearsView> createState() =>
      _FlickerSwipableYearsViewState();
}

class _FlickerSwipableYearsViewState extends State<FlickerSwipableYearsView> {
  /// Grid column count (4 columns per row)
  static const int _columns = 4;

  /// Edge append page count
  static const int _preloads = 2;

  /// Year list
  final List<int> _years = [];

  /// Page controller
  late PageController _controller;

  /// Whether it's first layout
  bool _firstLayout = true;

  /// Loading lock to prevent recursive loading
  bool _loading = false;

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

  /// Initialize year list
  ///
  /// Calculate initial year range based on parent constraints
  void _initYears(BoxConstraints c) {
    final now = DateTime.now().year;
    final perPage = _perPage(c);
    final start = now - 3 * perPage;
    final end = now + 3 * perPage;
    _years.addAll(List.generate(end - start + 1, (i) => start + i));
  }

  /// 计算默认滚动到的页码
  ///
  /// 根据当前选中年份计算初始页码
  int _targetPage(BoxConstraints c) {
    final targetYear = widget.value ?? DateTime.now().year;
    return ((targetYear - _years.first) / _perPage(c)).floor();
  }

  /// 向前/向后追加年份数据
  ///
  /// 当用户滚动到边界时，自动追加更多年份
  /// - [c]: 父级约束
  /// - [prepend]: true表示向前追加，false表示向后追加
  void _append(BoxConstraints c, {bool prepend = false}) {
    if (_loading) return;
    _loading = true;
    final perPage = _perPage(c);
    setState(() {
      if (prepend) {
        final newStart = _years.first - perPage * _preloads;
        _years.insertAll(
          0,
          List.generate(perPage * _preloads, (i) => newStart + i),
        );
        // 保持页码相对位置
        _controller.jumpToPage(_controller.page!.round() + _preloads);
      } else {
        final newEnd = _years.last + perPage * _preloads;
        _years.addAll(
          List.generate(
            perPage * _preloads,
            (i) => newEnd - perPage * _preloads + 1 + i,
          ),
        );
      }
    });
    // 解锁
    WidgetsBinding.instance.addPostFrameCallback((_) => _loading = false);
  }

  /// Check if append is needed when scrolling ends
  ///
  /// When user scrolls to boundary, check if more years need to be loaded
  void _handleScrollEnd(BoxConstraints c) {
    if (_loading) return;
    final page = _controller.page!.round();
    final totalPages = (_years.length / _perPage(c)).ceil();
    if (page < _preloads) {
      _append(c, prepend: true);
    } else if (page >= totalPages - _preloads) {
      _append(c, prepend: false);
    }
  }

  /// Calculate page count based on constraints
  int _itemCountByConstraints(BoxConstraints constraints) {
    return (_years.length / _perPage(constraints)).ceil();
  }

  /// Get year list for specified page
  List<int> _yearsCountByConstraint(BoxConstraints constraints, int pageIndex) {
    final start = pageIndex * _perPage(constraints);
    final end = (start + _perPage(constraints)).clamp(0, _years.length);
    return _years.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    // 使用 LayoutBuilder 获取父级约束
    return LayoutBuilder(
      builder: (context, constraints) {
        // 仅在第一次布局时初始化
        if (_firstLayout) {
          _initYears(constraints);
          _controller = PageController(initialPage: _targetPage(constraints));
          _firstLayout = false;
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification) {
              _handleScrollEnd(constraints);
            }
            return false;
          },
          child: PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            pageSnapping: false, // 关闭回弹/吸附
            physics: const ClampingScrollPhysics(), // 禁用 iOS 回弹
            itemCount: _itemCountByConstraints(constraints),
            itemBuilder: (_, pageIndex) =>
                _buildPage(context, pageIndex, constraints),
          ),
        );
      },
    );
  }

  /// 构建单页年份网格
  ///
  /// - [pageIndex]: 页码
  /// - [constraints]: 父级约束
  Widget _buildPage(
    BuildContext context,
    int pageIndex,
    BoxConstraints constraints,
  ) {
    final pageYears = _yearsCountByConstraint(constraints, pageIndex);
    final theme = context.flickerTheme;
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        childAspectRatio: 2,
      ),
      itemCount: pageYears.length,
      itemBuilder: (_, index) {
        final year = pageYears[index];
        final isSelected = year == widget.value;
        return Tappable(
          onTap: () => widget.onSelect(year),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: isSelected
                ? theme.getDayDecoration(selected: true)
                : null,
            alignment: Alignment.center,
            child: Text(
              year.toString(),
              style: theme.getDayTextStyle(isSelected, null, null),
            ),
          ),
        );
      },
    );
  }
}
