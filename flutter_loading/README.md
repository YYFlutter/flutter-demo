# Flutter 全局弹窗
#### 背景
> - 开发[flutter-ui](https://github.com/efoxTeam/flutter-ui)过程中，遇到了全局弹窗问题
> - 友好的交互界面，能够产生更好的用户体验，比如查询接口较久或需要耗时处理程序时，给个loading效果。
> - flutter组件中showDialog弹窗组件，能满足弹窗需求，但使用过程可能不太顺手。

将从以下几点来分析与实现接口请求前的弹窗效果
- showDialog介绍
- 实现简单弹窗
- 接入[dio package](https://pub.dartlang.org/packages/dio)
- 弹窗关键点分析
- 实现全局存储context
- 实现dio请求时loading
- 并发请求时loading处理

本文相关链接
- [flutter-ui](https://github.com/efoxTeam/flutter-ui)
- [dio](https://pub.dartlang.org/packages/dio)
- [provide](https://pub.dartlang.org/packages/provide)


### 准备
- 新建项目flutter create xxx (有项目就用自己项目，影响的地方不大)
- pubspec.yaml增加dio依赖包
```
dependencies:
  flutter:
    sdk: flutter
  dio: ^2.1.0 # dio依赖包 2019/03/30
```
- 创建http文件夹与http/index.dart， http/loading.dart文件
```
lib
  |--http   #文件
	  |--index.dart  # dio
	  |--loading.dart  #loading
  |--main.dart #入口 
```

### showDialog介绍
```
showDialog{
  @required BuildContext context,
  bool barrierDismissible = true,
  @Deprecated(
    'Instead of using the "child" argument, return the child from a closure '
    'provided to the "builder" argument. This will ensure that the BuildContext '
    'is appropriate for widgets built in the dialog.'
  ) Widget child,
  WidgetBuilder builder,
}
```
* builder：创建弹窗的组件，这些可以创建需要的交互内容
* context：上下文，这里只要打通了，就能实现全局。这是关键

> 查看showDialog源码，调用顺序是  
> showDialog -> showGeneralDialog -> Navigator.of(context, rootNavigator: true).push()
> context作为参数，作用是提供给了Navigator.of(context, rootNavigator: true).push使用 


* showGeneralDialog的注释内容，介绍了关闭弹窗的重点
```
/// The dialog route created by this method is pushed to the root navigator.
/// If the application has multiple [Navigator] objects, it may be necessary to
/// call `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// dialog rather than just `Navigator.pop(context, result)`.
///
/// See also:
///
///  * [showDialog], which displays a Material-style dialog.
///  * [showCupertinoDialog], which displays an iOS-style dialog.
```

### 实现简单弹窗
- demo中floatingActionButton中_incrementCounter事件，事件触发后显示弹窗，具体内容可结合代码注解
```

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
                    print('close');
                  },
                ),
              ],
            ), // 自带loading效果，需要宽高设置可在外加一层sizedbox，设置宽高即可
          ),
        );
      },
    );
  }
```
<img src="https://raw.githubusercontent.com/efoxTeam/flutter-demo/master/flutter_loading/assets/loading.jpg" width = "260" height = "480" div align=center />

点击后出来了弹窗了，这一切还没有结束，只是个开始。
关闭弹窗，点击物理返回键就后退了。（尴尬不）
在上面showDialog介绍中最后提供了一段关于showGeneralDialog的注释代码，若需要关闭窗口，可以通过调用 Navigator.of(context, rootNavigator: true).pop(result)。
修改下RaisedButton事件内容
```
RaisedButton(
  child: Text('close dialog'),
  onPressed: () {
    Navigator.of(context, rootNavigator: true).pop();
  },
),
```
这样弹窗可以通过按钮控制关闭了

### 接入dio
在触发接口请求时，先调用showDialog触发弹窗，接口请求完成关闭窗口
- http/index.dart 实现get接口请求，同时增加interceptors，接入onRequest、onResponse、onError函数，伪代码如下
```
import 'package:dio/dio.dart' show Dio, DioError, InterceptorsWrapper, Response;

