import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';
import 'package:flutter_flicker/src/constants/ui_constants.dart';
import 'custom_text_widget.dart';

/// 本地化演示组件
/// 展示语义标签的多语言支持和无障碍功能
class FlickerLocalizationDemo extends StatefulWidget {
  const FlickerLocalizationDemo({super.key});

  @override
  State<FlickerLocalizationDemo> createState() =>
      _FlickerLocalizationDemoState();
}

class _FlickerLocalizationDemoState extends State<FlickerLocalizationDemo> {
  List<DateTime> selectedDates = [];
  Locale currentLocale = const Locale('zh', 'CN');
  FlickerSelectionMode _selectionMode = FlickerSelectionMode.single;
  bool _useDarkMode = false;

  final List<Map<String, dynamic>> supportedLocales = [
    {'locale': const Locale('en', 'US'), 'name': 'English', 'flag': '🇺🇸'},
    {'locale': const Locale('zh', 'CN'), 'name': '中文', 'flag': '🇨🇳'},
    {'locale': const Locale('es', 'ES'), 'name': 'Español', 'flag': '🇪🇸'},
    {'locale': const Locale('fr', 'FR'), 'name': 'Français', 'flag': '🇫🇷'},
    {'locale': const Locale('de', 'DE'), 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'locale': const Locale('ja', 'JP'), 'name': '日本語', 'flag': '🇯🇵'},
    {'locale': const Locale('ko', 'KR'), 'name': '한국어', 'flag': '🇰🇷'},
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SpacingConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            DemoTexts.largeTitle('Flicker 本地化演示'),
            SizedBox(height: SpacingConstants.verticalSpacing),

            // 语言选择器
            _buildLanguageSelector(),
            SizedBox(height: SpacingConstants.verticalSpacing),

            // 选择模式和主题控制
            _buildControlPanel(),
            SizedBox(height: SpacingConstants.verticalSpacing),

            // 无障碍功能说明
            _buildAccessibilityInfo(),
            SizedBox(height: SpacingConstants.verticalSpacing),

            // 键盘导航说明
            _buildKeyboardNavigationInfo(),
            SizedBox(height: SpacingConstants.verticalSpacing),

            // 日历组件
            _buildCalendar(),

            // 选择结果显示
            if (selectedDates.isNotEmpty) ..._buildSelectedDateInfo(),
          ],
        ),
      ),
    );
  }

  /// 构建语言选择器
  Widget _buildLanguageSelector() {
    return Container(
      padding: EdgeInsets.all(SpacingConstants.defaultPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoTexts.standardBold('选择语言 / Select Language'),
          SizedBox(height: SpacingConstants.verticalSpacing),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: supportedLocales.map((localeData) {
              final locale = localeData['locale'] as Locale;
              final isSelected = locale == currentLocale;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    currentLocale = locale;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CupertinoColors.activeBlue
                        : CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? CupertinoColors.activeBlue
                          : CupertinoColors.systemGrey4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localeData['flag'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        localeData['name'],
                        style: TextStyle(
                          color: isSelected
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建控制面板（选择模式和主题）
  Widget _buildControlPanel() {
    final controlTexts = _getControlPanelTexts();
    return Container(
      padding: EdgeInsets.all(SpacingConstants.defaultPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DemoTexts.standardBold(controlTexts['title']!),
          SizedBox(height: SpacingConstants.verticalSpacing),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DemoTexts.smallMedium(controlTexts['selectionMode']!),
                    const SizedBox(height: 8),
                    CupertinoSlidingSegmentedControl<FlickerSelectionMode>(
                      groupValue: _selectionMode,
                      children: {
                        FlickerSelectionMode.single: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(controlTexts['single']!),
                        ),
                        FlickerSelectionMode.range: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(controlTexts['range']!),
                        ),
                        FlickerSelectionMode.many: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(controlTexts['many']!),
                        ),
                      },
                      onValueChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectionMode = value;
                            selectedDates.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DemoTexts.smallMedium(controlTexts['darkMode']!),
                  const SizedBox(height: 8),
                  CupertinoSwitch(
                    value: _useDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _useDarkMode = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取控制面板相关文本
  Map<String, String> _getControlPanelTexts() {
    switch (currentLocale.languageCode) {
      case 'en':
        return {
          'title': 'Control Options',
          'selectionMode': 'Selection Mode',
          'single': 'Single',
          'range': 'Range',
          'many': 'Multiple',
          'darkMode': 'Dark Mode',
        };
      case 'es':
        return {
          'title': 'Opciones de Control',
          'selectionMode': 'Modo de Selección',
          'single': 'Único',
          'range': 'Rango',
          'many': 'Múltiple',
          'darkMode': 'Modo Oscuro',
        };
      case 'fr':
        return {
          'title': 'Options de Contrôle',
          'selectionMode': 'Mode de Sélection',
          'single': 'Unique',
          'range': 'Plage',
          'many': 'Multiple',
          'darkMode': 'Mode Sombre',
        };
      case 'de':
        return {
          'title': 'Steuerungsoptionen',
          'selectionMode': 'Auswahlmodus',
          'single': 'Einzeln',
          'range': 'Bereich',
          'many': 'Mehrfach',
          'darkMode': 'Dunkler Modus',
        };
      case 'ja':
        return {
          'title': 'コントロールオプション',
          'selectionMode': '選択モード',
          'single': '単一',
          'range': '範囲',
          'many': '複数',
          'darkMode': 'ダークモード',
        };
      case 'ko':
        return {
          'title': '제어 옵션',
          'selectionMode': '선택 모드',
          'single': '단일',
          'range': '범위',
          'many': '다중',
          'darkMode': '다크 모드',
        };
      case 'zh':
      default:
        return {
          'title': '控制选项',
          'selectionMode': '选择模式',
          'single': '单选',
          'range': '范围',
          'many': '多选',
          'darkMode': '深色模式',
        };
    }
  }

  /// 构建无障碍功能说明
  Widget _buildAccessibilityInfo() {
    return Container(
      padding: EdgeInsets.all(SpacingConstants.defaultPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.person_2_fill,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              DemoTexts.standardBold('无障碍功能演示'),
            ],
          ),
          SizedBox(height: SpacingConstants.verticalSpacing / 2),
          DemoTexts.smallGrey(
            '• 语义标签会根据选择的语言自动本地化\n'
            '• 屏幕阅读器会使用相应语言朗读日期和状态\n'
            '• 支持键盘导航和焦点管理\n'
            '• 选择日期后可以看到本地化的语义信息',
          ),
        ],
      ),
    );
  }

  /// 构建键盘导航说明
  Widget _buildKeyboardNavigationInfo() {
    final keyboardTexts = _getKeyboardNavigationTexts();
    return Container(
      padding: EdgeInsets.all(SpacingConstants.defaultPadding),
      decoration: BoxDecoration(
        color: CupertinoColors.systemOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.keyboard,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 8),
              DemoTexts.standardBold(keyboardTexts['title']!),
            ],
          ),
          SizedBox(height: SpacingConstants.verticalSpacing / 2),
          DemoTexts.smallGrey(keyboardTexts['instructions']!),
        ],
      ),
    );
  }

  /// 获取键盘导航相关文本
  Map<String, String> _getKeyboardNavigationTexts() {
    switch (currentLocale.languageCode) {
      case 'en':
        return {
          'title': 'Keyboard Navigation',
          'instructions': '• Arrow keys: Move focus to different dates\n'
              '• Tab/Shift+Tab: Switch focus between dates\n'
              '• Enter/Space: Select current focused date\n'
              '• Page Up/Down: Switch months\n'
              '• Home/End: Jump to beginning/end of month\n'
              '• Escape: Clear selection or exit',
        };
      case 'ja':
        return {
          'title': 'キーボードナビゲーション',
          'instructions': '• 矢印キー：異なる日付にフォーカスを移動\n'
              '• Tab/Shift+Tab：日付間でフォーカスを切り替え\n'
              '• Enter/Space：現在フォーカスされている日付を選択\n'
              '• Page Up/Down：月を切り替え\n'
              '• Home/End：月の始まり/終わりにジャンプ\n'
              '• Escape：選択をクリアまたは終了',
        };
      case 'ko':
        return {
          'title': '키보드 내비게이션',
          'instructions': '• 방향키: 다른 날짜로 포커스 이동\n'
              '• Tab/Shift+Tab: 날짜 간 포커스 전환\n'
              '• Enter/Space: 현재 포커스된 날짜 선택\n'
              '• Page Up/Down: 월 전환\n'
              '• Home/End: 월 시작/끝으로 이동\n'
              '• Escape: 선택 해제 또는 종료',
        };
      case 'zh':
      default:
        return {
          'title': '键盘导航功能',
          'instructions': '• 方向键：移动焦点到不同日期\n'
              '• Tab/Shift+Tab：在日期间切换焦点\n'
              '• Enter/Space：选择当前焦点日期\n'
              '• Page Up/Down：切换月份\n'
              '• Home/End：跳转到月初/月末\n'
              '• Escape：清除选择或退出',
        };
    }
  }

  /// 构建日历组件
  Widget _buildCalendar() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: _useDarkMode ? CupertinoColors.black : CupertinoColors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: CupertinoColors.systemGrey4,
        ),
      ),
      child: Flicker(
        mode: _selectionMode,
        onValueChange: (dates) {
          setState(() {
            selectedDates = dates;
          });
        },
      ),
    );
  }

  /// 构建选择日期信息显示
  List<Widget> _buildSelectedDateInfo() {
    return [
      SizedBox(height: SpacingConstants.verticalSpacing),
      Container(
        padding: EdgeInsets.all(SpacingConstants.defaultPadding),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                DemoTexts.standardBold('已选择日期'),
              ],
            ),
            SizedBox(height: SpacingConstants.verticalSpacing / 2),
            Builder(
              builder: (context) {
                final l10n = FlickerL10n.maybeOf(context);
                final date = selectedDates.first;
                final semanticLabel = l10n?.formatDateForSemantics(date) ?? '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DemoTexts.smallBold('语义标签: $semanticLabel'),
                    const SizedBox(height: 4),
                    DemoTexts.smallGrey(
                      '原始日期: ${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ];
  }
}
