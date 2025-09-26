import 'package:flutter/widgets.dart';
import 'package:flutter/painting.dart';

/// Theme constants for Flicker date picker components
///
/// This file contains all the color, size, and styling constants used throughout
/// the Flicker date picker theme system. It provides a centralized location for
/// managing visual consistency across light and dark themes.
///
/// ## Color System
///
/// The color system is organized into light and dark theme variants, with each
/// providing colors for different UI states and elements:
/// - Background and border colors
/// - Text colors for different states (primary, secondary, disabled)
/// - Selection and highlight colors
/// - Range selection colors
///
/// ## Design Principles
///
/// - **Consistency**: Unified color palette across all components
/// - **Adaptability**: Seamless light/dark mode transitions
/// - **iOS Design Language**: Colors inspired by iOS Human Interface Guidelines

// ============================================================================
// Light Theme Colors
// ============================================================================

/// Pure white background color for light theme
const Color lightBackground = Color(0xFFFFFFFF);

/// Light gray border color for separators and outlines
const Color lightBorder = Color(0xFFE5E5EA);

/// Primary text color for light theme - near black for high contrast
const Color lightPrimaryText = Color(0xFF0B0B0B);

/// Secondary text color for light theme - medium gray for less emphasis
const Color lightSecondaryText = Color(0xFF8E8E93);

/// Disabled text color for light theme - light gray for inactive elements
const Color lightDisabledText = Color(0xFFA6A5A5);

/// Selected background color for light theme - translucent blue
const Color lightSelectedBackground = Color(0x1A007AFF);

/// Selected text color for light theme - iOS blue
const Color lightSelectedText = Color(0xFF007AFF);

/// Highlight background color for light theme - very light blue
const Color lightHighlightBackground = Color(0x0D007AFF);

/// Highlight text color for light theme - iOS blue
const Color lightHighlightText = Color(0xFF007AFF);

// ============================================================================
// Dark Theme Colors
// ============================================================================

/// Dark background color for dark theme - iOS dark gray
const Color darkBackground = Color(0xFF1C1C1E);

/// Dark border color for separators and outlines
const Color darkBorder = Color(0xFF38383A);

/// Primary text color for dark theme - pure white for high contrast
const Color darkPrimaryText = Color(0xFFFFFFFF);

/// Disabled text color for dark theme - light gray for inactive elements
const Color darkDisabledText = Color(0xFFDBDBDB);

/// Selected background color for dark theme - translucent blue
const Color darkSelectedBackground = Color(0x1A0A84FF);

/// Selected text color for dark theme - iOS dark mode blue
const Color darkSelectedText = Color(0xFF0A84FF);

/// Highlight background color for dark theme - very light blue
const Color darkHighlightBackground = Color(0x0D0A84FF);

/// Highlight text color for dark theme - iOS dark mode blue
const Color darkHighlightText = Color(0xFF0A84FF);

/// Range background color for dark theme - translucent blue
const Color darkRangeBackground = Color(0x1A0A84FF);

/// Range text color for dark theme - iOS dark mode blue
const Color darkRangeText = Color(0xFF0A84FF);

// ============================================================================
// Title Colors
// ============================================================================

/// Title color for light theme - uses primary text color
const Color lightTitleColor = lightPrimaryText;

/// Title color for dark theme - uses primary text color
const Color darkTitleColor = darkPrimaryText;

// ============================================================================
// Typography Constants
// ============================================================================

/// Small font size for secondary text elements
const double smallFontSize = 14.0;

/// Default font size for primary text elements
const double defaultFontSize = 16.0;

// ============================================================================
// Size and Dimension Constants
// ============================================================================

/// Standard border width for UI elements
const double borderWidth = 1.0;

/// No radius - creates sharp corners
const Radius noRadius = Radius.circular(0.0);

/// Small radius for subtle rounded corners
const Radius circular1 = Radius.circular(1.0);

/// Large radius for fully rounded elements (circular)
const Radius circular100 = Radius.circular(100.0);

/// Fully circular border radius for buttons and selections
const BorderRadius circular100Radius = BorderRadius.all(circular100);

/// Subtle rounded border radius for containers
const BorderRadius circular1Radius = BorderRadius.all(circular1);

/// No border radius - creates sharp rectangular corners
const BorderRadius noBorderRadius = BorderRadius.all(noRadius);

/// Right-side only circular border radius for range selections
const BorderRadius onlyRightBorderRadius = BorderRadius.only(
  topRight: circular100,
  bottomRight: circular100,
);

/// Left-side only circular border radius for range selections
const BorderRadius onlyLeftBorderRadius = BorderRadius.only(
  topLeft: circular100,
  bottomLeft: circular100,
);

// ============================================================================
// Base Text Style Templates
// ============================================================================

/// Base text style for title elements - bold and prominent
const TextStyle _baseTitleStyle = TextStyle(
  fontSize: defaultFontSize,
  fontWeight: FontWeight.bold,
);

/// Base text style for day numbers - normal weight and readable
const TextStyle _baseDayTextStyle = TextStyle(
  fontSize: smallFontSize,
  fontWeight: FontWeight.normal,
);

/// Base text style for weekday labels - normal weight and compact
const TextStyle _baseWeekDayTextStyle = TextStyle(
  fontSize: smallFontSize,
  fontWeight: FontWeight.normal,
);

// ============================================================================
// Base Decoration Templates
// ============================================================================

