import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/circle_button.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/screens/post_page.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'dart:wasm';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/notify_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fake_app/models/notification.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NotificationPage extends StatefulWidget {

  NotificationPage({Key key}) : super(key : key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Notifications> listNotifications = List();
  UserViewModel model;
  bool notificatons = false;
  NotifyViewModel _notifyViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = Provider.of<UserViewModel>(context, listen: false);
    _notifyViewModel = Provider.of<NotifyViewModel>(context, listen: false);
    _initScroll();
    _getListNotifications();
  }
  void _getListNotifications() async {
    if(_notifyViewModel.listNotify == null || _notifyViewModel.listNotify.length == 0){
      List<Notifications> notifications = await SharedPreferencesHelper.instance.getListNotify();
      // String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
      if (notifications.length > 0){
        _notifyViewModel.replaceAllWith(notifications);
        setState(() {
          listNotifications = _notifyViewModel.listNotify;
        });
        print("here");
        print(_notifyViewModel.listNotify);
      }else if (_notifyViewModel.listNotify.length == 0){
        await _notifyViewModel.fetchListNotify(context, model.user.token, 0);
        setState(() {
          listNotifications = _notifyViewModel.listNotify;
          if(listNotifications.length==0){
            notificatons = true;
          }
        });
        print("here2");
        print(listNotifications);
      }
    }
    else {
      setState(() {
        listNotifications = _notifyViewModel.listNotify;
      });
    }
  }

  void _initScroll(){
  }


  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _notifyViewModel.scrollController,
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _getHeader(),
          _getNotifications()
        ],
      ),
    );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Text(
            ConstString.notification,
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 22),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CircleButton(
                iconData: Icons.search,
                sizeIcon: 50,
                onTap: _onPressSearch,
                backgroundColor: HexColor(ConstColor.grey_fake_transparent),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getNotifications(){
    // print(listNotifications);
    if (listNotifications != null && listNotifications.length > 0){
      return Container(
        //height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
          //itemExtent: 100.0,
            padding: EdgeInsets.zero,
            itemCount: listNotifications.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index){
              return Ink(
                color: (listNotifications[index].read == "1") ? HexColor(ConstColor.color_white) : HexColor(ConstColor.blue_fade),
                // color: HexColor(ConstColor.blue_fade),
                child: ListTile(
                  //dense: false,
                  onTap: () => _onTapSeeNotification(listNotifications[index]),
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: (listNotifications[index].avatar != null && listNotifications[index].avatar.length > 0 )
                            ?NetworkImage(listNotifications[index].avatar)
                            :AssetImage("images/user_grey.png"),
                        radius: 30,
                        backgroundColor: HexColor(ConstColor.grey_fake_transparent),
                      ),
                      Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: HexColor(ConstColor.grey_fake_transparent),
                              borderRadius: BorderRadius.circular(40),
                              image: DecorationImage(
                                  image: (listNotifications[index].type == "comment_post")
                                      ?AssetImage("images/comment_notification")
                                      :(listNotifications[index].type == "like_post")
                                      ?AssetImage("images/like_notification.png")
                                      :(listNotifications[index].type == "new_post")
                                      ?AssetImage("images/post_notification.png")
                                      :(listNotifications[index].type == "friend_accept")
                                      ?AssetImage("images/accept_notification.png")
                                      :AssetImage("images/request_notification.png")
                                  ,
                                  fit: BoxFit.cover
                              )
                          ),
                          margin: EdgeInsets.only(left: 40, top: 27)
                      )

                    ],
                  ),
                  title: RichText(
                    text: TextSpan(
                      text: listNotifications[index].account_username + " ",
                      style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: listNotifications[index].subtitle, style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Text(
                      ConvertHelper.covertDateTimeToStringShow(listNotifications[index].now),
                      // "a ",
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13, color: HexColor(ConstColor.text_color_grey)),
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: _onPressMoreAction,
                    icon: Icon(Icons.more_horiz),
                    iconSize: 15,
                  ),
                ),
              );
            }),
      );
    } else if (notificatons == true) {
      return Container(
        padding: EdgeInsets.all(10),
        height: 400,
        child: Center(
          child: Text(
            "Không có thông báo nào !!!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ),
      );
    } else {
      return Container(
        //height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: 6,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                  child: ListTile(
                    onTap: () {},
                    contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(PostWidget.defaultImage),
                      radius: 30,
                    ),
                    title: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      height: 15,
                      color: Colors.blue,
                    ),
                    subtitle: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      height: 15,
                      width: 200,
                      color: Colors.blue,
                    ),

                    isThreeLine: true,
                  ),
                  baseColor: Colors.grey[200] ,
                  highlightColor: Colors.grey[100]);
            }
        ),
      );
    }
  }

  void _onPressSearch(){

  }

  void _onPressMoreAction(){

  }

  void _onTapSeeNotification(Notifications noti){
    if (noti.read == "0") {
      final UserViewModel _userModel = Provider.of<UserViewModel>(context, listen: false);
      FakeBookService().set_read_notification( _userModel.user.token, noti.notification_id);
      setState(() {
        listNotifications.forEach((notification) {
          if (notification.notification_id == noti.notification_id) {
            notification.read = "1";
          }
        });
      });
    }

    if (noti.type == "comment_post" || noti.type == "like_post" || noti.type == "new_post") {
      Navigator.pushNamed(
          context,
          PostPage.route,
          arguments: noti.object_id
      );
    } else if (noti.type == "friend_accept") {
      User user = new User();
      UserViewModel _user = new UserViewModel();
      user.id = noti.object_id;
      user.name = noti.account_username;
      user.link_avatar = noti.avatar;
      user.password = '';
      user.token = '';
      _user.setUser(user);
      Navigator.pushNamed(
          context,
          PersonalPage.route,
          arguments: _user
      );
    } else if (noti.type == "friend_request") {
      User user = new User();
      UserViewModel _user = new UserViewModel();
      user.id = noti.object_id;
      user.name = noti.account_username;
      user.link_avatar = noti.avatar;
      user.password = '';
      user.token = '';
      _user.setUser(user);
      Navigator.pushNamed(
          context,
          PersonalPage.route,
          arguments: _user
      );
    }

  }

  Future<Void> _onRefresh() async {
    // Load new post
    await _notifyViewModel.fetchListNotify(context, model.user.token, 0);
    setState(() {
    });
    return null;
  }

}