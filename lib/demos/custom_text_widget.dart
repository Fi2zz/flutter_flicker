import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/demos/demo_text_styles.dart';

/// 演示页面通用文本组件
/// 提供预定义的文本样式，减少重复代码
class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.style = DemoTextStyle.standardNormal,
    this.color,
    this.isDarkMode = false,
    this.useSystemOppositeColor = true,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// 文本内容
  final String text;

  /// 文本样式类型
  final DemoTextStyle style;

  /// 自定义颜色（可选）
  final Color? color;

  /// 是否为深色模式
  final bool isDarkMode;

  /// 是否使用与系统brightness相反的颜色
  final bool useSystemOppositeColor;

  /// 文本对齐方式
  final TextAlign? textAlign;

  /// 最大行数
  final int? maxLines;

  /// 溢出处理
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = _getTextStyle();

    textStyle = DemoTextStyles.withSystemOppositeColor(textStyle, context);

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// 根据样式类型获取对应的TextStyle
  TextStyle _getTextStyle() {
    switch (style) {
      case DemoTextStyle.largeTitle:
        return DemoTextStyles.largeTitle;
      case DemoTextStyle.standardBold:
        return DemoTextStyles.standardBold;
      case DemoTextStyle.standardNormal:
        return DemoTextStyles.standardNormal;
      case DemoTextStyle.standardMedium:
        return DemoTextStyles.standardMedium;
      case DemoTextStyle.smallMedium:
        return DemoTextStyles.smallMedium;
      case DemoTextStyle.smallBold:
        return DemoTextStyles.smallBold;
      case DemoTextStyle.smallNormal:
        return DemoTextStyles.smallNormal;
      case DemoTextStyle.smallGrey:
        return DemoTextStyles.smallGrey;
      case DemoTextStyle.languageSelectorSelected:
        return DemoTextStyles.languageSelectorSelected;
      case DemoTextStyle.languageSelectorNormal:
        return DemoTextStyles.languageSelectorNormal;
      case DemoTextStyle.selectedInfo:
        return DemoTextStyles.selectedInfo;
    }
  }
}

/// 演示文本样式枚举
enum DemoTextStyle {
  largeTitle,
  standardBold,
  standardNormal,
  standardMedium,
  smallMedium,
  smallBold,
  smallNormal,
  smallGrey,
  languageSelectorSelected,
  languageSelectorNormal,
  selectedInfo,
}

/// 便捷的文本组件构造器
class DemoTexts {
  /// 大标题文本
  static Widget largeTitle(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,

    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.largeTitle,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
      textAlign: textAlign,
    );
  }

  /// 标准粗体文本
  static Widget standardBold(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,

    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.standardBold,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
      textAlign: textAlign,
    );
  }

  /// 标准普通文本
  static Widget standardNormal(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,

    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.standardNormal,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
      textAlign: textAlign,
    );
  }

  /// 小号中等粗细文本
  static Widget smallMedium(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,

    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.smallMedium,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
      textAlign: textAlign,
    );
  }

  /// 小号粗体文本
  static Widget smallBold(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.smallBold,
      color: color,
      isDarkMode: isDarkMode,
      textAlign: textAlign,
    );
  }

  /// 小号灰色文本
  static Widget smallGrey(
    String text, {
    Key? key,
    bool isDarkMode = false,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.smallGrey,
      isDarkMode: isDarkMode,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  /// 选中信息文本
  static Widget selectedInfo(
    String text, {
    Key? key,
    Color? color,
    bool isDarkMode = false,
  }) {
    return CustomText(
      text,
      key: key,
      style: DemoTextStyle.selectedInfo,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
    );
  }

  /// 语言选择器文本
  static Widget languageSelector(
    String text, {
    Key? key,
    required bool isSelected,
    Color? color,
    bool isDarkMode = false,
  }) {
    return CustomText(
      text,
      key: key,
      style: isSelected
          ? DemoTextStyle.languageSelectorSelected
          : DemoTextStyle.languageSelectorNormal,
      color: color,
      isDarkMode: isDarkMode,
      useSystemOppositeColor: true,
    );
  }
}
