import 'package:flutter/widgets.dart';

const double baseSize = 40.0;
const double width = 7 * baseSize;
const double height = 5 * baseSize;
const Size horizontalSize = Size(width * 2, height);
const Size verticalSize = Size(width, (height + baseSize) * 2);
const Size defaultSize = Size(width, height);

Size computeSize(int count, Axis scrollDirection) {
  switch ((count, scrollDirection)) {
    case (2, Axis.horizontal):
      return horizontalSize;
    case (2, Axis.vertical):
      return verticalSize;
    default:
      return defaultSize;
  }
}

class BaseBox extends StatelessWidget {
  final Widget child;
  const BaseBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: Size(width, baseSize), child: child);
  }
}

class YearsBox extends StatelessWidget {
  final Widget child;
  const YearsBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: Size(width, height), child: child);
  }
}

class MonthBox extends StatelessWidget {
  final Widget child;
  const MonthBox({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: Size(width, height), child: child);
  }
}
