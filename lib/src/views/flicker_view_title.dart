import 'package:flutter/widgets.dart';
import 'flicker_shared.dart';
import 'flicker_tappable.dart';
import 'package:intl/intl.dart';
import 'flicker_extensions.dart';

/// Month/Year title widget
///
/// Displays the current month and year, optionally making it tappable
/// to switch between month and year views
class FlickerViewTitle extends StatelessWidget {
  /// The date to display in the title
  final DateTime date;

  /// Optional callback when title is tapped
  final Function()? onTap;
  final EdgeInsetsGeometry? padding;

  /// Whether to show rotation indicator (triangle)
  final bool? roate;
  final bool? centerred;

  /// Whether to show the triangle indicator
  final bool showTriangle;

  /// Optional flex parameter
  final int? flex;

  const FlickerViewTitle({
    super.key,
    required this.date,
    this.onTap,
    this.roate = false,
    this.padding,
    this.showTriangle = true,
    this.flex,
    this.centerred = false,
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
        padding: EdgeInsets.symmetric(horizontal: 16.0),
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

    Widget containerChild = Container(padding: padding, child: child);

    if (centerred == true) containerChild = Center(child: containerChild);
    if (flex != null) return Expanded(flex: flex!, child: containerChild);
    return containerChild;
  }
}
