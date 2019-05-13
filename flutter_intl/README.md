# 以$t形式使用flutter多语言

## 前言
关于flutter国际化的具体介绍，大家可以移步[国际化Flutter App](https://flutterchina.club/tutorials/internationalization/)

本文主要介绍在flutter如何使用多语言并且如何像web使用i18n一样使用多语言（$t）和实现语言切换,这对前端开发人员会更加友好。

## 项目地址
[flutter-ui](https://github.com/efoxTeam/flutter-ui), 这是包含flutter组件介绍的开源项目，欢迎star

[flutter_intl](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_intl) 本教程的项目源码，欢迎star

## 效果
![英文](https://user-gold-cdn.xitu.io/2019/5/13/16ab050e3802eacd?w=742&h=1548&f=png&s=99048)

![中文](https://user-gold-cdn.xitu.io/2019/5/13/16ab051b0d0dd4a0?w=768&h=1536&f=png&s=194623)

## 如何使用
### 添加依赖
* 在pubspec.yaml中引入依赖
``` dart
dependencies:
  flutter_localizations:
    sdk: flutter
```
* 执行
``` dart
flutter packages get
```
### 新建文件locale
``` dart
locale
    |-en.json
    |-zh.json
```
多语言的文件
* en.json
``` dart
{
    "title_page": "i18n",
    "title_appbar": "i18n",
    "content": {
        "currentLanguage": "The current language is English",
        "zh": "zh",
        "en": "en"
    }
}
```
* zh.json
``` dart
{
    "title_page": "国际化例子",
    "title_appbar": "国际化例子",
    "content": {
        "currentLanguage": "当前语言是中文",
        "zh": "中文",
        "en": "英文"
    }
}
```
### lib下新建lang
``` dart
lang
  |- config.dart
  |- index.dart
```
* config.dart
``` dart
import 'package:flutter/material.dart';

class ConfigLanguage {
  static List<Locale> supportedLocales = [
    Locale('zh', 'CH'),
    Locale('en', 'US')
  ];

  static Map<String, dynamic> supportLanguage = {
    "zh": {"code": "zh", "country_code": "CH"},
    "en": {"code": "en", "country_code": "US"},
  };

  static dynamic defaultLanguage = {
    "code": "zh",
    "country_code": "CH"
  };
}
```
config.dart作用主要是将配置性的内容统一到一个文件中
* index.dart
``` dart
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

// $t 封装，目的是为了可以使用$t来获取多语言数据
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


// 实现LocalizationsDelegate协议，用于初始化Localizations类
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  AppLocalizationsDelegate([this.locale]);

  @override
  bool isSupported(Locale locale) {
    return I18NConfig.ConfigLanguage.supportLanguage.keys
      .toList()
      .contains(locale.languageCode);
  }

// 在这里初始化Localizations类
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
```

详情请看代码注释~~~~~~~~~

概况一下就是

实现一个LocalizationsDelegate协议和实现一个Localizations类，然后引入到main.dart中的MaterialApp中

### 处理main.dart文件
``` dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_intl/lang/index.dart'
  show AppLocalizations, AppLocalizationsDelegate;
import 'package:flutter_intl/lang/config.dart' show ConfigLanguage;


void main () => runApp(MainApp());
GlobalKey<_ChangeLocalizationsState> changeLocalizationsStateKey = new GlobalKey<_ChangeLocalizationsState>();
class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // 定义全局 语言代理
  AppLocalizationsDelegate _delegate;

  @override
  void initState() {
    // TODO: implement initState
    _delegate = AppLocalizationsDelegate();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: Locale('zh', 'CH'),
      localeResolutionCallback: (deviceLocale, supportedLocal) {
        print('当前设备语种 deviceLocale: $deviceLocale, 支持语种 supportedLocale: $supportedLocal}');
        // 判断传入语言是否支持
        Locale _locale = supportedLocal.contains(deviceLocale) ? deviceLocale : Locale('zh', 'CN');
        return _locale;
      },
      onGenerateTitle: (context) {
        // 设置多语言代理
        // AppLocalizations.setProxy(setState, _delegate);
        return AppLocalizations.$t('title_page');
      },
      // localizationsDelegates 列表中的元素时生成本地化集合的工厂
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,   // 为Material Components库提供本地化的字符串和其他值
        GlobalWidgetsLocalizations.delegate,    // 定义widget默认的文本方向，从左往右或从右往左
        _delegate
      ],
      supportedLocales: ConfigLanguage.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => 
        // Home()
        Builder(builder: (context) {
          return ChangeLocalizations(
            key: changeLocalizationsStateKey,
            child: Home()
          );
        })
      }
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Locale locale = Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title: Text('${AppLocalizations.$t('title_appbar')}'),),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 60),
            alignment: Alignment.center,
            child: Text('${locale.languageCode} ${locale.toString()}'),
          ),
          Container(
            alignment: Alignment.center,
            child: Text('${AppLocalizations.$t('content.currentLanguage')}'),
          ),
          Wrap(
            spacing: 8.0,
            alignment: WrapAlignment.center,
            children: <Widget>[
              ActionChip(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  changeLocalizationsStateKey.currentState.changeLocale(Locale('en', 'US'));
                },
                label: Text('${AppLocalizations.$t('content.en')}'),
              ),
              ActionChip(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () {
                  changeLocalizationsStateKey.currentState.changeLocale(Locale('zh', 'CH'));
                },
                label: Text('${AppLocalizations.$t('content.zh')}'),
              )
            ],
          )
        ],
      )
    );
  }
}

class ChangeLocalizations extends StatefulWidget {
  final Widget child;
  ChangeLocalizations({Key key, this.child}):super(key: key);
  @override
  _ChangeLocalizationsState createState() => _ChangeLocalizationsState();
}

class _ChangeLocalizationsState extends State<ChangeLocalizations> {
  Locale _locale;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // 获取当前设备的语言
    _locale = Localizations.localeOf(context);
    print('设备语言: $_locale');
  }
  changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: _locale,
      child: widget.child,
    );
  }
}
```
* 在MaterialApp中指定localizationsDelegate和supportedLocales
    * localeResolutionCallback：在应用获取用户设置的语言区域时回调，可以根据需要return对应的Locale
    * onGenerateTitle： 返回对应的多语言应用标题
    * localizationsDelegates：localizationsDelegates 列表中的元素时生成本地化集合的工厂
    * supportedLocales: app支持的语言种类
* Home类就是显示的类
    * Localizations.localeOf(context).languageCode可以获取当前app的语言类型
    * AppLocalizations.$t('content.currentLanguage')像web一样玩耍多语言内容

到这里就已经可以愉快的玩耍多语言了，用户设置不同的语言就会加载不同的语言包

下面实现在app内的语言切换

* ChangeLocalizations类使用Localizations的override方法，代码如上
    * 使用GlobalKey调用ChangeLocalizations的内部方法，GlobalKey<_ChangeLocalizationsState> changeLocalizationsStateKey = new GlobalKey<_ChangeLocalizationsState>(); 我们也可以将GlobalKey放入到provide中，这样可以实现多个页面进行changeLocalizationsStateKey的访问
    * 修改语言调用changeLocale方法，changeLocalizationsStateKey.currentState.changeLocale(Locale('en', 'US'));


## 最后
欢迎更多学习flutter的小伙伴加入QQ群 Flutter UI： 798874340

敬请关注我们正在开发的: [efoxTeam/futter-ui](https://github.com/efoxTeam/flutter-ui)

[作者](https://github.com/DIVINER-onlys)
    














