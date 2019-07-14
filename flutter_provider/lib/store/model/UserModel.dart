import 'package:flutter/foundation.dart' show ChangeNotifier;
import '../object/UserInfo.dart';
export '../object/UserInfo.dart';

class UserModel extends UserInfo with ChangeNotifier {
  UserInfo _userInfo = UserInfo(name: '咕噜猫不吃猫粮不吃鱼');

  String get name => _userInfo.name;

  void setName (name) {
    _userInfo.name = name;
    notifyListeners();
  }
}