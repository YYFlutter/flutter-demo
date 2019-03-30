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

// 弹窗内容
class Index extends StatelessWidget {
  final String text;

  Index({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // 设置透明背影
      body: Center(
        // 居中显示
        child: Column(
          // 定义垂直布局
          mainAxisAlignment: MainAxisAlignment.center,
          // 主轴居中布局，相关介绍可以搜下flutter-ui的内容
          children: <Widget>[
            // CircularProgressIndicator自带loading效果，需要宽高设置可在外加一层sizedbox，设置宽高即可
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              text,
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ), //
            SizedBox(
              height: 20,
            ),
            // 触发关闭窗口
            RaisedButton(
              child: Text(
                'close dialog',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ), // 自带loading效果，需要宽高设置可在外加一层sizedbox，设置宽高即可
      ),
    );
  }
}
