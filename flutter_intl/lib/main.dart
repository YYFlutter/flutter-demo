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