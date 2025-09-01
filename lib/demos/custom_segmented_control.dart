import 'package:flutter/cupertino.dart';
import 'demo_constants.dart';
import '../src/constants/ui_constants.dart';

/// 通用的分段控制组件
///
/// 支持泛型类型，提供统一的样式和行为
class CustomSegmentedControl<T extends Object> extends StatelessWidget {
  /// 当前选中的值
  final T value;

  /// 值改变时的回调
  final ValueChanged<T> onValueChanged;

  /// 选项映射，键为值，值为显示文本
  final Map<T, String> options;

  /// 标题文本
  final String? title;

  /// 是否显示为行布局（包含标题）
  final bool showAsRow;

  const CustomSegmentedControl({
    super.key,
    required this.value,
    required this.onValueChanged,
    required this.options,
    this.title,
    this.showAsRow = true,
  });

  @override
  Widget build(BuildContext context) {
    final segmentedControl = CupertinoSegmentedControl<T>(
      groupValue: value,
      children: options.map(
        (key, text) => MapEntry(key, _buildSegmentedOption(text)),
      ),
      onValueChanged: onValueChanged,
    );

    return _buildRow(title!, [segmentedControl]);
  }

  /// 创建分段控制选项，保持与原有样式一致
  Widget _buildSegmentedOption(String text) {
    return Container(
      constraints: BoxConstraints(minWidth: 120), // 确保至少能显示4个汉字
      padding: EdgeInsets.symmetric(
        horizontal: DemoSpacingConstants.segmentedControlHorizontalPadding,
      ),
      child: Text(
        text,
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 创建带标题的行布局，保持与原有样式一致
  Widget _buildRow(String title, List<Widget> children) {
    final titleWidget = Text(
      title,
      style: TextStyle(
        fontSize: TypographyConstants.standardFontSize,
        fontWeight: FontWeight.bold,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: DemoSpacingConstants.labelWidth, child: titleWidget),
        ...children, //.map((node) => Expanded(flex: 1, child: node)),
      ],
    );
  }
}
