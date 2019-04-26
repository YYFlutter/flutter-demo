import 'package:flutter/material.dart';
import 'package:flutter_provide/store/index.dart'
    show Store, ConfigModel, ProvideMulti, UserModel;

// 将状态放入到顶层
void main() => runApp(Store.init(child: MainApp()));

class MainApp extends StatefulWidget {
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  Map materialColor = {
    'red': 0xFFF44336,
    'pink': 0xFFE91E63,
    'purple': 0xFF9C27B0,
    'deepPurple': 0xFF673AB7,
    'indigo': 0xFF3F51B5,
    //

    'blue': 0xFF2196F3,
    'lightBlue': 0xFF03A9F4,
    'cyan': 0xFF00BCD4,
    'teal': 0xFF009688,
    'green': 0xFF4CAF50,
    //
    'lightGreen': 0xFF8BC34A,
    'lime': 0xFFCDDC39,
    'yellow': 0xFFFFEB3B,
    'amber': 0xFFFFC107,
    'orange': 0xFFFF9800,
    //
    'deepOrange': 0xFFFF5722,
    'brown': 0xFF795548,
    'grey': 0xFF9E9E9E,
    'blueGrey': 0xFF607D8B,
    'black': 0xFF222222,
  };

  @override
  Widget build(BuildContext context) {
    //  获取Provide状态
    return Store.connect<ConfigModel>(builder: (context, child, model) {
      return MaterialApp(
        title: 'Provide修改主题',
        theme: ThemeData(primaryColor: Color(materialColor[model.theme])),
        home: MyHomePage(
            title: 'FLutter_Provide Demo', materialColor: materialColor),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Map materialColor;

  MyHomePage({Key key, this.title, this.materialColor}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController nameCtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<String> _color = [];
    widget.materialColor.forEach((k, v) {
      _color.add(k);
    });
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      body: Center(
          child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _color.map(
                (item) {
                  return InkWell(
                    onTap: () {
                      Store.value<ConfigModel>(context).$setTheme(item);
                    },
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      color: Color(widget.materialColor[item]),
                    ),
                  );
                },
              ).toList(),
            ),
            ProvideMulti(
              builder: (context, child, model) {
                UserModel user = model.get<UserModel>();
                ConfigModel config = model.get<ConfigModel>();
                return Container(
                  child: Column(
                    children: <Widget>[
                      Text('ProvideMulti的使用'),
                      Text("1 申明ProvideMulti中requestedValues的属性值"),
                      Text('eg: requestedValues: [UserModel, ConfigModel],'),
                      Text('2 通过ProvidedValues中get方法获取到对应的类型'),
                      Text('UserModel user = model.get<UserModel>();'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('当前颜色 ${config.theme}'),
                      Text("显示名称: ${user.name}"),
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "输入试试修改名称",
                        ),
                        controller: nameCtl,
                      ),
                      RaisedButton(
                        child: Text("修改名称"),
                        onPressed: () {
                          user.setName(nameCtl.text.trim());
                          nameCtl.text = '';
                        },
                      ),
                    ],
                  ),
                );
              },
              requestedValues: [UserModel, ConfigModel],
            ),
          ],
        ),
      )),
    );
  }
}
