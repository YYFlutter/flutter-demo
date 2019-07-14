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