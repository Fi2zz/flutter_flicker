import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';
import 'demos/flicker_demo.dart';
import 'package:flutter_flicker/demos/ui_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flicker Demo',
      home: const DemoNavigator(),
      locale: const Locale('zh', 'CN'),
      supportedLocales: FlickerL10n.supportedLocales,
      localizationsDelegates: [...FlickerL10n.localizationsDelegates],
    );
  }
}

class DemoNavigator extends StatelessWidget {
  const DemoNavigator({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: FlickerPickerDemo(),
      ),
    );
  }
}
