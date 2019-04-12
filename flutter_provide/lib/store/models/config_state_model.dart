import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;

class ConfigInfo {
  String theme = 'red';
}

class ConfigModel extends ConfigInfo with ChangeNotifier {
  Future $setTheme(payload) async {
    theme = payload;
    notifyListeners();
  }
}