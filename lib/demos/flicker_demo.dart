import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';
import './flicker_years_demo.dart';
import 'package:flutter_flicker/demos/ui_constants.dart';
import './demo_constants.dart';

/// Demo picker mode enumeration
///
/// Defines the different demo modes available in the showcase
enum PickerMode { single, many, range, basic }

/// Demo view mode enumeration
///
/// Defines the different demo views available
enum DemoViewMode { picker, years }

/// Comprehensive demo widget for Flicker date picker
///
/// Provides an interactive demo with controls for:
/// - Theme switching (light/dark)
/// - Scroll direction (horizontal/vertical)
/// - View count (single/double month)
/// - Selection mode (single/range/multiple/basic)
/// - First day of week configuration
/// - Real-time selected dates display
class FlickerPickerDemo extends StatefulWidget {
  const FlickerPickerDemo({super.key});

  @override
  State<FlickerPickerDemo> createState() => _FlickerPickerDemoState();
}

class _FlickerPickerDemoState extends State<FlickerPickerDemo> {
  /// Currently selected dates for display and testing
  List<DateTime> _selectedDates = [
    DateTime(2024, 8, 22),
    DateTime(2025, 8, 29),
  ];

  /// Theme mode toggle
  bool _useDarkMode = false;

  /// Scroll direction configuration
  Axis _axis = Axis.horizontal;

  /// First day of week setting
  FirstDayOfWeek _firstDayOfWeek = FirstDayOfWeek.monday;

  /// Current picker mode for demo
  PickerMode _flickerMode = PickerMode.basic;

  /// Current demo view mode
  DemoViewMode _demoViewMode = DemoViewMode.picker;

  /// Number of months to display
  int _viewCount = 1;

  /// Minimum selectable date
  late DateTime? _startDate = DateTime(1920, 1, 31);

  /// Maximum selectable date
  late DateTime? _endDate = DateTime(2025, 9, 1);

  /// Handles date selection changes from the picker
  void onDatesChanged(List<DateTime> dates) =>
      setState(() => _selectedDates = dates);

