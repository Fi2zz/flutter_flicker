import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/flicker_shared.dart';
import 'package:intl/intl.dart';
import 'flicker_extensions.dart';

/// Month/Year title widget
///
/// Displays the current month and year, optionally making it tappable
/// to switch between month and year views
class FlickerDateTitle extends StatelessWidget {
  /// The date to display in the title
  final DateTime date;

  /// Optional callback when title is tapped
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;

  /// Whether to show rotation indicator (triangle)
  final bool? roate;

  /// Whether to show the triangle indicator
  final bool showTriangle;

  const FlickerDateTitle({
    super.key,
    required this.date,
    this.onTap,
    this.roate = false,
    this.padding,
    this.showTriangle = true,
  });

  /// Formats a date as month/year string based on locale
  String _formatMonth(BuildContext context, DateTime date) {
    final i10n = context.flickerL10n;
    final formatString = i10n.monthYearFormat;
    final formatter = DateFormat(formatString, i10n.locale.toString());
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final title = Text(
      _formatMonth(context, date),
      style: context.flickerTheme.titleTextStyle,
    );
    Widget child = title;
    if (onTap != null) {
      child = Tappable(
        onTap: onTap,
        tappable: true,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 8,
          children: [
            title,
            if (showTriangle) Triangle(active: roate),
          ],
        ),
      );
    }

    return Container(padding: padding, child: child);
  }
}