/// Base circular decoration for selected states and buttons
const BoxDecoration _baseCircularDecoration = BoxDecoration(
  borderRadius: circular100Radius,
);

/// Base container decoration for the main picker container
final BoxDecoration _baseContainerDecoration = const BoxDecoration(
  borderRadius: circular1Radius,
);

// ============================================================================
// Theme-specific Borders
// ============================================================================

/// Light theme border with appropriate color and width
Border lightThemeBorder = Border.all(color: lightBorder, width: borderWidth);

/// Dark theme border with appropriate color and width
Border darkThemeBorder = Border.all(color: darkBorder, width: borderWidth);

/// Comprehensive theme constants provider for Flicker date picker components
///
/// [ThemeConstants] serves as a centralized factory for creating consistent
/// visual styles across the Flicker date picker. It combines base templates
/// with theme-specific colors to generate complete styling definitions.
///
/// ## Design Philosophy
///
/// - **Consistency**: All styles derive from shared base templates
/// - **Maintainability**: Changes to base styles automatically propagate
/// - **Theme Support**: Complete light and dark mode implementations
/// - **Performance**: Static definitions for optimal runtime performance
///
/// ## Usage
///
/// This class is primarily used internally by the theme system, but can be
/// accessed directly for custom styling needs:
///
/// ```dart
/// // Access predefined decorations
/// final decoration = ThemeConstants.lightDecoration;
/// final selectedDecoration = ThemeConstants.lightSelectedDecoration;
///
/// // Access text styles
/// final titleStyle = ThemeConstants.lightTitleStyle;
/// final dayStyle = ThemeConstants.lightDayStyle;
/// ```
class ThemeConstants {
  // ============================================================================
  // Light Theme Decorations
  // ============================================================================

  /// Main container decoration for light theme
  /// Combines light background color with appropriate border
  static BoxDecoration lightDecoration = _baseContainerDecoration.copyWith(
    color: lightBackground,
    border: lightThemeBorder,
  );

  /// Selected date decoration for light theme
  /// Circular background with light theme selection color
  static BoxDecoration lightSelectedDecoration = _baseCircularDecoration
      .copyWith(color: lightSelectedBackground);

  /// Highlighted date decoration for light theme
  /// Circular background with light theme highlight color
  static BoxDecoration lightHighlightDecoration = _baseCircularDecoration
      .copyWith(color: lightHighlightBackground);

  // ============================================================================
  // Dark Theme Decorations
  // ============================================================================

  /// Main container decoration for dark theme
  /// Combines dark background color with appropriate border
  static BoxDecoration darkDecoration = _baseContainerDecoration.copyWith(
    color: darkBackground,
    border: darkThemeBorder,
  );

  /// Selected date decoration for dark theme
  /// Circular background with dark theme selection color
  static BoxDecoration darkSelectedDecoration = _baseCircularDecoration
      .copyWith(color: darkSelectedBackground);

  // ============================================================================
  // Light Theme Text Styles
  // ============================================================================

  /// Standard day text style for light theme
  /// Normal weight with primary text color for good readability
  static TextStyle lightDayStyle = _baseDayTextStyle.copyWith(
    color: lightPrimaryText,
  );

  /// Title text style for light theme
  /// Bold weight with title color for prominence
  static TextStyle lightTitleStyle = _baseTitleStyle.copyWith(
    color: lightTitleColor,
  );

  /// Weekday label text style for light theme
  /// Secondary color for reduced emphasis
  static TextStyle lightWeekDayStyle = _baseWeekDayTextStyle.copyWith(
    color: lightSecondaryText,
  );

  /// Disabled day text style for light theme
  /// Muted color to indicate non-interactive state
  static TextStyle lightDayDisabledStyle = _baseDayTextStyle.copyWith(
    color: lightDisabledText,
  );

  /// Selected day text style for light theme
  /// Accent color to indicate selection state
  static TextStyle lightDaySelectedStyle = _baseDayTextStyle.copyWith(
    color: lightSelectedText,
  );

  /// Highlighted day text style for light theme
  /// Accent color for hover or focus states
  static TextStyle lightDayHighlightStyle = _baseDayTextStyle.copyWith(
    color: lightHighlightText,
  );

  // ============================================================================
  // Dark Theme Text Styles
  // ============================================================================

  /// Title text style for dark theme
  /// Bold weight with dark theme title color
  static TextStyle darkTitleStyle = _baseTitleStyle.copyWith(
    color: darkTitleColor,
  );

  /// Standard day text style for dark theme
  /// Primary text color optimized for dark backgrounds
  static TextStyle darkDayTextStyle = _baseDayTextStyle.copyWith(
    color: darkPrimaryText,
  );

  /// Weekday label text style for dark theme
  /// Primary color for good visibility on dark backgrounds
  static TextStyle darkWeekDayTextStyle = _baseWeekDayTextStyle.copyWith(
    color: darkPrimaryText,
  );

  /// Disabled day text style for dark theme
  /// Muted color appropriate for dark theme
  static TextStyle darkDayDisabledTextStyle = _baseDayTextStyle.copyWith(
    color: darkDisabledText,
  );

  /// Selected day text style for dark theme
  /// Dark theme accent color for selection indication
  static TextStyle darkDaySelectedStyle = _baseDayTextStyle.copyWith(
    color: darkSelectedText,
  );

  /// Highlighted day text style for dark theme
  /// Dark theme accent color for interactive states
  static TextStyle darkDayHighlightStyle = _baseDayTextStyle.copyWith(
    color: darkHighlightText,
  );
}
