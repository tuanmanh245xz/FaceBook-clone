


import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/models/user_info.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:flutter/material.dart';

class InfoViewModel extends ChangeNotifier  {
  InfoViewModel({this.userInfo});
  UserInfo userInfo;

  void setUserInfo(UserInfo userInfo){
    this.userInfo = userInfo;
    notifyListeners();
  }

}