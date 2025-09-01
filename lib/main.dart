import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flicker.dart';
import 'demos/flicker_demo.dart';
import 'package:flutter_flicker/src/constants/ui_constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _currentLocale = const Locale('zh', 'CN');

  void _changeLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Flicker Demo',
      home: DemoNavigator(onLocaleChange: _changeLocale),
      locale: _currentLocale,
      supportedLocales: FlickerL10n.supportedLocales,
      localizationsDelegates: [...FlickerL10n.localizationsDelegates],
    );
  }
}

class DemoNavigator extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  
  const DemoNavigator({super.key, required this.onLocaleChange});
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        padding: EdgeInsets.all(SpacingConstants.defaultPadding),
        child: FlickerPickerDemo(onLocaleChange: onLocaleChange),
      ),
    );
  }
}
