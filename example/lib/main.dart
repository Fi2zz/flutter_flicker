import 'package:flutter/cupertino.dart';
import 'package:flutter_flicker/flutter_flicker.dart';
import 'demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final home = CupertinoPageScaffold(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: const FlickerPickerDemo(),
      ),
    );

    return CupertinoApp(
      title: 'Flicker Demo',
      home: home,
      locale: const Locale('en', 'US'),
      supportedLocales: FlickerL10n.supportedLocales,
      localizationsDelegates: [...FlickerL10n.localizationsDelegates],
    );
  }
}
