import 'package:flutter/widgets.dart';

enum AppLocale {
  en('en'),
  pl('pl');

  const AppLocale(this.code);
  final String code;

  static AppLocale fromCode(String? code) {
    return AppLocale.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLocale.en,
    );
  }

  Locale toLocale() => Locale(code);
}

class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier(this._locale);

  AppLocale _locale;
  AppLocale get locale => _locale;

  set locale(AppLocale value) {
    if (_locale == value) return;
    _locale = value;
    notifyListeners();
  }
}

class LocaleScope extends InheritedNotifier<LocaleNotifier> {
  const LocaleScope({
    super.key,
    required LocaleNotifier super.notifier,
    required super.child,
  });

  static AppLocale of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in widget tree');
    return scope!.notifier!.locale;
  }

  static LocaleNotifier notifierOf(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<LocaleScope>()
        ?.widget as LocaleScope?;
    assert(scope != null, 'LocaleScope not found in widget tree');
    return scope!.notifier!;
  }
}

extension AppLocaleTr on BuildContext {
  String tr({required String en, required String pl}) {
    final locale = LocaleScope.of(this);
    return locale == AppLocale.pl ? pl : en;
  }
}
