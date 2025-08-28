import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

const Color lightBackground = Color(0xFFFFFFFF);
const Color lightBorder = Color(0xFFE5E5EA);
const Color lightPrimaryText = Color(0xFF0B0B0B);
const Color lightSecondaryText = Color(0xFF8E8E93);
const Color lightDisabledText = Color(0xFFA6A5A5);
const Color lightSelectedBackground = Color(0x1A007AFF);
const Color lightSelectedText = Color(0xFF007AFF);
const Color lightHighlightBackground = Color(0x0D007AFF);
const Color lightHighlightText = Color(0xFF007AFF);
const Color darkBackground = Color(0xFF1C1C1E);
const Color darkBorder = Color(0xFF38383A);
const Color darkPrimaryText = Color(0xFFFFFFFF);
const Color darkDisabledText = Color(0xFFDBDBDB);
const Color darkSelectedBackground = Color(0x1A0A84FF);
const Color darkSelectedText = Color(0xFF0A84FF);
const Color darkHighlightBackground = Color(0x0D0A84FF);
const Color darkHighlightText = Color(0xFF0A84FF);
const Color darkRangeBackground = Color(0x1A0A84FF);
const Color darkRangeText = Color(0xFF0A84FF);
const Color lightTitleColor = lightPrimaryText;
const Color darkTitleColor = darkPrimaryText;

// ============================================================================
// 公共尺寸常量
// ============================================================================

const double borderWidth = 1.0;
const Radius noRadius = Radius.circular(0.0);

const Radius circular1 = Radius.circular(1.0);
const Radius circular100 = Radius.circular(100.0);

const BorderRadius circular100Radius = BorderRadius.all(circular100);
const BorderRadius circular1Radius = BorderRadius.all(circular1);

/// 标准边框宽度
const onlyRightBorderRadius = BorderRadius.only(
  topRight: circular100,
  bottomRight: circular100,
);

const onlyLeftBorderRadius = BorderRadius.only(
  topLeft: circular100,
  bottomLeft: circular100,
);
const noBorderRadius = BorderRadius.all(noRadius);
const TextStyle _baseTitleStyle = TextStyle(
  fontSize: 16.0,
  fontWeight: FontWeight.bold,
);

const TextStyle _baseDayTextStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);
const TextStyle _baseWeekDayTextStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.normal,
);
const BoxDecoration _baseCircularDecoration = BoxDecoration(
  borderRadius: circular100Radius,
);
final BoxDecoration _baseContainerDecoration = BoxDecoration(
  borderRadius: circular1Radius,
);

Border lightThemeBorder = Border.all(color: lightBorder, width: borderWidth);
Border darkThemeBorder = Border.all(color: darkBorder, width: borderWidth);

/// Theme constants definition for Flicker components
///
/// This class contains all the predefined colors, sizes, decorations, and text styles
/// used throughout the Flicker theme system. It provides both light and dark theme
/// variants following modern design principles.
class ThemeConstants {
  static BoxDecoration lightDecoration = _baseContainerDecoration.copyWith(
    color: lightBackground,
    border: lightThemeBorder,
  );
  static BoxDecoration lightSelectedDecoration = _baseCircularDecoration
      .copyWith(color: lightSelectedBackground);
  static BoxDecoration lightHighlightDecoration = _baseCircularDecoration
      .copyWith(color: lightHighlightBackground);

  static BoxDecoration darkDecoration = _baseContainerDecoration.copyWith(
    color: darkBackground,
    border: darkThemeBorder,
  );
  static BoxDecoration darkSelectedDecoration = _baseCircularDecoration
      .copyWith(color: darkSelectedBackground);

  static TextStyle lightDayStyle = _baseDayTextStyle.copyWith(
    color: lightPrimaryText,
  );

  static TextStyle lightTitleStyle = _baseTitleStyle.copyWith(
    color: lightTitleColor,
  );

  static TextStyle darkTitleStyle = _baseTitleStyle.copyWith(
    color: darkTitleColor,
  );
  static TextStyle lightWeekDayStyle = _baseWeekDayTextStyle.copyWith(
    color: lightSecondaryText,
  );
  static TextStyle lightDayDisabledStyle = _baseDayTextStyle.copyWith(
    color: lightDisabledText,
  );
  static TextStyle lightDaySelectedStyle = _baseDayTextStyle.copyWith(
    color: lightSelectedText,
  );
  static TextStyle lightDayHighlightStyle = _baseDayTextStyle.copyWith(
    color: lightHighlightText,
  );
  static TextStyle darkDayTextStyle = _baseDayTextStyle.copyWith(
    color: darkPrimaryText,
  );
  static TextStyle darkWeekDayTextStyle = _baseWeekDayTextStyle.copyWith(
    color: darkPrimaryText,
  );
  static TextStyle darkDayDisabledTextStyle = _baseDayTextStyle.copyWith(
    color: darkDisabledText,
  );
  static TextStyle darkDaySelectedStyle = _baseDayTextStyle.copyWith(
    color: darkSelectedText,
  );
  static TextStyle darkDayHighlightStyle = _baseDayTextStyle.copyWith(
    color: darkHighlightText,
  );
}

