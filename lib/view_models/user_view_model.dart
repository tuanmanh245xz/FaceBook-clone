


import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:flutter/material.dart';

class UserViewModel extends ChangeNotifier  {
  UserViewModel({this.user});
  User user;
  TabController tabController;

  void setUser(User user){
    this.user = user;
    notifyListeners();
  }


  Future<bool> likePost(Post post) async {
    var response = await FakeBookService().like_post(user.token, post.idPost);
    if (response == null) return null;
    switch(int.parse(response['code'])){
      case ConstantCodeMessage.OK:
        return true;
      default:
        return false;
    }
  }

  Future<bool> commentPost(Post post, String comment, int index, int count) async {
    var response = await FakeBookService().set_comment(user.token, post.idPost, comment, index, count);
    if (response == null) return null;
    switch(int.parse(response['code'])){
      case ConstantCodeMessage.OK:
        return true;
      default:
        return false;
    }
  }

  Future<Map<String, dynamic>> deletePost(String idPost) async {
    var response = await FakeBookService().delete_post(user.token, idPost);
    if (response != null){
      return response;
    }
    return null;
  }
}