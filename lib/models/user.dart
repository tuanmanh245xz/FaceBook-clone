
import 'dart:convert';

import 'package:flutter/material.dart';

class User {
  String id;
  String name;
  String password;
  String phone;
  String link_avatar;
  String token;
  List<int> block_users;

  User({this.id, this.name, this.password, this.phone, this.link_avatar, this.token, this.block_users = null});

  Map<String, dynamic> toJson() => {
    "id" : id,
    "name" : name,
    "password" : password,
    "phone" : phone,
    "link_avatar" : link_avatar,
    "token" : token,
    "block_user" : block_users
  };

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      phone: json['phone'],
      link_avatar: json['link_avatar'],
      token: json['token'],
      block_users: json['block_users'] as List<int>
    );
  }
}

class ShortUser {
  String id;
  String name;
  String avatar;
  bool isOnline;
  ShortUser({this.id, this.name, this.avatar, this.isOnline});

  Map<String, dynamic> toJson() => {
    "id" : this.id,
    "name" : this.name,
    "avatar" : this.avatar,
    "online" : this.isOnline ? "1" : "0"
  };

  factory ShortUser.fromJson(Map<String, dynamic> data){
    return ShortUser(
      id : data['id'],
      name: data['name'],
      avatar: data['avatar'],
      isOnline: data['online'] == "1" ? true : false
    );
  }
}

class SimpleUser {
  String name;
  String avatar;
  String id;

  SimpleUser({this.name, this.avatar, this.id});

  Map<String, dynamic> toJson() => {
    "id" : this.id,
    "name" : this.name,
    "avatar" : this.avatar,
  };

  factory SimpleUser.fromJson(Map<String, dynamic> data){
    return SimpleUser(
        id : data['id'],
        name: data['name'],
      avatar: data['avatar'],
    );
  }
}