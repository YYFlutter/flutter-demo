import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class UserModel with ChangeNotifier {
  String name = 'Wanwu';
  setName(val) {
    name = val;
    notifyListeners();
  }
}