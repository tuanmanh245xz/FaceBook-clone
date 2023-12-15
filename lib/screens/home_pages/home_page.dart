import 'dart:convert';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/home_pages/friend_page.dart';
import 'package:fake_app/screens/home_pages/new_feed_page.dart';
import 'package:fake_app/screens/home_pages/menu_page.dart';
import 'package:fake_app/screens/custom_screen/login_screen.dart';
import 'package:fake_app/screens/messenger/messenger_screen.dart';
import 'package:fake_app/screens/search/search_screen.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/view_models/notify_view_model.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Contants_Color;
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_page.dart';
import 'watch_page.dart';

class HomePage extends StatefulWidget {
  static String route = "/homepage";
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final double default_tab_size = 28;
  PageStorageKey _newFeedKey;
  PageStorageKey _menuKey;
  PageStorageKey _friendsKey;
  PageStorageKey _notifyKey;
  PageStorageKey _watchKey;

  ScrollController _scrollController;
  TabController _tabController;
  NewFeedPage newFeedPage;
  FriendPage friendPage;
  WatchPage watchPage;
  NotificationPage notificationPagePage;
  MenuPage menuPage;
  UserViewModel _userVm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    //_tabController = TabController(vsync: this, length: 5,);
    _userVm = Provider.of<UserViewModel>(context, listen: false);
    _userVm.tabController = TabController(vsync: this, length: 5,);
    _newFeedKey = PageStorageKey(0);
    _menuKey = PageStorageKey(1);
    _friendsKey = PageStorageKey(2);
    _notifyKey = PageStorageKey(3);
    _watchKey = PageStorageKey(4);

    newFeedPage = NewFeedPage(key: _newFeedKey,);
    friendPage = FriendPage(key: _friendsKey);
    watchPage = WatchPage(key: _watchKey);
    notificationPagePage = NotificationPage(key: _notifyKey);
    menuPage = MenuPage(key: _menuKey);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: new NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                stretch: false,
                floating: true,
                pinned: true,
                snap: false,
                forceElevated: false,
                automaticallyImplyLeading: false,
                brightness: Brightness.light,
                title: new Text(
                  "Fakebook",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900
                  ),
                ),
                actions: <Widget>[
                  CircleAvatar(
                    backgroundColor: HexColor(ConstColor.grey_fake_transparent),
                    radius: 18.5,
                    child: IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: _onPressSearch,
                      icon: Icon(Icons.search, size: 28, color: HexColor(ConstColor.black),),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: CircleAvatar(
                      backgroundColor: HexColor(ConstColor.grey_fake_transparent),
                      radius: 18.5,
                      child: IconButton(
                          onPressed: _onPressMess,
                          icon: Image.asset('images/messenger.png', filterQuality: FilterQuality.high, width: 22, height: 22,)
                      ),
                    ),
                  )
                ],
                elevation: 0.0,
                bottom: TabBar(
                  onTap: (index) => onTapTabBar(index),
                  controller: _userVm.tabController,
                  labelColor: Theme.of(context).iconTheme.color,
                  unselectedLabelColor: HexColor(Contants_Color.accent_gray_color),
                  tabs: <Widget>[
                    Tab(
                      icon: Icon(Icons.home, size: default_tab_size,),
                    ),
                    Tab(
                      icon: Icon(Icons.group, size: default_tab_size,),
                    ),
                    Tab(
                      icon: Icon(Icons.ondemand_video, size: default_tab_size,),
                    ),
                    Tab(
                      icon: Icon(Icons.notifications),
                    ),
                    Tab(
                      icon: Icon(Icons.menu),
                    )
                  ],
                ),
              )
            ];
          },
          body: new TabBarView(
            controller: _userVm.tabController,
            children: <Widget>[
              NewFeedPage(key: _newFeedKey,),
              FriendPage(key: _friendsKey),
              WatchPage(key: _watchKey),
              NotificationPage(key: _notifyKey),
              MenuPage(key: _menuKey)
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );  // Widget _getHomePage(){
  }



  void _onPressSearch(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SearchScreen(isSearchPersonalUser: false,))
    );
  }

  void _onPressMess(){
    Navigator.of(context).pushNamed(MessengerScreen.route);
  }

  void onTapTabBar(int index) {
    print('Index: $index');
    print('Controller Index $index');
    switch(index){
      case 0:
        if(_userVm.tabController.index == 0){
          Provider.of<PostViewModel>(context, listen: false).scrollToTopPost();
          print('Enter here');
        }
        return;
      case 1:
        if(_userVm.tabController.index == 1){
          // Scroll to Top
        }
        return;
      case 2:
        if(_userVm.tabController.index == 2){
          // Scroll to top
        }
        return;
      case 3:
        if(_userVm.tabController.index == 3){
          Provider.of<NotifyViewModel>(context, listen: false).scrollToTop();
        }
        return;
      case 4:
        if(_userVm.tabController.index == 4){
          MenuPage(key: _menuKey).scrollToTop();
        }
        return;
      default:
        return;
    }
  }
}