Dio dio;

class Http {
  static Dio instance() {
    if (dio != null) {
      return dio;// 实例化dio
    }
    dio = new Dio();
    // 增加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        // 接口请求前数据处理
        onRequest: (options) {
          return options;
        },
        // 接口成功返回时处理
        onResponse: (Response resp) {
          return resp;
        },
        // 接口报错时处理
        onError: (DioError error) {
          return error;
        },
      ),
    );
    return dio;
  }

  /**
   * get接口请求
   * path: 接口地址
   */
  static get(path) {
    return instance().get(path);
  }
}

```
- http/loading.dart 实现弹窗，dio在onRequest时调用 Loading.before，onResponse/onError调用Loading。complete完毕窗口，伪代码如下
```
import 'package:flutter/material.dart';

class Loading {
  static void before(text) {
    // 请求前显示弹窗
    // showDialog();
  }

  static void complete() {
    // 完成后关闭loading窗口
	// Navigator.of(context, rootNavigator: true).pop();
  }
}


// 弹窗内容
class Index extends StatelessWidget {
  final String text;

  Index({Key key, @required this.text}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return xxx;
  }
}

```

### 弹窗关键点分析
#### context
> 解决了showDialog中的context，即能实现弹窗任意调用，不局限于dio请求。context不是任意的，只在Scaffold中能够使Navigator.of(context)中找得到Navigator对象。（刚接触时很多时候会觉得同样都是context，为啥调用of(context)会报错。）
```
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('main${Navigator.of(context)}'); // !!!这里发报错!!!
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
  ... // 省略其它内容
}

错误内容如下：
I/flutter ( 9137): Navigator operation requested with a context that does not include a Navigator.
I/flutter ( 9137): The context used to push or pop routes from the Navigator must be that of a widget that is a
I/flutter ( 9137): descendant of a Navigator widget.

即在MaterialApp中未能找到。

```
让我们在_MyHomePageState中查看下build返回Scaffold时，context对象内容是否有Navigator对象
```
class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    print('home${Navigator.of(context)}');  // 正常打印NavigatorState#600dc(tickers: tracking 1 ticker)
    
  }
  ... // 省略其它内容
}
```
所以全局弹窗的context，需要scaffold中的context。项目初始时在build第一次返回scaffold组件前，把context全局存储起来，提供能showDialog使用。（第一次返回没有局限，只要在调用showDiolog调用前全局保存context即可，自行而定。），至此可以解决了dio中调用showDialog时，context经常运用错误导致报错问题。
- 这里是扩展分析[flutter-ui](https://github.com/efoxTeam/flutter-ui)中与[provide](https://pub.dartlang.org/packages/provide)结合使用后遇到的context。
- flutter-ui先通过Store.connect封装provide数据层，这里的context返回的provide实例的上下文，接着return MaterialApp中，这里的上下文也是MaterialApp本身的，这些都没法使用Navigator对象，最终在build Scaffold时，通过Provide数据管理提前setWidgetCtx，全局保存Scaffold提供的context。

#### 实现全局存储context
> 1 在http/loading.dart文件的Loading类暂存一个context静态变量。
```
class Loading {
  static dynamic ctx;
  static void before(text) {
    // 请求前显示弹窗
//    showDialog(context: ctx, builder: (context) {
//      return Index(text:text);
//    });
  }

  static void complete() {
    // 完成后关闭loading窗口
//    Navigator.of(ctx, rootNavigator: true).pop();
  }
}
```
> 2 在main.dart中_MyHomePageState build函数返回前注入Loading.ctx = context;  为了便于区别，我们使用ctx来存储
```
import 'package:flutter_loading/http/loading.dart' show Loading;
... // 省略部分代码

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    print('home  $context');
    print('home  ${Navigator.of(context)}');
    Loading.ctx = context; // 注入context
    return ...;
  }
