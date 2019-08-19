class UserInfo extends Object {
  String name;

  UserInfo({this.name});

  UserInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic> ();
    data['name'] = this.name;
    return data;
  }
}