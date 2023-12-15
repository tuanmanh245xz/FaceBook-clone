

import 'package:intl/intl.dart';

class Friend {
  String id;
  String username;
  String avatar;
  DateTime created;
  int same_friends;
  Friend({this.id, this.username, this.avatar, this.created, this.same_friends});

  Map<String, dynamic> toJson() => {
    "id" : id,
    "username" : username,
    "avatar" : avatar,
    "created" : created != null ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(created) : "",
    "same_friends" : same_friends
  };

  factory Friend.fromJson(Map<String, dynamic> json){
    DateTime created;
    try {
      print(json['created']);
      created = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((json['created'] as String).trim(), false).toLocal();
      //modified = (json['modified'] as String).length > 1 ? DateFormat('dd/MM/yyyy, HH:mm::ss').parse((json['modified'] as String).trim(), false).toLocal() : null;
    } on Exception catch(e){
      created = DateTime.now();
      print(e.toString());
    }
    return Friend(
        id: json['id'],
        username: json['username'],
        avatar: json['avatar'],
        created: created,
        same_friends: json['same_friends']
    );
  }
}