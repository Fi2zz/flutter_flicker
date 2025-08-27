import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Localization delegate for Flicker date picker
class FlickerL10nDelegate extends LocalizationsDelegate<FlickerL10n> {
  const FlickerL10nDelegate();
  @override
  bool isSupported(Locale locale) {
    return [
      'en',
      'zh',
      'es',
      'fr',
      'de',
      'ja',
      'ko',
    ].contains(locale.languageCode);
  }

  @override
  Future<FlickerL10n> load(Locale locale) async {
    return FlickerL10n(locale);
  }

  @override
  bool shouldReload(FlickerL10nDelegate old) => false;
}

/// Localization class for Flicker date picker
class FlickerL10n {
  final Locale locale;

  const FlickerL10n(this.locale);

  /// Default localization instance (English)
  static const FlickerL10n defaultL10n = FlickerL10n(Locale('en', 'US'));

  static FlickerL10n? of(BuildContext context) {
    return Localizations.of<FlickerL10n>(context, FlickerL10n);
  }

  /// Get localization instance with fallback to default
  static FlickerL10n maybeOf(BuildContext context) {
    return Localizations.of<FlickerL10n>(context, FlickerL10n) ?? defaultL10n;
  }

  static const LocalizationsDelegate<FlickerL10n> delegate =
      FlickerL10nDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    FlickerL10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('en', 'GB'),
    Locale('en', 'CA'),
    Locale('en', 'AU'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('es', 'ES'),
    Locale('es', 'MX'),
    Locale('fr', 'FR'),
    Locale('fr', 'CA'),
    Locale('de', 'DE'),
    Locale('de', 'AT'),
    Locale('ja', 'JP'),
    Locale('ko', 'KR'),
  ];

  /// Month names in different languages
  static const Map<String, List<String>> _monthNames = {
    'en': [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
    'zh': [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ],
    'es': [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ],
    'fr': [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ],
    'de': [
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ],
    'ja': [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月',
    ],
    'ko': [
      '1월',
      '2월',
      '3월',
      '4월',
      '5월',
      '6월',
      '7월',
      '8월',
      '9월',
      '10월',
      '11월',
      '12월',
    ],
  };

  /// Weekday names in different languages
  static const Map<String, List<String>> _weekdayNames = {
    'en': ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
    'zh': ['日', '一', '二', '三', '四', '五', '六'],
    'es': ['Do', 'Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sá'],
    'fr': ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'],
    'de': ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
    'ja': ['日', '月', '火', '水', '木', '金', '土'],
    'ko': ['일', '월', '화', '수', '목', '금', '토'],
  };

  /// First day of week configuration by locale (0=Sunday, 1=Monday, etc.)
  static const Map<String, int> _firstDayOfWeek = {
    'en': 0, // Sunday
    'zh': 1, // Monday
    'es': 1, // Monday
    'fr': 1, // Monday
    'de': 1, // Monday
    'ja': 0, // Sunday
    'ko': 0, // Sunday
  };

  List<String> get monthNames =>
      _monthNames[locale.languageCode] ?? _monthNames['en']!;
  List<String> get weekdayNames =>
      _weekdayNames[locale.languageCode] ?? _weekdayNames['en']!;

  /// Get the first day of week for current locale (0=Sunday, 1=Monday, etc.)
  int get firstDayOfWeek => _firstDayOfWeek[locale.languageCode] ?? 0;

  //
  /// Date format patterns for different locales
  String get monthYearFormat {
    switch (locale.languageCode) {
      case 'zh':
        return 'yyyy年M月';
      case 'ja':
      case 'ko':
        return 'yyyy年M月';
      default:
        return 'MMMM yyyy';
    }
  }
}
