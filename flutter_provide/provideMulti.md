# Flutter provide ProvideMulti
> 在数据管理上flutter package中的provide提供了良好使用体验，与scoped_model中最大的特点在于有namespace的概念。
> 相关的使用方式，可以参考文章[Flutter UI使用Provide实现主题切换](https://juejin.im/post/5ca5e240f265da30c1725021)
> 本文将介绍provide中ProvideMulti属性的使用方式

本文相关链接
* [flutter-ui](https://github.com/efoxTeam/flutter-ui)
* [flutter-ui中关于flutter_provide应用](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_provide)
* [Flutter UI使用Provide实现主题切换](https://juejin.im/post/5ca5e240f265da30c1725021)
* [provide](https://pub.dartlang.org/packages/provide)
* [scoped_model](https://pub.dartlang.org/flutter/packages?q=scoped_model)

#### 初始化
```
/// UserModel
class UserModel with ChangeNotifier {
	String name = 'Wanwu';
	setAge(val) {
		age = val;
	    notifyListeners();
	}
}

/// ConfigModel
class ConfigInfo {
  String theme = 'red';
}
class ConfigModel extends ConfigInfo with ChangeNotifier {
  Future $setTheme(payload) async {
    theme = payload;
    notifyListeners();
  }
}

/// init store
init({child, dispose = true}) {
  final providers = Providers()
  ..provide(Provider.value(UserModel()))
  ..provide(Provider.value(AuthorModel()));

  return ProviderNode(
    child: child,
    providers: providers,
    dispose: dispose,
  );
}

/// ...MainApp省略MainApp的内容
/// main
void main() => runApp(init(child: MainApp()));
```
#### 分析ProvideMulti
```
ProvideMulti(
   builder: builder,
   child: child,
   requestedValues: requestedValues,
   requestedScopedValues: requestedScopedValues);
}
```
builder:  （context, child, model）返回context, child, ProvidedValues值，ProvidedValues对应requestedValues提供的namespace。
requestedValues： []数组类型，即传入数据模型对应的namespace，需要使用哪个就传入哪个。[UserModel, ConfigModel]
child: 传入组件，在build中返回

#### 使用
```
ProvideMulti(
	builder:(context, child, model) {
		// 参数model是ProvidedValues的值，通过get方法和泛型能获取到对应数据模型的数据。
		UserModel user = model.get<UserModel>();
		ConfigModel config = model.get<ConfigModel>();
		return Container(
			child: Text("name: ${user.name} , color: ${config.theme}")
		)
	},
	requestedValues: [UserModel, ConfigModel]
)
```

* 源码可参考[flutter-ui中关于flutter_provide应用](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_provide)  
* 欢迎交流~  
