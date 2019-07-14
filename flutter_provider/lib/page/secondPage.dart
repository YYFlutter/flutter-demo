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