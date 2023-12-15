import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notifications {
  String account_username;
  String subtitle;
  String user_id;
  String avatar;
  String type;
  String object_id;
  DateTime now;
  String notification_id;
  String group;
  String read;

  Notifications({this.account_username, this.subtitle, this.user_id, this.avatar, this.type, this.object_id, this.now, this.notification_id, this.group, this.read});

  Map<String, dynamic> toJson() => {
    "account_username" : account_username,
    "subtitle" : subtitle,
    "user_id" : user_id,
    "avatar" : avatar,
    "type" : type,
    "object_id" : object_id,
    "now" : this.now != null ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(this.now) : "",
    "notification_id" : notification_id,
    "group" : group,
    "read" : read,
  };

  factory Notifications.fromJson(Map<String, dynamic> json){
    DateTime now;
    try {
      if (json.containsKey('now')){
        now = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((json['now'] as String).trim(), false).toLocal();
      } else now = null;
    } on Exception catch(e){
      now = null;
      print(e.toString());
    }
    // try {
    //   print(json['now']);
    //   now = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((json['now'] as String).trim(), false).toLocal();
    //  // modified = (json['modified'] as String).length > 1 ? DateFormat('dd/MM/yyyy, HH:mm::ss').parse((json['modified'] as String).trim(), false).toLocal() : null;
    // } on Exception catch(e){
    //   now = DateTime.now();
    //   print(e.toString());
    // }
    return Notifications(
      account_username: (json['title'] != null) ? json['title']['account_username'] as String : json['account_username'] as String,
      subtitle: (json['title'] != null) ? json['title']['subtitle'] as String : json['subtitle'] as String,
      // account_username: "account",
      // subtitle: "subtitle",
      user_id: json['user_id'],
      avatar: json['avatar'],
      type: json['type'],
      object_id: json['object_id'],
      now: now,
      notification_id: json['notification_id'],
      group: json['group'],
      read: json['read'],
    );
  }
}