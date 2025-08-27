import 'package:flutter/widgets.dart';
export 'date_helpers.dart';

/// Base dimensions for consistent sizing throughout the date picker
const double basicSize = 40.0;
const double gridViewWidth = 7 * basicSize;
const double gridViewHeight = 5 * basicSize;

/// Predefined sizes for common widgets
Size fixedSize = Size(gridViewWidth, basicSize);
Size yearSize = Size(gridViewWidth, gridViewHeight);
Size monthSize = Size(gridViewWidth, gridViewHeight);
double maxWidth(Axis scrollDirection, int viewCount) {
  // return context.flickerTheme.maxWidth;
  return scrollDirection == Axis.vertical
      ? gridViewWidth
      : gridViewWidth * viewCount;
}

double maxHeight(Axis scrollDirection, int viewCount) {
  return scrollDirection == Axis.vertical
      ? gridViewHeight * viewCount + basicSize * viewCount
      : gridViewHeight;
}
