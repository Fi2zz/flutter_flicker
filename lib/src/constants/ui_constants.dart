/// UI Constants for Flutter Flicker
///
/// This file contains all the hardcoded UI values used throughout the application
/// to improve maintainability and consistency.

// ============================================================================
// GRID CONSTANTS
// ============================================================================

/// Calendar grid constants
class CalendarGridConstants {
  /// Number of days in a week (for crossAxisCount in GridView)
  static const int daysPerWeek = 7;
  
  /// Square aspect ratio for calendar cells
  static const double cellAspectRatio = 1.0;
}

// ============================================================================
// SPACING CONSTANTS
// ============================================================================

/// Common spacing values used throughout the app
class SpacingConstants {
  /// Standard padding for containers
  static const double standardPadding = 16.0;
  
  /// Default padding (alias for standardPadding)
  static const double defaultPadding = 16.0;
  
  /// Vertical spacing between elements
  static const double verticalSpacing = 20.0;
  
  /// Small vertical margin
  static const double smallVerticalMargin = 4.0;
  
  /// Calendar view padding
  static const double calendarVerticalPadding = 16.0;
  static const double calendarHorizontalPadding = 12.0;
  
  /// Title view horizontal padding
  static const double titleHorizontalPadding = 16.0;
}

// ============================================================================
// TYPOGRAPHY CONSTANTS
// ============================================================================

/// Font size constants
class TypographyConstants {
  /// Large title font size
  static const double largeTitleFontSize = 24.0;
  
  /// Standard text font size
  static const double standardFontSize = 16.0;
  
  /// Small text font size
  static const double smallFontSize = 14.0;
}

// ============================================================================
// ICON CONSTANTS
// ============================================================================

/// Icon size constants
class IconConstants {
  /// Standard icon size
  static const double standardIconSize = 24.0;
  
  /// Small icon size
  static const double smallIconSize = 20.0;
  
  /// Extra small icon size
  static const double extraSmallIconSize = 12.0;
}

/// Icon drawing constants
class IconDrawingConstants {
  /// Stroke width for custom icons
  static const double strokeWidth = 2.0;
  
  /// Arrow width as percentage of container
  static const double arrowWidthRatio = 0.15;
  
  /// Arrow height as percentage of container
  static const double arrowHeightRatio = 0.35;
  
  /// Triangle height as percentage of container
  static const double triangleHeightRatio = 0.4;
  
  /// Triangle width as percentage of container
  static const double triangleWidthRatio = 0.8;
}

// ============================================================================
// LAYOUT CONSTANTS
// ============================================================================

/// Layout dimension constants
class LayoutConstants {
  /// Standard spacing between elements
  static const double standardSpacing = 16.0;
}