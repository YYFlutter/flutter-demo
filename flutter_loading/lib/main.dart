import 'package:flutter/material.dart';
import 'package:flutter_loading/http/loading.dart' show Loading;
import 'http/index.dart' show Http;
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    print('main${Navigator.of(context)}');
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    print('home  $context');
    print('home  ${Navigator.of(context)}');
    Loading.ctx = context; // 注入context
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '该用例只是简单实现一个弹窗',
            ),
            Text("具体的关键点在于使用Scaffold中的context对象"),
            Text(
              '建议依项目特点进行完善',
            ),
            RaisedButton(
              child: Text("跳转页面"),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return Scaffold(
                    body: Center(
                      child: Text('点击按钮试下loading效果'),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: _incrementCounter,
                      tooltip: 'Increment',
                      child: Icon(Icons.add),
                    ),
                  );
                }));
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _incrementCounter() {
//    Loading.before('loading...');
    Http.get('https://raw.githubusercontent.com/efoxTeam/flutter-ui/master/version.json');
    Http.get('https://raw.githubusercontent.com/efoxTeam/flutter-ui/master/version.json');
    Http.get('https://raw.githubusercontent.com/efoxTeam/flutter-ui/master/version.json');
  }
}