  /// Formats a date for display in the demo
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Determines if a date should be disabled
  /// Currently allows all dates, but can be customized to disable weekends
  bool _disabledDate(DateTime date) {
    // if (_flickerMode == PickerMode.single &&
    //     date.month == 8 &&
    //     date.day == 14) {
    //   return true;
    // }

    if (date.month == 8) {
      return date.day == 14 || date.day == 18;
    }
    // Disable weekends (currently disabled for demo purposes)
    // return false;
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  void _onModeChange(PickerMode value) {
    setState(() {
      if (value == PickerMode.single) {
        _selectedDates = [DateTime(2025, 9, 1), DateTime(2025, 9, 2)];
      }
      if (value == PickerMode.range) {
        _selectedDates = [DateTime.now(), DateTime(2025, 9, 2)];
      }

      if (value == PickerMode.basic) {
        // _selectedDates = [DateTime.now(), DateTime(2025, 9, 2)];
        _startDate = DateTime(2025, 12, 1);
        _endDate = DateTime(2026, 9, 2);
        _selectedDates = [DateTime(2025, 12, 1), DateTime(2026, 1, 1)];
      }
      _flickerMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Flicker',
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildDemoViewSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildThemeSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildDirectionSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildViewCountSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildModeSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildFirstDayOfWeekSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildSelectedInfo(),
        ],
      ),
    ];

    if (_demoViewMode == DemoViewMode.picker) {
      children.add(_buildDatePicker());
    } else {
      children.add(FlickerYearsDemo());
    }

    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SpacingConstants.defaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  /// Helper widget for consistent row layout
  ///
  /// [title] - Label for the control
  /// [children] - Control widgets to display
  Widget _buildRow(String title, List<Widget> children) {
    final titleWidget = Text(
      title,
      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: DemoSpacingConstants.labelWidth, child: titleWidget),
        ...children,
      ],
    );
  }

  /// Helper method to create segmented control option with consistent padding
  Widget _buildSegmentedOption(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DemoSpacingConstants.segmentedControlHorizontalPadding,
      ),
      child: Text(text),
    );
  }

  /// Demo view switch control
  ///
  /// Allows switching between picker demo and years demo
  Widget _buildDemoViewSwitch() {
    return _buildRow('Demo View', [
      CupertinoSegmentedControl<DemoViewMode>(
        groupValue: _demoViewMode,
        children: {
          DemoViewMode.picker: _buildSegmentedOption('Picker'),
          DemoViewMode.years: _buildSegmentedOption('Years'),
        },
        onValueChanged: (DemoViewMode value) {
          setState(() {
            _demoViewMode = value;
          });
        },
      ),
    ]);
  }

  /// Theme switch control
  ///
  /// Allows toggling between light and dark themes
  Widget _buildThemeSwitch() {
    return _buildRow(' Theme', [
      CupertinoSegmentedControl<int>(
        groupValue: _useDarkMode ? 1 : 0,
        children: {
          0: _buildSegmentedOption('Light'),
          1: _buildSegmentedOption('Dark'),
        },
        onValueChanged: (int value) {
          setState(() {
            _useDarkMode = value == 1;
          });
        },
      ),
    ]);
  }

  /// View count control
  ///
  /// Allows switching between single and dual month views
  Widget _buildViewCountSwitch() {
    return _buildRow('ViewCount', [
      CupertinoSegmentedControl<int>(
        groupValue: _viewCount,
        children: {
          1: _buildSegmentedOption('Single View'),
          2: _buildSegmentedOption('Double Views'),
        },
        onValueChanged: (int value) {
          setState(() {
            _viewCount = value;
          });
        },
      ),
    ]);
  }

  /// First day of week control
  ///
  /// Allows configuring which day appears as the first column
  Widget _buildFirstDayOfWeekSwitch() {
    return _buildRow('First Day Of Week', [
      CupertinoSegmentedControl<FirstDayOfWeek>(
        groupValue: _firstDayOfWeek,
        children: {
          FirstDayOfWeek.monday: _buildSegmentedOption('Monday'),
          FirstDayOfWeek.sunday: _buildSegmentedOption('Sunday'),
          FirstDayOfWeek.saturday: _buildSegmentedOption('Saturday'),
          FirstDayOfWeek.locale: _buildSegmentedOption('Locale Based'),
        },
        onValueChanged: (FirstDayOfWeek value) {
          setState(() {
            _firstDayOfWeek = value;
          });
        },
      ),
    ]);
  }

  /// Selection mode control
  ///
  /// Allows switching between different date selection modes
  Widget _buildModeSwitch() {
    final child = CupertinoSegmentedControl<PickerMode>(
      groupValue: _flickerMode,
      children: {
        PickerMode.basic: _buildSegmentedOption('Basic'),
        PickerMode.single: _buildSegmentedOption('Single'),
        PickerMode.range: _buildSegmentedOption('Range'),
        PickerMode.many: _buildSegmentedOption('Many'),
      },
      onValueChanged: _onModeChange,
    );
    return _buildRow('Mode', [child]);
  }

  /// Scroll direction control
  ///
  /// Allows switching between horizontal and vertical scrolling
  Widget _buildDirectionSwitch() {
    final child = CupertinoSegmentedControl<Axis>(
      groupValue: _axis,
      children: {
        Axis.horizontal: _buildSegmentedOption('Horizontal'),
        Axis.vertical: _buildSegmentedOption('Vertical'),
      },
      onValueChanged: (value) {
        setState(() {
          _axis = value;
          if (value == Axis.vertical) _viewCount = 2;
        });
      },
    );
    return _buildRow(' Direction', [child]);
  }

  /// Main date picker builder
  ///
  /// Returns the appropriate Flicker instance based on current demo mode
  Widget _buildDatePicker() {
    // return Container();

    switch (_flickerMode) {
      case PickerMode.basic:
        return _buildBasic();

      case PickerMode.single:
        return _buildSingle();

      case PickerMode.range:
        return _buildRangeMode();
      case PickerMode.many:
        return _buildManyMode();
    }
  }

  /// Multiple date selection demo
  Widget _buildManyMode() {
    return Flicker(
      mode: FlickerSelectionMode.many,
      value: _selectedDates,
      startDate: _startDate,
      endDate: _endDate,
      disabledDate: _disabledDate,
      onValueChange: onDatesChanged,
      theme: FlickTheme(useDarkMode: _useDarkMode),
      firstDayOfWeek: _firstDayOfWeek,
      viewCount: _viewCount,
      scrollDirection: _axis,
    );
  }

  /// Basic mode demo (single date selection with horizontal scrolling)
  Flicker _buildBasic() {
    debugPrint('startDate: $_startDate, endDate: $_endDate');

    return Flicker(
      value: _selectedDates,
      startDate: _startDate,
      endDate: _endDate,
      disabledDate: _disabledDate,
      onValueChange: onDatesChanged,
      theme: FlickTheme(useDarkMode: _useDarkMode),
      mode: FlickerSelectionMode.single,
      firstDayOfWeek: _firstDayOfWeek,
      viewCount: _viewCount,
      scrollDirection: _axis,
    );
  }

  /// Single date selection demo
  Widget _buildSingle() {
    return Flicker(
      value: _selectedDates,
      startDate: _startDate,
      endDate: _endDate,
      disabledDate: _disabledDate,
      onValueChange: onDatesChanged,
      theme: FlickTheme(useDarkMode: _useDarkMode),
      firstDayOfWeek: _firstDayOfWeek,
      viewCount: _viewCount,
      scrollDirection: _axis,
    );
  }

  /// Date range selection demo
  Widget _buildRangeMode() {
    return Flicker(
      mode: FlickerSelectionMode.range,
      value: _selectedDates,
      startDate: _startDate,
      endDate: _endDate,
      disabledDate: _disabledDate,
      onValueChange: onDatesChanged,
      theme: FlickTheme(useDarkMode: _useDarkMode),
      firstDayOfWeek: _firstDayOfWeek,
      viewCount: _viewCount,
      scrollDirection: _axis,
    );
  }

  /// Selected dates display widget
  ///
  /// Shows the currently selected dates in a readable format
  Widget _buildSelectedInfo() {
    return _buildRow('Selected Dates', [
      Text(
        _selectedDates.isEmpty
            ? 'No Selected'
            : ' ${_selectedDates.map((e) => _formatDate(e)).join(', ')}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFFFFFFF),
        ),
      ),
      SizedBox(width: 16),
      Text(
        "$_axis",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFFFFFFF),
        ),
      ),
    ]);
  }
}
