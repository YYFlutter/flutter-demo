# flutter ui接入github登陆
## 前言
本文是[flutter ui](https://github.com/efoxTeam/flutter-ui)项目的的github接入功能的讲解，以实现内容为主

## 项目地址
[flutter-ui](https://github.com/efoxTeam/flutter-ui), 这是包含flutter组件介绍的开源项目，欢迎star

[flutter_github_login](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_github_login) 本教程的项目源码，欢迎star

## 效果
![登陆](https://user-gold-cdn.xitu.io/2019/6/3/16b1d75ae7573425?w=746&h=1526&f=png&s=147220)
![用户信息](https://user-gold-cdn.xitu.io/2019/6/3/16b1d7630a34d564?w=734&h=1522&f=png&s=77849)

## github 操作
### 授权
```
https://api.github.com/authorizations
POST
HEAD:
Authorization : Basic base64(username:password)

DATA:
{
"scopes": ["user", "repo", "gist", "notifications","public_repo"],
"note": "admin_script",
"client_id": "d8eef6133f1a2be3a842",
"client_secret": "2b005eed01c72aefd68fac5c5c7f2654f81c227a"
}

RES:
{$token} 
```

### 获取个人信息
```
https://api.github.com/user   
POST

HEAD:
Authorization : token $token

DATA:
{}

```

### 参考Api  
```
https://developer.github.com/v3
https://developer.github.com/v4
```

## 实现
接入github登陆主要分为两步
* 第一步获取授权，得到返回数据token,返回的数据格式如下:
```
/**
 * github登录后返回的数据
 * GitHubRespInfo
 */
  num id;
  String url;
  App app; // 格式看class App
  String token;
  String hashed_token;
  String token_last_eight;
  String note;
  Map note_url;
  String created_at;
  String updated_at;
  List scopes;
  Map fingerprint;
  
  class App {
      String str;
      num number;
      bool boolean;
      List array;
      Map map;

  }
```
* 第二步通过token请求获取用户数据,返回用户数据格式如下：
```
/**
 * 查询用户信息返回的数据
 * UserInfo
 */
  String login;
  num id;
  String node_id;
  String avatar_url;
  String gravatar_id;
  String url;
  String html_url;
  String followers_url;
  String following_url;
  String gists_url;
  String starred_url;
  String subscriptions_url;
  String organizations_url;
  String repos_url;
  String events_url;
  String received_events_url;
  String type;
  bool site_admin;
  String name;
  String company;
  String blog;
  dynamic location;
  String email;
  dynamic hireable;
  dynamic bio;
  num public_repos;
  num public_gists;
  num followers;
  num following;
  String created_at;
  String updated_at;
  num private_gists;
  num total_private_repos;
  num owned_private_repos;
  num disk_usage;
  num collaborators;
  bool two_factor_authentication;
  Plan plan; // 格式看class Plan
  
  class Plan {
      String name;
      num space;
      num collaborators;
      num private_repos;
  }
```
### 在store层中新建user_model.dart

关于provide的使用可参考 [Flutter UI使用Provide实现主题切换](https://juejin.im/post/5ca5e240f265da30c1725021)

```
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:dio/dio.dart' show Options;
import '../objects/user_info.dart' show UserInfo;  // UserInfo为用户信息Object
import '../objects/github_resp_info.dart' show GitHubRespInfo; // 用户登陆获得权限Object
import 'package:flutter_github_login/http/index.dart' as Http;
import 'package:flutter_github_login/utils/localStorage.dart' show LocalStorage;

class UserModel with ChangeNotifier {
  UserInfo user = UserInfo();
  bool showLogin = false;
  
  changeShowLogin(isShow) {
    showLogin = isShow;
    notifyListeners();
  }

  /**
   * 登录控制
   */
  Future loginController(context, payload) async {
    dynamic result = await login(payload);
    // dynamic result = await testLogin();
    print('返回result $result');
    if (result == true) {
      print('登录成功后退');
      // Navigator.of(context).pop();
    } else {
      print('登录失败');
      Scaffold.of(context).showSnackBar(new SnackBar(
        content: new Text('登录失败'),
      ));
    }
  }

  // 第一步 获取github登陆权限
  Future login(payload) async {
    var name = payload['name'];
    var pwd = payload['pwd'];
    var bytes = utf8.encode("$name:$pwd");
    var credentials = base64.encode(bytes);
    const data = {
      "scopes": ["user", "repo", "gist", "notifications", "public_repo"],
      "note": "admin_script",
      "client_id": "d8eef6133f1a2be3a842",
      "client_secret": "2b005eed01c72aefd68fac5c5c7f2654f81c227a"
    };
    Options options = Options(headers: {'Authorization': 'Basic $credentials'});
    var response = Http.post(
      url: 'https://api.github.com/authorizations',
      data: data,
      options: options,
    );
    return await response.then((resp) async {
      return await setLoginRespInfo(resp.data);
    }).catchError((error) {
      clearUserInfo();
      return false;
    });
  }

  // 将用户授权信息缓存到本地
  setLoginRespInfo(payload) async {
    GitHubRespInfo user = GitHubRespInfo.fromJson(payload);
    LocalStorage.set('githubRespInfo', user.toString());
    print('user.token.toString() ${user.token.toString()}');
    LocalStorage.set('githubRespLoginToken', user.token.toString());
    return await getUserInfo(); // 授权成功获取用户信息
  }

  /**
   * 第二步 授权成功或打开app时获取用户信息
   */
  Future getUserInfo() async {
    var response = Http.post(
      url: 'https://api.github.com/user',
    );
    return await response.then((resp) {
      UserInfo user = UserInfo.fromJson(resp.data);
      setUserInfo(user);
      return true;
    }).catchError((error) {
      print('ERROR $error');
      return false;
    });
  }

  /**
   * 获取本地数据，减少调用接口
   */
  getLocalUserInfo() async {
    String data = await LocalStorage.get('githubUserInfo');
    print("本地数据 $data");
    if (data == null) {
      getUserInfo();
      return;
    }
    UserInfo user = UserInfo.fromJson(json.decode(data));
    setUserInfo(user);
  }

  /**
   * 设置用户信息
   */
  setUserInfo(payload) {
    user = payload;
    if (user != null && user.id != null) {
      LocalStorage.set('githubUserInfo', json.encode(user));
    }
    notifyListeners();
  }

  /**
   * 清空用户信息
   */
  clearUserInfo() {
    user = UserInfo();
    LocalStorage.remove('githubUserInfo');
    LocalStorage.remove('githubRespInfo');
    LocalStorage.remove('githubRespLoginToken');
    notifyListeners();
  }
}
```


### http请求头带上token
```
dio.interceptors.add(InterceptorsWrapper(
    onRequest: (RequestOptions options) async {
      // 获取本地缓存的token并加到请求头中，在第二步进行用户信息获取的时候用到
      String token = await LocalStorage.get('githubRespLoginToken');
      if (options.headers['Authorization'] == null && token != null) {
        options.headers['Authorization'] = 'token $token';
      }
      return options;
    },
    onResponse: (Response response) async {
      return response;
    }
  ));
```

### 调用接口
* 在调用build时调用 Store.value<UserModel>(context).getLocalUserInfo();
目的是已经授权过或者获取过用户信息的，直接从本地中获取数据减少请求次数
* 用户点击账号秘密登陆如下：
```
Expanded(
  child: RaisedButton(
    padding: EdgeInsets.all(15),
    color: Theme.of(context).primaryColor,
    textColor: Theme.of(context).primaryTextTheme.title.color,
    child: Text('登陆',),
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
```

关于UI的具体代码就不再这贴出了，需要参考ui代码的可参考 [flutter_github_login](https://github.com/efoxTeam/flutter-demo/tree/master/flutter_github_login) 


## 总结
* 获取github登陆授权，得到返回数据token，将数据缓存至本地供请求用户信息接口的权限token使用
* http请求的请求头中加入授权token
* 获取用户信息，将用户信息缓存至本地，二次进入app不用重新获取授权和用户信息

## 最后
欢迎更多学习flutter的小伙伴加入QQ群 Flutter UI： 798874340

敬请关注我们正在开发的: [efoxTeam/futter-ui](https://github.com/efoxTeam/flutter-ui)

[作者](https://github.com/DIVINER-onlys)