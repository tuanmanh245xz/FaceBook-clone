

import 'dart:convert';
import 'dart:developer';

import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/messenger.dart';
import 'package:fake_app/models/notification.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/search.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/models/suggest.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  SharedPreferencesHelper._privateConstructor();
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._privateConstructor();
  static SharedPreferencesHelper get instance => _instance;

  void setCurrentUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.CUR_USER, user != null ? jsonEncode(user.toJson()) : "");
  }
  
  Future<User> getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strUser = prefs.getString(Prefs.CUR_USER);
    if (strUser != null && strUser.length > 0){
      return User.fromJson(jsonDecode(strUser));
    }
    return null;
  }
  
  void setListAccount(List<User> accounts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.ACCOUNTS, accounts != null ? jsonEncode(accounts) : "");
  }

  Future<List<User>> getListAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accountsStr = prefs.getString(Prefs.ACCOUNTS);
    List<User> accounts;
    if (accountsStr != null && accountsStr.length > 0){
      accounts = ((jsonDecode(accountsStr)) as List).map((e) => User.fromJson(e)).toList();
      return accounts;
    }
    return List();
  }

  void setListPost(List<Post> listPost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('here 1');
    // print(listPost[0]);
    // print('here 2');
    prefs.setString(Prefs.LIST_POST, listPost != null ? jsonEncode(listPost) : "");
  }

  Future<List<Post>> getListPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListPost = prefs.getString(Prefs.LIST_POST);
    List<Post> posts;
    if (strListPost != null && strListPost.length > 0){
      posts = (jsonDecode(strListPost) as List).map((post) => Post.fromJson(post)).toList();
      return posts;
    }
    return List();
  }

  void setListPostP(List<Post> listPostP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_POST_PERSONAL, listPostP != null ? jsonEncode(listPostP) : "");
  }

  Future<List<Post>> getListPostP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListPostP = prefs.getString(Prefs.LIST_POST_PERSONAL);
    List<Post> posts;
    if (strListPostP != null && strListPostP.length > 0){
      posts = (jsonDecode(strListPostP) as List).map((post) => Post.fromJson(post)).toList();
      return posts;
    }
    return List();
  }

  void setListNotify(List<Notifications> listNotify) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_NOTIFY, listNotify != null ? jsonEncode(listNotify) : "");
  }

  Future<List<Notifications>> getListNotify() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListNotify = prefs.getString(Prefs.LIST_NOTIFY);
    List<Notifications> notifications;
    if (strListNotify != null && strListNotify.length > 0){
      notifications = (jsonDecode(strListNotify) as List).map((noti) => Notifications.fromJson(noti)).toList();
      return notifications;
    }
    return List();
  }

  void setListAccept(List<Friend> listAccept) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_ACCEPT, listAccept != null ? jsonEncode(listAccept) : "");
  }

  Future<List<Friend>> getListAccept() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListAccept = prefs.getString(Prefs.LIST_ACCEPT);
    List<Friend> accepts;
    if (strListAccept != null && strListAccept.length > 0){
      accepts = (jsonDecode(strListAccept) as List).map((accept) => Friend.fromJson(accept)).toList();
      return accepts;
    }
    return List();
  }

  void setListSuggest(List<Suggest> listSuggest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_SUGGEST, listSuggest!= null ? jsonEncode(listSuggest) : "");
  }

  Future<List<Suggest>> getListSuggest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListSuggest = prefs.getString(Prefs.LIST_SUGGEST);
    List<Suggest> suggests;
    if (strListSuggest != null && strListSuggest.length > 0){
      suggests = (jsonDecode(strListSuggest) as List).map((suggest) => Suggest.fromJson(suggest)).toList();
      return suggests;
    }
    return List();
  }

  void setListPostVideo(List<Post> listPostVideo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_POST_VIDEO, listPostVideo != null ? jsonEncode(listPostVideo) : "");
  }

  Future<List<Post>> getListPostVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListPostVideo = prefs.getString(Prefs.LIST_POST_VIDEO);
    List<Post> posts;
    if (strListPostVideo != null && strListPostVideo.length > 0){
      posts = (jsonDecode(strListPostVideo) as List).map((post) => Post.fromJson(post)).toList();
      return posts;
    }
    return List();
  }
  
  void setLastIdPost(String lastIdPost) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LAST_ID_POST, lastIdPost != null ? lastIdPost : "");
  }

  Future<String> getLastIdPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Prefs.LAST_ID_POST);
  }

  void setLastIdPostP(String lastIdPostP) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LAST_ID_POST_PERSONAL, lastIdPostP != null ? lastIdPostP : "");
  }

  Future<String> getLastIdPostP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Prefs.LAST_ID_POST_PERSONAL);
  }

  void setLastIdPostVideo(String lastIdPostVideo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LAST_ID_POST_VIDEO, lastIdPostVideo != null ? lastIdPostVideo : "");
  }

  Future<String> getLastIdPostVideo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(Prefs.LAST_ID_POST_VIDEO);
  }

  void setListNotification(List<Notifications> listNotification) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_NOTIFY, listNotification != null ? jsonEncode(listNotification) : "");
  }

  Future<List<Notifications>> getListNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListNotification = prefs.getString(Prefs.LIST_NOTIFY);
    List<Notifications> notis;
    if (strListNotification != null && strListNotification.length > 0){
      notis = (jsonDecode(strListNotification) as List).map((noti) => Notifications.fromJson(noti)).toList();
      return notis;
    }
    return List();
  }

  Future<List<KeyWord>> getListHistorySearch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var strListHistoryS = prefs.getString(Prefs.LIST_HISTORY_SEARCH);
    List<KeyWord> listHistoryS;
    if (strListHistoryS != null && strListHistoryS.length > 0){
      listHistoryS = (jsonDecode(strListHistoryS) as List).map((history) => KeyWord.fromJson(history)).toList();
      return listHistoryS;
    }
    return List();
  }

  void setListHistorySearch(List<KeyWord> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_HISTORY_SEARCH, list != null ? jsonEncode(list) : "");
  }
  
  void setListBoxChat(List<Conversation> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_BOX_CHAT, list != null ? jsonEncode(list) : "");
  }

  Future<List<Conversation>> getListBoxChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = prefs.getString(Prefs.LIST_BOX_CHAT);
    List<Conversation> list = List();
    if(data != null && data.length > 0){
      list = (jsonDecode(data) as List).map((boxChat) => Conversation.fromJson(boxChat)).toList();
      return list;
    }
    return list;
  }

  void setNumNewMess(int numNewMess) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(Prefs.NUM_NEW_MESS, numNewMess);
  }

  Future<int> getNumNewMess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(Prefs.NUM_NEW_MESS);
  }

  void setListFriend(List<Friend> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_FRIEND, list != null ? jsonEncode(list) : "");
  }

  Future<List<Friend>> getListFriend() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Friend> list = List();
    var friendsStr = prefs.getString(Prefs.LIST_FRIEND);
    if (friendsStr != null && friendsStr.length > 0){
      list = (jsonDecode(friendsStr) as List).map((friend) => Friend.fromJson(friend)).toList();
    }
    return list;
  }

  void setConversation(BoxChat boxChat, String partnerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(boxChat != null && boxChat.listMess.length > 0){
      BoxChat newBoxChat = BoxChat(
        index: boxChat.index,
        listMess: boxChat.listMess.length > 20 ? boxChat.listMess.getRange(boxChat.listMess.length - 20, boxChat.listMess.length).toList() : boxChat.listMess.getRange(0, boxChat.listMess.length).toList()
      );
      prefs.setString(Prefs.BOX_CHAT + partnerId, jsonEncode(newBoxChat));
    }else{
      prefs.setString(Prefs.BOX_CHAT + partnerId, "");
    }
  }

  Future<BoxChat> getBoxChat(String partnerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strResult = prefs.getString(Prefs.BOX_CHAT + partnerId);
    if(strResult != null && strResult.length > 0){
      return BoxChat.fromJson(jsonDecode(strResult));
    }
    return null;
  }

  Future<List<Friend>> getHistorySearchMess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String strResult = prefs.getString(Prefs.LIST_HISTORY_SEARCH);
    if(strResult != null && strResult.length > 0){
      return (jsonDecode(strResult) as List).map((e) => Friend.fromJson(e)).toList();
    }
    return List();
  }

  void setHistoryMess(List<Friend> friends) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LIST_HISTORY_SEARCH, friends != null ? jsonEncode(friends) : "");
  }


  void removeAllUSerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(Prefs.LAST_ID_POST, "");
    prefs.setString(Prefs.LAST_ID_POST_VIDEO, "");
    prefs.setString(Prefs.LIST_HISTORY_SEARCH, "");
    prefs.setString(Prefs.BOX_CHAT, "");
    prefs.setString(Prefs.LIST_FRIEND, "");
    prefs.setString(Prefs.NUM_NEW_MESS, "");
    prefs.setString(Prefs.HISTORY_SEARCH_MESS, "");
    prefs.setString(Prefs.CUR_USER, "");
    prefs.setString(Prefs.LIST_POST, "");
    prefs.setString(Prefs.LIST_POST_VIDEO, "");
    prefs.setString(Prefs.LIST_POST_PERSONAL, "");
    prefs.setString(Prefs.LIST_ACCEPT, "");
    prefs.setString(Prefs.LIST_SUGGEST, "");
    prefs.setString(Prefs.LAST_ID_POST_VIDEO, "");
    prefs.setString(Prefs.LAST_ID_POST_PERSONAL, "");
    prefs.setString(Prefs.LIST_NOTIFY, "");
    prefs.setString(Prefs.LIST_BOX_CHAT, null);
    prefs.setString(Prefs.LIST_POST_PERSONAL, "");
    prefs.setString(Prefs.LIST_POST_VIDEO, "");
    prefs.setString(Prefs.LIST_SUGGEST, "");
    prefs.setString(Prefs.LIST_NOTIFY, "");
    prefs.setString(Prefs.LIST_ACCEPT, "");
  }
}