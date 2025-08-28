import 'package:flutter/widgets.dart';
import 'package:flutter_flicker/src/views/date_helpers.dart';
import 'package:flutter_flicker/src/views/flicker_date_title.dart';
import 'package:flutter_flicker/src/views/flicker_swipable_view.dart';
import 'package:flutter_flicker/src/views/flicker_shared.dart';

class FlickerMonthControllerView extends StatelessWidget {
  final DateTime date;
  final bool Function(SwipeDirection) canTap;
  final Function(int) onTap;
  final VoidCallback? onTitleTap;
  final bool showTriangle;
  final int viewCount;
  const FlickerMonthControllerView({
    super.key,
    required this.canTap,
    required this.date,
    required this.onTap,
    this.viewCount = 1,
    this.onTitleTap,
    this.showTriangle = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget left = Chevron.left(
      touchable: canTap(SwipeDirection.backward),
      onTap: () => onTap(viewCount * -1),
    );
    Widget right = Chevron.right(
      touchable: canTap(SwipeDirection.forward),
      onTap: () => onTap(viewCount),
    );

    Widget currentTitle() {
      return FlickerDateTitle(
        date: date,
        onTap: showTriangle ? onTitleTap : null,
        roate: false,
        showTriangle: showTriangle, // Hide triangle
      );
    }

    if (viewCount == 1) {
      return Row(
        children: [
          Expanded(flex: 4, child: currentTitle()),
          left,
          right,
        ],
      );
    }

    return Row(
      children: [
        SizedBox(
          width: gridViewWidth,
          height: gridBasicSize,
          child: Row(
            children: [
              left,
              Expanded(flex: 1, child: Center(child: currentTitle())),
              SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          width: gridViewWidth,
          height: gridBasicSize,

          child: Row(
            children: [
              SizedBox.shrink(),
              Expanded(
                flex: 1,
                child: Center(
                  child: FlickerDateTitle(
                    date: DateHelpers.nextMonth(date),
                    showTriangle: false, // Hide triangle
                  ),
                ),
              ),
              right,
            ],
          ),
        ),
      ],
    );
  }
}
