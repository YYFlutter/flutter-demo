import 'package:flutter/material.dart';
import 'package:flutter_loading/http/loading.dart' show Loading;
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
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
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
  int _counter = 0;

  void _incrementCounter() {
    showDialog(
      context: context,
      builder: (context) {
        // 用Scaffold返回显示的内容，能跟随主题
        return Scaffold(
          backgroundColor: Colors.transparent, // 设置透明背影
          body: Center( // 居中显示
            child: Column( // 定义垂直布局
              mainAxisAlignment: MainAxisAlignment.center, // 主轴居中布局，相关介绍可以搜下flutter-ui的内容
              children: <Widget>[
                // CircularProgressIndicator自带loading效果，需要宽高设置可在外加一层sizedbox，设置宽高即可
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text('loading'), // 文字
                // 触发关闭窗口
                RaisedButton(
                  child: Text('close dialog'),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ), // 自带loading效果，需要宽高设置可在外加一层sizedbox，设置宽高即可
          ),
        );
      },
    );
  }
}
