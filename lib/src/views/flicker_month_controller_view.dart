import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/utils/constants.dart';
import 'package:flutter_flicker/src/views/flicker_date_title.dart';
import 'package:flutter_flicker/src/views/shared.dart';

class FlickerMonthControllerView extends StatelessWidget {
  final DateTime date;
  final bool Function(int)? canTap;
  final ValueChanged<int> onTap;
  final VoidCallback? onTitleTap;
  final int viewCount;
  const FlickerMonthControllerView({
    super.key,
    required this.date,
    required this.onTap,
    this.viewCount = 1,
    this.onTitleTap,
    this.canTap,
  });

  Widget _currentTitle({VoidCallback? onTap, bool? rotate}) {
    return FlickerDateTitle(date: date, onTap: onTap, roate: rotate);
  }

  Widget _nextTitle() => FlickerDateTitle(date: DateHelpers.nextMonth(date));

  static FlickerDateTitle title({required DateTime date}) {
    return FlickerDateTitle(date: date);
  }

  static FlickerDateTitle nextTitle({required DateTime date}) {
    return FlickerDateTitle(date: DateHelpers.nextMonth(date));
  }

  @override
  Widget build(BuildContext context) {
    Widget left = Chevron.left(
      touchable: canTap?.call(-1) ?? true,
      onTap: () => onTap(viewCount),
    );
    Widget right = Chevron.right(
      touchable: canTap?.call(1) ?? true,
      onTap: () => onTap(viewCount),
    );

    if (viewCount == 1) {
      return Row(
        children: [
          Expanded(
            flex: 4,
            child: _currentTitle(onTap: onTitleTap, rotate: false),
          ),
          left,
          right,
        ],
      );
    }

    return Row(
      children: [
        SizedBox.fromSize(
          size: fixedSize,
          child: Row(
            children: [
              left,
              Expanded(flex: 1, child: Center(child: _currentTitle())),
              SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox.fromSize(
          size: fixedSize,
          child: Row(
            children: [
              SizedBox.shrink(),
              Expanded(flex: 1, child: Center(child: _nextTitle())),
              right,
            ],
          ),
        ),
      ],
    );
  }
}
