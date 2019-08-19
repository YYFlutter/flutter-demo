## 背景
provider是Google I/O 2019大会宣布的现在官方推荐的状态管理方式，
[provider](https://pub.dev/packages/provider)，语法糖是InheritedWidget，它允许在小部件树中传递数据，允许我们更加灵活地处理数据类型和数据。

## 项目地址
[flutter_provider](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_provider) 本教程的项目源码，欢迎star

## 为什么需要状态管理
在进行项目的开发时，我们往往需要管理不同页面之间的数据共享，在页面功能复杂，状态达到几十个上百个的时候，我们会难以清楚的维护我们的数据状态，本文将以简单计数器功能使用状态管理来讲解如何在Flutter中使用provider这个状态管理框架

## 为什么选择Provider
上次为大家介绍了provide，然后provide就被弃用了，不过要从provide转provider学习成本也不高，要了解provide可以转[Flutter UI使用Provide实现主题切换](https://juejin.im/post/5ca5e240f265da30c1725021)

使用Provider访问数据有两种方式
* 使用Provider.of<T>(context)，简单易用，但是要数据发生变化时，会进行页面级别rebuild，相当于stfulWidget
* 使用Consumer，Consumer比Provider.of<T>(context)复杂一点，但是对于app性能的提高却有些很好的作用，当状态发生变化时，widget树会更新指定的节点，极小程度进行控件刷新，不会进行整颗widget树的更新，详细看下文分析。
* Provider有泛型的优势，相当于namespace的特性，使用过vuex的应该知道namespace的重要性，它将我们的状态分离开来

## 项目地址
[flutter-provider](https://github.com/efoxTeam/flutter-ui), 可参考项目中使用provider方法

## 效果
![FistPage](https://user-gold-cdn.xitu.io/2019/7/14/16bf0a59fca69007?w=712&h=1420&f=png&s=183884)

![SecondPage](https://user-gold-cdn.xitu.io/2019/7/14/16bf0a641f492d0b?w=698&h=1406&f=png&s=153411)
## 如何使用
### 添加依赖
查看 [pub-install](https://pub.dev/packages/provider)
* 在pubspec.yaml中引入依赖
``` dart
dependencies:
      provider: 3.0.0+1 #数据管理层
```
* 执行
``` dart
flutter packages get
```
* 在需要使用的页面中引入
``` dart
import 'package:provider/provider.dart'
```

### 创建model （这才第一步）
新建 lib/store/object/CounterInfo.dart 文件

新建 lib/store/object/UserInfo.dart 文件

数据模型，就不贴出代码了

新建 lib/store/model/CounterModel.dart 文件
``` dart
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../object/CounterInfo.dart';
export '../object/CounterInfo.dart';

class Counter extends CounterInfo with ChangeNotifier {
  CounterInfo _counterInfo = CounterInfo(count: 0, totalInfo: TotalInfo(total: 2));

  int get count => _counterInfo.count;
  TotalInfo get totalInfo => _counterInfo.totalInfo;

  void increment () {
    _counterInfo.count++;
    notifyListeners();
  }

  void decrement () {
    _counterInfo.count--;
    notifyListeners();
  }
}
```
新建 lib/store/model/UserModelModel.dart 文件
```
import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../object/UserInfo.dart';
export '../object/UserInfo.dart';

class UserModel extends UserInfo with ChangeNotifier {
  UserInfo _userInfo = UserInfo(name: '咕噜猫不吃猫粮不吃鱼');

  String get name => _userInfo.name;

  void setName (name) {
    _userInfo.name = name;
    notifyListeners();
  }
}
```
通过mixin混入ChangeNotifier，通过notifyListeners通知听众刷新
### 封装Store （没错，到这里已经要快完成所有步骤了）
新建 lib/store/index.dart 文件
``` dart
import 'package:flutter/material.dart' show BuildContext;
import 'package:provider/provider.dart'
  show ChangeNotifierProvider, MultiProvider, Consumer, Provider;
import 'model/index.dart' show Counter, UserModel;
export 'model/index.dart';
export 'package:provider/provider.dart';

class Store {
  static BuildContext context;
  static BuildContext widgetCtx;

  //  我们将会在main.dart中runAPP实例化init
  static init({context, child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_) => Counter()),
        ChangeNotifierProvider(builder: (_) => UserModel(),)
      ],
      child: child,
    );
  }

  //  通过Provider.value<T>(context)获取状态数据
  static T value<T>(context) {
    return Provider.of(context);
  }

  //  通过Consumer获取状态数据
  static Consumer connect<T>({builder, child}) {
    return Consumer<T>(builder: builder, child: child);
  }
}

```
需要管理多个状态只需要在providers添加对应的状态

providers: [
        ChangeNotifierProvider(builder: (_) => Counter()),
        ChangeNotifierProvider(builder: (_) => UserModel(),)
      ],


### 定义全局的Provide （倒数第二）
lib/main.dart 文件
``` dart
import 'package:flutter/material.dart';
import 'package:flutter_provider/store/index.dart' show Store;
import 'package:flutter_provider/page/firstPage.dart' show FirstPage;

void main () {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('根部重建: $context');
    return Store.init(
      context: context,
      child: MaterialApp(
        title: 'Provider',
        home: Builder(
          builder: (context) {
            Store.widgetCtx = context;
            print('widgetCtx: $context');
            return FirstPage();
          },
        ),
      )
    );
  }
}
```

### 建立页面 （完成）
新建 lib/page/firstPage.dart 文件
``` dart
import 'package:flutter/material.dart';
import 'package:flutter_provider/store/index.dart' show Store, Counter, UserModel;
import 'package:flutter_provider/page/secondPage.dart' show SecondPage;

class FirstPage extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    print('first page rebuild');
    return Scaffold(
      appBar: AppBar(title: Text('FirstPage'),),
      body: Center(
        child: Column(
          children: <Widget>[
            Store.connect<Counter>(
              builder: (context, snapshot, child) {
                return RaisedButton(
                  child: Text('+'),
                  onPressed: () {
                    snapshot.increment();
                  },
                );
              }
            ),
            Store.connect<Counter>(
              builder: (context, snapshot, child) {
                print('first page counter widget rebuild');
                return Text(
                  '${snapshot.count}'
                );
              }
            ),
            Store.connect<Counter>(
              builder: (context, snapshot, child) {
                return RaisedButton(
                  child: Text('-'),
                  onPressed: () {
                    snapshot.decrement();
                  },
                );
              }
            ),
            Store.connect<UserModel>(
              builder: (context, snapshot, child) {
                print('first page name Widget rebuild');
                return Text(
                  '${Store.value<UserModel>(context).name}'
                );
              }
            ),
            TextField(
              controller: controller,
            ),
            Store.connect<UserModel>(
              builder: (context, snapshot, child) {
                return RaisedButton(
                  child: Text('change name'),
                  onPressed: () {
                    snapshot.setName(controller.text);
                  },
                );
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Center(
          child: Icon(Icons.group_work)
        ),
        onPressed: () {
          Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
              return SecondPage();
          }));
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          //   return SecondPage();
          // }));
        },
      ),
    );
  }
}
```
新建 lib/page/secondPage.dart 文件
```
import 'package:flutter/material.dart';
import 'package:flutter_provider/store/index.dart' show Store, Counter, UserModel;

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('second page rebuild');
    return Scaffold(
      appBar: AppBar(title: Text('SecondPage'),),
      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('+'),
              onPressed: () {
                Store.value<Counter>(context).increment();
              },
            ),
            Builder(
              builder: (context) {
                print('second page counter widget rebuild');
                return Text(
                  'second page: ${Store.value<Counter>(context).count}'
                );
              },
            ),
            RaisedButton(
              child: Text('-'),
              onPressed: () {
                Store.value<Counter>(context).decrement();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

细心的同学可以发现我在firstPage中使用获取数据状态全部都是通过Consumer来获取的，在firstPage中使用了两个store（Counter和UserModel）绑定了两个不同的weiget，好处就在于：
* 我通过+或-进行数据修改时，只会对使用Counter数据模型的widget进行更新，通过点击change name按钮时修改了UserModel中的name，也只会对使用了UserModel的weiget进行更新
    * firstPage中在build中进行了print('first page rebuild');
    * 在显示数量的weiget中进行了print('first page counter widget rebuild');
    * 在显示昵称的weiget中进行了print('first page name Widget rebuild');

结果是first page rebuild只会在页面初始化的时候进行打印，而操作数据增减和name修改只会重新渲染对应的weiget，下图分别为单独进行一次数据修改和name修改后的控制台输出
![firstPage的print](https://user-gold-cdn.xitu.io/2019/7/14/16bf0a37e16aaa23?w=792&h=124&f=png&s=21009)

* 在secondPage中对于数据的操作我通过Provider.value<T>(context)获取，使用较为方便简单，但是数据改变时，会发生页面级别刷新
    * secondPage中build进行了print('second page rebuild');
    * 在显示数量的weiget中进行了print('second page counter widget rebuild');

结果是second page rebuild会在页面初始化的时候进行打印，但每次数据修改时同样也会进行print
![secondPage的print](https://user-gold-cdn.xitu.io/2019/7/14/16bf0a3fbe6e658b?w=824&h=130&f=png&s=27985)

综上，使用Provider.value<T>(context)会导致页面刷新，虽然flutter会自动优化刷新，但还是建议大家尽量使用Consumer去获取数据，可以获取最好app的性能提升

## 最后
欢迎更多学习flutter的小伙伴加入QQ群 Flutter UI： 798874340

敬请关注我们正在开发的：[efoxTeam/flutter-ui](https://github.com/efoxTeam/flutter-ui)

[作者](https://github.com/DIVINER-onlys)