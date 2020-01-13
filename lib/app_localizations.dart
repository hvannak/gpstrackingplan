
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AppLocalizations {
  Locale locale;
  static Map<dynamic, dynamic> _localisedValues;

  AppLocalizations(Locale locale) {
    this.locale = locale;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations appTranslations = AppLocalizations(locale);
    String jsonContent =
    await rootBundle.loadString('lang/${locale.languageCode}.json');
    _localisedValues = json.decode(jsonContent);
    return appTranslations;
  }

  get currentLanguage => locale.languageCode;

  String translate(String key) {
    return _localisedValues[key] ?? "$key not found";
  }
}
