
import 'dart:convert';

import 'package:flutter/material.dart';

class Suggest {
  String id;
  String username;
  String avatar;
  int same_friends;
  Suggest({this.id, this.username, this.avatar, this.same_friends});

  Map<String, dynamic> toJson() => {
    "id" : id,
    "username" : username,
    "avatar" : avatar,
    "same_friends" : same_friends
  };

  factory Suggest.fromJson(Map<String, dynamic> json){
    return Suggest(
        id: json['id'],
        username: json['username'],
        avatar: json['avatar'],
        same_friends: json['same_friends']
    );
  }
}