import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/src/views/flicker_shared.dart';
import '../src/views/flicker_years_view.dart';

/// Demo widget for FlickerYearsView component
///
/// Demonstrates the year selection view with customizable parameters:
/// - startYear: 1990
/// - endYear: 2030
/// - size: Size(280, 320)
/// - date: 2025-08-29
class FlickerYearsDemo extends StatefulWidget {
  const FlickerYearsDemo({super.key});

  @override
  State<FlickerYearsDemo> createState() => _FlickerYearsDemoState();
}

class _FlickerYearsDemoState extends State<FlickerYearsDemo> {
  /// Current selected date
  DateTime _selectedDate = DateTime(2025, 8, 29);

  /// Demo parameters as specified
  static const int _startYear = 1900;
  static const int _endYear = 2030;
  static const Size _viewSize = Size(
    gridViewWidth,
    gridViewHeight + gridBasicSize,
  );
  //  Size(300, 320);

  /// Handles year selection
  void _onYearSelected(int year) {
    setState(() {
      _selectedDate = DateTime(year, _selectedDate.month, _selectedDate.day);
    });
  }

  /// Handles title tap (placeholder for navigation back)
  void _onTitleTap() {
    // In a real app, this would navigate back to month view
    debugPrint('Title tapped - would navigate back to month view');
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          _buildDemoInfo(),
          Container(
            color: CupertinoColors.white,
            child: FlickerYearsView(
              date: _selectedDate,
              startYear: _startYear,
              endYear: _endYear,
              size: _viewSize,
              onTapYear: _onYearSelected,
              onTapTitle: _onTitleTap,
              itemHeight: gridBasicSize,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(color: CupertinoColors.systemGrey6),
      child: child,
    );
  }

  /// Builds demo parameter information
  Widget _buildDemoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text('• Start Year: $_startYear', style: style),
        Text('• End Year: $_endYear', style: style),
        Text('• Size: ${_viewSize.width} × ${_viewSize.height}', style: style),
        Text(
          '• Initial Date: ${_formatDate(DateTime(2025, 8, 29))}',
          style: style,
        ),
        Text('• Selected Date: ${_formatDate(_selectedDate)}', style: style),
        Text('• Selected Year: ${_selectedDate.year}', style: style),
      ],
    );
  }
}

TextStyle style = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: CupertinoColors.black,
);
