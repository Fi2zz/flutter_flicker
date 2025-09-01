import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';
import './flicker_years_demo.dart';
import 'package:flutter_flicker/src/constants/ui_constants.dart';
import './demo_constants.dart';
import './custom_segmented_control.dart';
import 'custom_text_widget.dart';

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
  final Function(Locale) onLocaleChange;

  const FlickerPickerDemo({super.key, required this.onLocaleChange});

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
  Axis _scrollDirection = Axis.horizontal;

  /// First day of week setting
  FirstDayOfWeek _firstDayOfWeek = FirstDayOfWeek.monday;

  /// Current picker mode for demo
  PickerMode _flickerMode = PickerMode.basic;

  /// Current demo view mode
  DemoViewMode _viewMode = DemoViewMode.picker;

  /// Number of months to display
  int _viewCount = 1;

  int get viewCount => _scrollDirection == Axis.vertical ? 2 : _viewCount;

  /// Supported locales for language switching
  final List<Map<String, dynamic>> _supportedLocales = [
    {'locale': const Locale('en', 'US'), 'name': 'English'},
    {'locale': const Locale('zh', 'CN'), 'name': '中文'},
    {'locale': const Locale('es', 'ES'), 'name': 'Español'},
    {'locale': const Locale('fr', 'FR'), 'name': 'Français'},
    {'locale': const Locale('de', 'DE'), 'name': 'Deutsch'},
    {'locale': const Locale('ja', 'JP'), 'name': '日本語'},
  ];

  /// Localized text mappings
  Map<String, Map<String, String>> get _localizedTexts => {
    'en': {
      'title': 'Welcome to Flicker',
      'language': 'Language',
      'demoView': 'Demo View',
      'theme': 'Theme',
      'direction': 'Direction',
      'viewCount': 'View Count',
      'mode': 'Mode',
      'firstDayOfWeek': 'First Day',
      'selectedDates': 'Selected Dates',
      'light': 'Light',
      'dark': 'Dark',
      'horizontal': 'Horizontal',
      'vertical': 'Vertical',
      'single': 'Single',
      'double': 'Double',
      'basic': 'Basic',
      'range': 'Range',
      'many': 'Multiple',
      'monday': 'Monday',
      'sunday': 'Sunday',
      'picker': 'Picker',
      'years': 'Years',
      'l10n': 'L10n',
      'saturday': 'Saturday',
      'localeBased': 'Locale Based',
      'noSelected': 'No Selected',
      'keyboard': 'Keyboard',
      'keyboardNavigation': 'Keyboard Navigation',
      'keyboardInstructions': 'Keyboard Instructions',
      'arrowKeys': '• Arrow keys: Move focus to different dates',
      'tabKeys': '• Tab/Shift+Tab: Switch focus between dates',
      'enterSpace': '• Enter/Space: Select current focused date',
      'pageKeys': '• Page Up/Down: Switch months',
      'homeEnd': '• Home/End: Jump to beginning/end of month',
      'escape': '• Escape: Clear selection or exit',
    },
    'zh': {
      'title': '欢迎使用 Flicker',
      'language': '语言',
      'demoView': '演示视图',
      'theme': '主题',
      'direction': '方向',
      'viewCount': '视图数量',
      'mode': '模式',
      'firstDayOfWeek': '每周首日',
      'selectedDates': '已选日期',
      'light': '浅色',
      'dark': '深色',
      'horizontal': '水平',
      'vertical': '垂直',
      'single': '单个',
      'double': '双个',
      'basic': '基础',
      'range': '范围',
      'many': '多选',
      'monday': '周一',
      'sunday': '周日',
      'picker': '选择器',
      'years': '年份',
      'l10n': '本地化',
      'saturday': '周六',
      'localeBased': '基于区域',
      'noSelected': '未选择',
      'keyboard': '键盘',
      'keyboardNavigation': '键盘导航',
      'keyboardInstructions': '键盘操作说明',
      'arrowKeys': '• 方向键：移动焦点到不同日期',
      'tabKeys': '• Tab/Shift+Tab：在日期间切换焦点',
      'enterSpace': '• Enter/Space：选择当前焦点日期',
      'pageKeys': '• Page Up/Down：切换月份',
      'homeEnd': '• Home/End：跳转到月初/月末',
      'escape': '• Escape：清除选择或退出',
    },
  };

  /// Get localized text
  String _getText(String key) {
    final locale = Localizations.localeOf(context);
    final languageCode = locale.languageCode;
    return _localizedTexts[languageCode]?[key] ??
        _localizedTexts['en']?[key] ??
        key;
  }

  /// Minimum selectable date
  late DateTime? _startDate = DateTime(1920, 1, 31);

  /// Maximum selectable date
  late DateTime? _endDate = DateTime(2025, 9, 1);

  /// Handles date selection changes from the picker
  void onDatesChanged(List<DateTime> dates) {
    setState(() {
      _selectedDates = dates;
    });
  }

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

    // Disable weekends (currently disabled for demo purposes)
    return false;
    return date.weekday == DateTime.monday ||
        // date.weekday == DateTime.thursday ||
        date.day % 15 == 2 ||
        date.day % 15 == 1;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoTexts.largeTitle(_getText('title'), color: CupertinoColors.white),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildDemoViewSwitch(),
          SizedBox(height: SpacingConstants.verticalSpacing),
          _buildLanguageSwitch(),
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

    switch (_viewMode) {
      case DemoViewMode.years:
        children.add(FlickerYearsDemo());
        break;
      case DemoViewMode.picker:
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDatePicker(),
              SizedBox(height: SpacingConstants.verticalSpacing),
              _buildKeyboardInstructions(),
            ],
          ),
        );
        break;
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
    final titleWidget = DemoTexts.standardBold(title);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: DemoSpacingConstants.labelWidth, child: titleWidget),
        ...children,
      ],
    );
  }

  /// Language switch control
  ///
  /// Allows switching between different languages
  Widget _buildLanguageSwitch() {
    final currentLocale = Localizations.localeOf(context);

    // Create options map for CustomSegmentedControl
    final Map<Locale, String> languageOptions = {};
    for (final localeData in _supportedLocales) {
      final locale = localeData['locale'] as Locale;
      languageOptions[locale] = localeData['name'] as String;
    }

    // Find current locale or default to first one
    Locale selectedLocale = _supportedLocales.first['locale'] as Locale;
    for (final locale in languageOptions.keys) {
      if (locale.languageCode == currentLocale.languageCode) {
        selectedLocale = locale;
        break;
      }
    }

    return CustomSegmentedControl<Locale>(
      title: _getText('language'),
      value: selectedLocale,
      options: languageOptions,
      onValueChanged: (Locale locale) => widget.onLocaleChange(locale),
    );
  }

  /// Demo view switch control
  ///
  /// Allows switching between picker demo and years demo
  Widget _buildDemoViewSwitch() {
    return CustomSegmentedControl<DemoViewMode>(
      title: _getText('demoView'),
      value: _viewMode,
      options: {
        DemoViewMode.picker: _getText('picker'),
        DemoViewMode.years: _getText('years'),
      },
      onValueChanged: (DemoViewMode value) => setState(() => _viewMode = value),
    );
  }

  /// Theme switch control
  ///
  /// Allows toggling between light and dark themes
  Widget _buildThemeSwitch() {
    return CustomSegmentedControl<int>(
      title: _getText('theme'),
      value: _useDarkMode ? 1 : 0,
      options: {0: _getText('light'), 1: _getText('dark')},
      onValueChanged: (int value) => setState(() => _useDarkMode = value == 1),
    );
  }

  /// View count control
  ///
  /// Allows switching between single and dual month views
  Widget _buildViewCountSwitch() {
    return CustomSegmentedControl<int>(
      title: _getText('viewCount'),
      value: _viewCount,
      options: {1: _getText('single'), 2: _getText('double')},
      onValueChanged: (int value) => setState(() => _viewCount = value),
    );
  }

  /// First day of week control
  ///
  /// Allows configuring which day appears as the first column
  Widget _buildFirstDayOfWeekSwitch() {
    return CustomSegmentedControl<FirstDayOfWeek>(
      title: _getText('firstDayOfWeek'),
      value: _firstDayOfWeek,
      options: {
        FirstDayOfWeek.monday: _getText('monday'),
        FirstDayOfWeek.sunday: _getText('sunday'),
        FirstDayOfWeek.saturday: _getText('saturday'),
        FirstDayOfWeek.locale: _getText('localeBased'),
      },
      onValueChanged: (FirstDayOfWeek value) =>
          setState(() => _firstDayOfWeek = value),
    );
  }

  /// Selection mode control
  ///
  /// Allows switching between different date selection modes
  Widget _buildModeSwitch() {
    return CustomSegmentedControl<PickerMode>(
      title: _getText('mode'),
      value: _flickerMode,
      options: {
        PickerMode.basic: _getText('basic'),
        PickerMode.single: _getText('single'),
        PickerMode.range: _getText('range'),
        PickerMode.many: _getText('many'),
      },
      onValueChanged: (value) {
        setState(() {
          if (value == PickerMode.single) {
            _selectedDates = [DateTime(2025, 9, 1), DateTime(2025, 9, 2)];
          }
          if (value == PickerMode.range) {
            _selectedDates = [DateTime.now(), DateTime(2025, 9, 2)];
          }

          if (value == PickerMode.basic) {
            // _selectedDates = [DateTime.now(), DateTime(2025, 9, 2)];
            _startDate = DateTime(1921, 12, 1);
            _endDate = DateTime(2026, 9, 2);
          }
          _flickerMode = value;
        });
      },
    );
  }

  /// Scroll direction control
  ///
  /// Allows switching between horizontal and vertical scrolling
  Widget _buildDirectionSwitch() {
    return CustomSegmentedControl<Axis>(
      title: _getText('direction'),
      value: _scrollDirection,
      options: {
        Axis.horizontal: _getText('horizontal'),
        Axis.vertical: _getText('vertical'),
      },
      onValueChanged: (Axis value) => setState(() => _scrollDirection = value),
    );
  }

  /// Keyboard navigation instructions
  ///
  /// Displays keyboard shortcuts and navigation instructions
  Widget _buildKeyboardInstructions() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // width: double.infinity,
      width: 300,
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        border: Border.all(
          color: CupertinoColors.white,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoTexts.standardBold(_getText('keyboardInstructions')),
          const SizedBox(height: 8),
          DemoTexts.standardNormal(_getText('arrowKeys')),
          DemoTexts.standardNormal(_getText('tabKeys')),
          DemoTexts.standardNormal(_getText('enterSpace')),
          DemoTexts.standardNormal(_getText('pageKeys')),
          DemoTexts.standardNormal(_getText('homeEnd')),
          DemoTexts.standardNormal(_getText('escape')),
        ],
      ),
    );
  }

  /// Main date picker builder
  ///
  /// Returns the appropriate Flicker instance based on current demo mode
  Widget _buildDatePicker() {
    // return Container();

    FlickerSelectionMode? mode;

    switch (_flickerMode) {
      case PickerMode.basic:

      // return _buildBasic();
      case PickerMode.single:
        mode = FlickerSelectionMode.single;
      // return _buildSingle();
      case PickerMode.range:
        mode = FlickerSelectionMode.range;
      // return _buildRangeMode();
      case PickerMode.many:
        mode = FlickerSelectionMode.many;
    }

    return Flicker(
      mode: mode,
      value: _selectedDates,
      startDate: _startDate,
      endDate: _endDate,
      disabledDate: _disabledDate,
      onValueChange: onDatesChanged,
      theme: FlickTheme(useDarkMode: _useDarkMode),
      firstDayOfWeek: _firstDayOfWeek,
      viewCount: viewCount,
      scrollDirection: _scrollDirection,
    );
  }

  /// Selected dates display widget
  ///
  /// Shows the currently selected dates in a readable format
  Widget _buildSelectedInfo() {
    debugPrint("$_scrollDirection $_selectedDates");

    return _buildRow(_getText('selectedDates'), [
      DemoTexts.selectedInfo(
        _selectedDates.isEmpty
            ? _getText('noSelected')
            : ' ${_selectedDates.map((e) => _formatDate(e)).join(', ')}',
      ),
      SizedBox(width: 16),
      DemoTexts.selectedInfo("$_scrollDirection"),
    ]);
  }
}
