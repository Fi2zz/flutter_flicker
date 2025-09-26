import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flutter_flicker.dart';
import 'package:signals/signals_flutter.dart';

enum Brightness { light, dark }

String formatDate(DateTime? date) {
  if (date == null) return 'N/A';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

Widget buildSegmentedOption(String text) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 8),
    child: Text(text),
  );
}

Widget buildRow(String text, List<Widget> children) {
  final title = Text(
    text,
    style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
  );
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(width: 150, child: title),
      ...children,
    ],
  );
}

Widget buildText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: Color(0xFFFFFFFF),
    ),
  );
}

Widget buildSegmentedControl<T extends Object>(
  String title,
  Signal<T> signal,
  Map<T, Widget> children,
) {
  return buildRow(title, [
    CupertinoSegmentedControl<T>(
      groupValue: signal.value,
      onValueChanged: (T value) => signal.value = value,
      children: children,
    ),
  ]);
}

class FlickerPickerDemo extends StatefulWidget {
  const FlickerPickerDemo({super.key});
  @override
  State<FlickerPickerDemo> createState() => _FlickerPickerDemoState();
}

class _FlickerPickerDemoState extends State<FlickerPickerDemo> {
  final Signal<List<DateTime>> _selectedDates = signal([DateTime.now()]);
  final Signal<Brightness> _brightness = signal(Brightness.light);
  final Signal<Axis> _scrollDirection = signal(Axis.horizontal);
  final Signal<int> _selectionCount = signal(1);
  final Signal<SelectionMode> _mode = signal(SelectionMode.single);
  final Signal<FirstDayOfWeek> _firstDayOfWeek = signal(FirstDayOfWeek.monday);
  final Signal<int> _viewCount = signal(1);
  final Signal<DateTime?> _startDate = signal(DateTime(2025, 9, 1));
  final Signal<DateTime?> _endDate = signal(DateTime(2025, 12, 1));

  void onValueChange(List<DateTime> dates) => (_selectedDates.value = dates);

  bool _disabledDate(DateTime date) {
    return date.weekday == DateTime.saturday || date.day == DateTime.now().day;
  }

  void _onModeChange(SelectionMode value) {
    switch (value) {
      case SelectionMode.single:
        onValueChange([DateTime(2025, 9, 2), DateTime(2025, 12, 2)]);
        _startDate.value = DateTime(2025, 10, 1);
        _endDate.value = DateTime(2025, 11, 2);
        _selectionCount.value = 1;
        break;
      case SelectionMode.range:
        _selectionCount.value = 2;
        onValueChange([DateTime.now(), DateTime(2025, 9, 2)]);
        break;
      case SelectionMode.many:
        _selectionCount.value = 4;
        onValueChange([
          DateTime(2025, 12, 1),
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 2),
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 5),
        ]);
        break;
    }
  }

  late final Effect _effect;

  String get _displaySelectedDates {
    return _selectedDates.value.isEmpty
        ? 'No Selected'
        : _selectedDates.value.map((e) => formatDate(e)).join(', ');
  }

  String get _displayDateRange {
    return "${formatDate(_startDate.value)} - ${formatDate(_endDate.value)}";
  }

  @override
  void initState() {
    super.initState();
    _effect = Effect(() {
      _onModeChange(_mode.value);
      if (_viewCount.value == 1) {
        _scrollDirection.value = Axis.horizontal;
      }
    });
  }

  @override
  void dispose() {
    _effect.dispose();
    super.dispose();
  }

  Widget _scaffold() {
    return Watch((context) {
      List<Widget> children = [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16.0,
          children: [
            const Text(
              'Welcome to Flicker',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            _buildBrightness(),
            _buildScrollDirection(),
            _buildViewCount(),
            _buildMode(),
            _buildFirstDayOfWeekSwitch(),
            _buildSelectionCount(),
            buildRow('Selected Dates', [buildText(_displaySelectedDates)]),
            buildRow('Start Date - End Date', [buildText(_displayDateRange)]),
          ],
        ),
        _builder(),
      ];
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: _scaffold(),
    );
  }

  Widget _buildBrightness() {
    return buildSegmentedControl('Brightness', _brightness, {
      Brightness.light: buildSegmentedOption('Light'),
      Brightness.dark: buildSegmentedOption('Dark'),
    });
  }

  Widget _buildViewCount() {
    return buildSegmentedControl('View Count', _viewCount, {
      1: buildSegmentedOption('1 View'),
      2: buildSegmentedOption('2 Views'),
    });
  }

  Widget _buildSelectionCount() {
    return buildSegmentedControl('Selection Count', _selectionCount, {
      1: buildSegmentedOption('1'),
      2: buildSegmentedOption('2'),
      3: buildSegmentedOption('3'),
      4: buildSegmentedOption('4'),
    });
  }

  Widget _buildFirstDayOfWeekSwitch() {
    return buildSegmentedControl('First Day Of Week', _firstDayOfWeek, {
      FirstDayOfWeek.monday: buildSegmentedOption('Monday'),
      FirstDayOfWeek.sunday: buildSegmentedOption('Sunday'),
      FirstDayOfWeek.saturday: buildSegmentedOption('Saturday'),
      FirstDayOfWeek.locale: buildSegmentedOption('Locale Based'),
    });
  }

  Widget _buildMode() {
    return buildSegmentedControl('Mode', _mode, {
      SelectionMode.single: buildSegmentedOption('Single'),
      SelectionMode.range: buildSegmentedOption('Range'),
      SelectionMode.many: buildSegmentedOption('Many'),
    });
  }

  Widget _buildScrollDirection() {
    return buildSegmentedControl('Direction', _scrollDirection, {
      Axis.horizontal: buildSegmentedOption('Horizontal'),
      Axis.vertical: buildSegmentedOption('Vertical'),
    });
  }

  FlickerTheme get _theme =>
      FlickerTheme(useDarkMode: _brightness.value == Brightness.dark);

  Widget _builder() {
    return Flicker(
      mode: _mode.value,
      value: _selectedDates.value,
      startDate: _startDate.value,
      endDate: _endDate.value,
      disabledDate: _disabledDate,
      onValueChange: onValueChange,
      theme: _theme,
      firstDayOfWeek: _firstDayOfWeek.value,
      viewCount: _viewCount.value,
      scrollDirection: _scrollDirection.value,
      selectionCount: _selectionCount.value,
    );
  }
}
