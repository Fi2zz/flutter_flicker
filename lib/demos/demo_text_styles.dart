import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/src/constants/ui_constants.dart';

/// Common text styles used throughout demos
class DemoTextStyles {
  /// Large title style for demo headers
  static const TextStyle largeTitle = TextStyle(
    fontSize: TypographyConstants.largeTitleFontSize,
    fontWeight: FontWeight.bold,
  );

  /// Standard bold text style for labels
  static const TextStyle standardBold = TextStyle(
    fontSize: TypographyConstants.standardFontSize,
    fontWeight: FontWeight.bold,
  );

  /// Standard normal text style
  static const TextStyle standardNormal = TextStyle(
    fontSize: TypographyConstants.standardFontSize,
    fontWeight: FontWeight.normal,
  );

  /// Standard medium weight text style
  static const TextStyle standardMedium = TextStyle(
    fontSize: TypographyConstants.standardFontSize,
    fontWeight: FontWeight.w500,
  );

  /// Small text style with medium weight
  static const TextStyle smallMedium = TextStyle(
    fontSize: TypographyConstants.smallFontSize,
    fontWeight: FontWeight.w500,
  );

  /// Small text style with bold weight
  static const TextStyle smallBold = TextStyle(
    fontSize: TypographyConstants.smallFontSize,
    fontWeight: FontWeight.bold,
  );

  /// Small text style with normal weight
  static const TextStyle smallNormal = TextStyle(
    fontSize: TypographyConstants.smallFontSize,
    fontWeight: FontWeight.normal,
  );

  /// Small text style with grey color
  static const TextStyle smallGrey = TextStyle(
    fontSize: TypographyConstants.smallFontSize,
    color: CupertinoColors.systemGrey,
  );

  /// Language selector text style for selected state
  static const TextStyle languageSelectorSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Language selector text style for normal state
  static const TextStyle languageSelectorNormal = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Selected info text style
  static const TextStyle selectedInfo = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Creates a text style with dynamic color based on dark mode
  static TextStyle withDynamicColor(TextStyle baseStyle, bool isDarkMode) {
    return baseStyle.copyWith(
      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  /// Creates a text style with color opposite to system brightness
  static TextStyle withSystemOppositeColor(TextStyle baseStyle, BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    // Use opposite color: if system is dark, use black text; if system is light, use white text
    return baseStyle.copyWith(
      color: brightness == Brightness.dark ? CupertinoColors.white : CupertinoColors.black,
    );
  }

  /// Creates a text style with specific color
  static TextStyle withColor(TextStyle baseStyle, Color color) {
    return baseStyle.copyWith(color: color);
  }
}
