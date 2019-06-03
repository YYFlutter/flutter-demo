import 'package:flutter/material.dart';
import 'package:flutter_github_login/store/index.dart' show Store, UserModel;
import 'package:flutter_github_login/page/app_login/index.dart' show AppLogin;

void main() => runApp(Store.init(child: MainApp()));


class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    Store.setStoreCtx(context);
  }

  // 抽屉面板
  renderDrawer() {
    return Drawer(
      child: Store.connect<UserModel>(builder: (context, child, model) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: ClipOval(
                      child: model.user.avatar_url != null
                          ? Image.network(
                              model.user.avatar_url,
                              width: 80,
                            )
                          : Icon(Icons.account_box),
                    ),
                  ),
                  Text(
                    model.user.name ?? 'Guest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: renderTiles(model.user.id, context, model),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<Widget> renderTiles(id, context, model) {
    if (id != null) {
      return [
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('退出'),
          onTap: () {
            Store.value<UserModel>(context).clearUserInfo();
            model.changeShowLogin(true);
            Navigator.of(context).pop();
          },
        ),
      ];
    }
    return [
      ListTile(
        leading: Icon(Icons.account_circle),
        title: Text('登陆'),
        onTap: () {
          model.changeShowLogin(true);
          Navigator.of(context).pop();
        },
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    Store.value<UserModel>(context).getLocalUserInfo();
    return Store.connect<UserModel>(
      builder: (context, child, model) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            appBar: AppBar(
              title: Text('Flutter UI 接入github登陆'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  model.showLogin ?
                  AppLogin()
                  :
                  ListTile(
                    leading: ClipOval(
                      child: model.user.avatar_url != null
                        ? Image.network(
                            model.user.avatar_url,
                            width: 80,
                          )
                        : Icon(Icons.account_box),
                    ),
                    title: Text(
                      model.user.name ?? 'Guest',
                      style: TextStyle(fontWeight: FontWeight.bold)
                    ),
                    onTap: () {
                      // Scaffold.of(context).openDrawer()
                      if(model.user.avatar_url == null) {
                        model.changeShowLogin(true);
                      }
                    }
                  )
                ],
              ),
            ),
            drawer: renderDrawer(),
          ),
        );
      }
    );
  }
}
