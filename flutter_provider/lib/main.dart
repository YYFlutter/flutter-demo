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