```

### 实现dio请求时loading
> 上述内容解决了context关键点。接下来实现接口交互。点击按钮，调用dio.get接口拉取数据，在onRequest前调用Loading.before(); onResponse调用Loading.complete()进行关闭。
```
import 'package:flutter/material.dart';

class Loading {
  static dynamic ctx;

  static void before(text) {
    // 请求前显示弹窗
    showDialog(
      context: ctx,
      builder: (context) {
        return Index(text: text);
      },
    );
  }

  static void complete() {
    // 完成后关闭loading窗口
    Navigator.of(ctx, rootNavigator: true).pop();
  }
}
```
修改下dio的内容，接口请求返回较快时，为了看到loading效果，故在onResponse增加了Future.delayed，延迟3s返回数据。
```
import 'package:dio/dio.dart' show Dio, DioError, InterceptorsWrapper, Response;
import 'loading.dart' show Loading;
Dio dio;

class Http {
  static Dio instance() {
    if (dio != null) {
      return dio;// 实例化dio
    }
    dio = new Dio();
    // 增加拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        // 接口请求前数据处理
        onRequest: (options) {
          Loading.before('正在加速中...');
          return options;
        },
        // 接口成功返回时处理
        onResponse: (Response resp) {
          // 这里为了让数据接口返回慢一点，增加了3秒的延时
          Future.delayed(Duration(seconds: 3), () {
            Loading.complete();
            return resp;
          });
        },
        // 接口报错时处理
        onError: (DioError error) {
          return error;
        },
      ),
    );
    return dio;
  }

  /**
   * get接口请求
   * path: 接口地址
   */
  static get(path) {
    return instance().get(path);
  }
}

```
修改下_incrementCounter函数的内容为通过http.get触发接口调用
```
import 'package:flutter/material.dart';
import 'package:flutter_loading/http/loading.dart' show Loading;
import 'http/index.dart' show Http;
	... // 省略代码
  void _incrementCounter() {
	// Loading.before('loading...');
    Http.get('https://raw.githubusercontent.com/efoxTeam/flutter-ui/master/version.json');
  }
	... // 省略代码
```
ok. 你将会看到如下效果。  

![Alt 预览](https://raw.githubusercontent.com/efoxTeam/flutter-demo/master/flutter_loading/assets/loading.gif)


### 并发请求时loading处理
> 并发请求，loading只需要保证有一个在当前运行。接口返回结束，只需要保证最后一个完成时，关闭loading。
- 使用Set有排重作用，比较使用用来管理并发请求地址。通过Set.length控制弹窗与关闭窗口。
- 增加LoadingStatus判断是否已经有弹窗存在
- 修改onRequest/onResponse/onError入参
```
import 'package:flutter/material.dart';

Set dict = Set();
bool loadingStatus = false;
class Loading {
  static dynamic ctx;

  static void before(uri, text) {
    dict.add(uri); // 放入set变量中
    // 已有弹窗，则不再显示弹窗, dict.length >= 2 保证了有一个执行弹窗即可，
    if (loadingStatus == true || dict.length >= 2) {
      return ;
    }
    loadingStatus = true; // 修改状态
    // 请求前显示弹窗
    showDialog(
      context: ctx,
      builder: (context) {
        return Index(text: text);
      },
    );
  }

  static void complete(uri) {
    dict.remove(uri);
    // 所有接口接口返回并有弹窗
    if (dict.length == 0 && loadingStatus == true) {
      loadingStatus = false; // 修改状态
      // 完成后关闭loading窗口
      Navigator.of(ctx, rootNavigator: true).pop();
    }
  }
}

```

```
http/index.dart

onReuest: Loading.before(options.uri, '正在加速中...');
onReponse: Loading.complete(resp.request.uri);
onError: Loading.complete(error.request.uri );
```

欢迎大家交流~