
import 'dart:convert';

import 'package:flutter/material.dart';

class UserInfo {
  String address;
  String username;
  String relationship;
  String link;
  String avatar;
  String city;
  String description;
  String country;
  String cover_image;

  UserInfo({this.address, this.username, this.relationship, this.link, this.avatar, this.city, this.description, this.country, this.cover_image });

  Map<String, dynamic> toJson() => {
    "address" : address,
    "username" : username,
    "relationship" : relationship,
    "link" : link,
    "avatar" : avatar,
    "city" : city,
    "description" : description,
    "country": country,
    "cover_image": cover_image
  };

  factory UserInfo.fromJson(Map<String, dynamic> json){
    return UserInfo(
        address: json['address'],
        username: json['username'],
        relationship: json['relationship'],
        link: json['link'],
        avatar: json['avatar'],
        city: json['city'],
        description: json['description'],
        country: json['country'],
        cover_image: json['cover_image']
    );
  }
}

