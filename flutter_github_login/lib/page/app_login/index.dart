import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_github_login/store/index.dart' show Store, UserModel;

class AppLogin extends StatefulWidget {
  AppLogin({Key key}) : super(key: key);

  @override
  _AppLoginState createState() => _AppLoginState();
}

class _AppLoginState extends State<AppLogin> {
  TextEditingController nameCtl = TextEditingController(text: '');
  TextEditingController pwdCtl = TextEditingController(text: '');

  GlobalKey _formKey = GlobalKey<FormState>();

  /**
   * 顶部图标
   */
  renderGithubImage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/imgs/github_2.png',
          width: 50,
          height: 50,
        ),
        SizedBox(
          width: 10,
        ),
        Transform.rotate(
          child: Icon(
            Icons.import_export,
            color: Colors.black,
          ),
          angle: math.pi / 2,
        ),
        SizedBox(
          width: 10,
        ),
        Image.asset(
          'assets/imgs/github_1.png',
          width: 50,
          height: 50,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext ctx) {
    return WillPopScope(
      child: Builder(builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidate: true,
              child: Column(
                children: <Widget>[
                  renderGithubImage(),
                  TextFormField(
                    controller: nameCtl,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '账户名',
                      hintText: '请输入账户名',
                      icon: Icon(Icons.person),
                    ),
                    validator: (v) {
                      return v.trim().length > 0
                          ? null
                          : '用户名不能为空';
                    },
                  ),
                  TextFormField(
                    controller: pwdCtl,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入登陆密码',
                      icon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) {
                      return v.trim().length > 0
                          ? null
                          : '密码不能为空';
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            padding: EdgeInsets.all(15),
                            color: Theme.of(context).primaryColor,
                            textColor: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .color,
                            child: Text(
                              '登陆',
                            ),
                            onPressed: () async {
                              if ((_formKey.currentState as FormState)
                                  .validate()) {
                                await Store.value<UserModel>(context)
                                    .loginController(context, {
                                  'name': nameCtl.text.trim(),
                                  'pwd': pwdCtl.text.trim()
                                });
                                Store.value<UserModel>(context).changeShowLogin(false);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: RaisedButton(
                            padding: EdgeInsets.all(15),
                            color: Theme.of(context).primaryColor,
                            textColor: Theme.of(context)
                                .primaryTextTheme
                                .title
                                .color,
                            child: Text(
                              '取消',
                            ),
                            onPressed: () async {
                              Store.value<UserModel>(context).changeShowLogin(false);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ),
        );
      })
    );
  }
}
