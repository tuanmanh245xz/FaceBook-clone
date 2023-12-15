import 'dart:wasm';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/circle_button.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/home_pages/list_friends_page.dart';
import 'package:fake_app/screens/home_pages/suggest_friend.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' ;
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/preferences/shared_preferences.dart';


import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/view_models/accept_view_model.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class FriendPage extends StatefulWidget {
  static String route = "/friendpage";

  FriendPage({Key key}) : super(key: key);

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  List<Friend> listRequestFriend = List();
  List<Friend> listNewFriend = List();
  UserViewModel model;
  bool accept = false;
  AcceptViewModel _acceptViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = Provider.of<UserViewModel>(context, listen: false);
    _acceptViewModel = Provider.of<AcceptViewModel>(context, listen: false);
    // userId = model.user.id;
    _getRequestFriend();
  }
  void _getRequestFriend() async {
    if(_acceptViewModel.listAccept == null || _acceptViewModel.listAccept.length == 0){
      List<Friend> notifications = await SharedPreferencesHelper.instance.getListAccept();
      // String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
      if (notifications.length > 0){
        _acceptViewModel.replaceAllWith(notifications);
        setState(() {
          listRequestFriend = _acceptViewModel.listAccept;
        });
        print("here");
        print(_acceptViewModel.listAccept);
      }else if (_acceptViewModel.listAccept.length == 0){
        await _acceptViewModel.fetchListAccept(context, model.user.token, 0);
        setState(() {
          listRequestFriend = _acceptViewModel.listAccept;
          if(listRequestFriend.length==0){
                      accept = true;
          }
        });
        print("here2");
        print(listRequestFriend);
      }
    } else {
      setState(() {
        listRequestFriend = _acceptViewModel.listAccept;
      });
    }
  }
  // void _getRequestFriend() async {
  //   FakeBookService().get_requested_friends(model.user.token, 0, 6).then((res) {
  //     if(mounted){
  //       setState(() {
  //         listRequestFriend = (res["data"]["request"] as List).map((friend) => Friend.fromJson(friend)).toList();
  //         if(listRequestFriend.length==0){
  //           accept = true;
  //         }
  //       });
  //     }
  //   });
  // }

  Widget build(BuildContext context) {
    return RefreshIndicator(
        backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      child: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          _getHeader(),
          _getAcceptFriend()
        ],
      )
    );
    // return ListView(
    //   padding: EdgeInsets.all(0),
    //   children: <Widget>[
    //     _getHeader(),
    //     _getAcceptFriend()
    //   ],
    // );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: <Widget>[
              Text(
                ConstString.friend,
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
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(right: 10),
                child: FlatButton(
                  color: HexColor(ConstColor.color_grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  onPressed: () {
                    Navigator.pushNamed(
                        context,
                        ListSuggestFriendPage.route
                    );
                  },
                  child: Text(
                    ConstString.suggest,
                    style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
              Container(
                child: Align(
                  child: FlatButton(
                    color: HexColor(ConstColor.color_grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () {
                      Navigator.pushNamed(
                          context,
                          ListFriendPage.route,
                          arguments: model
                      );
                    },
                    child: Text(
                      ConstString.all_friend,
                      style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                ),
              )
            ],
          ),
          Divider(height: 10, thickness: 1.5,),
          Row(
            children: <Widget>[
              Text(
                "Lời mời kết bạn",
                style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 22),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:  Container(
                    child: FlatButton(
                      child: Text(
                        "Xem tất cả",
                        style: TextStyle(fontSize: 16, color: HexColor(ConstColor.azure), fontWeight: FontWeight.w400),
                      ),
                      padding: EdgeInsets.all(8.0),
                      //color: HexColor(Constants_Color.empty_space_color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      minWidth: MediaQuery.of(context).size.width * 0.14,
                      onPressed: (){
                        print('You tapped on FlatButton');
                      },
                    ),
                  ),
                ),
              )
            ],
          ),

        ],
      ),
    );
  }


  Widget _getAcceptFriend(){
    if (listRequestFriend != null && listRequestFriend.length >0) {
      return Container(
        // height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listRequestFriend.length,
            shrinkWrap: true,
            itemBuilder: (context, index){
              return ListTile(
                onTap: () => _onTapShowPersonalPage(listRequestFriend[index]),
                contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                leading: (listRequestFriend[index].avatar != "")
                  ?CircleAvatar(
                    backgroundImage: NetworkImage(listRequestFriend[index].avatar),
                  backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                    radius: 40,
                   )
                  :CircleAvatar(
                    radius: 40,
                    child: ClipRRect(
                      child: Image.asset("images/user_grey.png"),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                  ),
                title: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child:  Text(
                            listRequestFriend[index].username,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                        Expanded(
                            child:  Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                ConvertHelper.covertDateTimeToStringShow(listRequestFriend[index].created),
                                style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            )
                        )
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        listRequestFriend[index].same_friends.toString() + " bạn chung",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black45),
                      ),
                    )
                  ],
                ),
                subtitle: Container(
                    margin: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          //margin: EdgeInsets.only(right: 6),
                          child: Container(
                            margin: EdgeInsets.only(right: 6),
                            child: FlatButton(
                              child: Text('Xác nhận',
                                style: new TextStyle(
                                  fontSize: 19.0,
                                  color: Colors.white,
                                ),
                              ),
                              padding: EdgeInsets.all(8.0),
                              color: HexColor(ConstColor.button_active_color),
                              textColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              minWidth: MediaQuery.of(context).size.width * 0.3,
                              onPressed: () => _onPressAccept(listRequestFriend[index]),
                            ),
                          )
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Text('Xóa',
                              style: new TextStyle(
                                fontSize: 19.0,
                                color: Colors.black54,
                              ),
                            ),
                            padding: EdgeInsets.all(8.0),
                            color: HexColor(ConstColor.color_grey),
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                            minWidth: MediaQuery.of(context).size.width * 0.3,
                            onPressed: () => _onPressDelete(listRequestFriend[index]),
                          ),
                        ),
                      ],
                    )
                ),
              );
            }
        ),
      );
    } else if(accept == true) {
      return Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Center(
            child: Text(
              "Chưa có lời mời kết bạn nào",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
        ),
      );
    } else {
      return Container(
        // height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                  child: ListTile(
                    onTap: (){},
                    contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                    leading:  CircleAvatar(
                      radius: 25,
                      child: ClipRRect(
                        child: Image.asset("images/user_grey.png"),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    title: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.grey,
                    ),
                    subtitle:  Container(
                        margin: EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: FlatButton(
                                    child: Text('Gỡ',
                                      style: new TextStyle(
                                        fontSize: 19.0,
                                        color: Colors.black,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(8.0),
                                    color: HexColor(ConstColor.color_grey),
                                    textColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    minWidth: MediaQuery.of(context).size.width * 0.3,
                                    onPressed: (){},
                                  ),
                                )
                            ),
                            Expanded(
                              child: FlatButton(
                                child: Text('Gỡ',
                                  style: new TextStyle(
                                    fontSize: 19.0,
                                    color: Colors.black,
                                  ),
                                ),
                                padding: EdgeInsets.all(8.0),
                                color: HexColor(ConstColor.color_grey),
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                minWidth: MediaQuery.of(context).size.width * 0.3,
                                onPressed: (){},
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                  baseColor: Colors.grey[200],
                  highlightColor:  Colors.grey[100]
              );
            }
        ),
      );
    }
  }
  void _onTapShowPersonalPage(Friend friend) {
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = friend.id;
    user.name = friend.username;
    user.link_avatar = friend.avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
        context,
        PersonalPage.route,
        arguments: _user
    );
  }

  void _onPressSearch(){
  }
  void _onPressAccept(Friend newFriend) {
    listRequestFriend.remove(newFriend);
    _acceptViewModel.listAccept.remove(newFriend);
    setState(() {
      listRequestFriend =listRequestFriend;
      if(listRequestFriend.length == 0) {
        accept = true;
      }
    });
    FakeBookService().set_accept_friend(model.user.token, newFriend.id, "1");
  }
  void _onPressDelete(Friend newFriend) {
    listRequestFriend.remove(newFriend);
    _acceptViewModel.listAccept.remove(newFriend);
    setState(() {
      listRequestFriend =listRequestFriend;
      if(listRequestFriend.length == 0) {
        accept = true;
      }
    });
    FakeBookService().set_accept_friend(model.user.token, newFriend.id, "0");
  }

  Future<Void> _onRefresh() async {
    // Load new post
    await _acceptViewModel.fetchListAccept(context, model.user.token, 0);
    setState(() {
    });
    return null;
  }
}

