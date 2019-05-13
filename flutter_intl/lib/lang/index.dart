import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_intl/lang/config.dart' as I18NConfig;
class AppLocalizations {
  Locale _locale;
  static Map<String, dynamic> jsonLanguage; // 语言包
  static AppLocalizations _inst; // inst

  AppLocalizations(this._locale);

  // 初始化 localizations
  static Future<AppLocalizations> init(Locale locale) async {
    _inst = AppLocalizations(locale);
    await getLanguageJson();
    return _inst;
  }

  // 获取语言包
  static Future getLanguageJson() async {
    Locale _tmpLocale = _inst._locale;
    print('获取语言包的语种; ${_tmpLocale.languageCode}');
    String jsonLang;
    try {
      jsonLang = await rootBundle.loadString('locale/${_tmpLocale.languageCode}.json');
    } catch (e) {
      print('出错了');
      _inst._locale = Locale(I18NConfig.ConfigLanguage.defaultLanguage['code']);
      jsonLang = await rootBundle.loadString('locale/${I18NConfig.ConfigLanguage.defaultLanguage['code']}.json');
    }
    jsonLanguage = json.decode(jsonLang);
    print("当前语言： ${_inst._locale}");
    print("数据： $jsonLanguage");
  }

  static String $t(String key) {
    var _array = key.split('.');
    var _dict = jsonLanguage;
    var retValue = '';
    try {
      _array.forEach((item) {
        if(_dict[item].runtimeType == Null) {
          retValue = key;
          return;
        }
        if (_dict[item].runtimeType != String) {
          _dict = _dict[item];
        } else {
          retValue = _dict[item];
        }
      });
      retValue = retValue.isEmpty ? _dict : retValue;
    } catch (e) {
      print('i18n exception');
      print(e);
      retValue = key;
    }

    return retValue ?? '';
  }

}


class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  AppLocalizationsDelegate([this.locale]);

  @override
  bool isSupported(Locale locale) {
    return I18NConfig.ConfigLanguage.supportLanguage.keys
      .toList()
      .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale _locale) async {
    print('将要加载的语言: $_locale');
    return await AppLocalizations.init(_locale);
    // return SynchronousFuture<AppLocalizations>(
    //   AppLocalizations(_locale)
    // );
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    // flase时，不执行上述重写函数
    return false;
  }
}