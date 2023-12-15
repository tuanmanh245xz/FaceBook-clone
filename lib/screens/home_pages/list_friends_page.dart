import 'dart:wasm';
import 'dart:ui';
import 'dart:async';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/home_pages/suggest_friend.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/view_models/friend_view_model.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' ;
import 'package:provider/provider.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:shimmer/shimmer.dart';

class ListFriendPage extends StatefulWidget {
  static String route = "/listfriendpage";
  @override
  _ListFriendPageState createState() => _ListFriendPageState();
}

class _ListFriendPageState extends State<ListFriendPage>{
  List<Friend> listFriend = List();
  UserViewModel _userViewModel;
  bool friend = false;
  UserViewModel model;
  FriendViewModel _friendViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _friendViewModel = Provider.of<FriendViewModel>(context, listen: false);
    Future.delayed(Duration(milliseconds: 1)).then((_) {
      _getListFriends();
    });

  }

  void _getListFriends() async {
    model = ModalRoute.of(context).settings.arguments;
    if (_userViewModel.user.id == model.user.id) {
      if(_friendViewModel.listFriend == null || _friendViewModel.listFriend.length == 0){
        List<Friend> friends = await SharedPreferencesHelper.instance.getListFriend();
        // String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
        if (friends.length > 0){
          _friendViewModel.replaceAllWith(friends);
          setState(() {
            listFriend = _friendViewModel.listFriend;
          });
        }else if (_friendViewModel.listFriend.length == 0){
          await _friendViewModel.fetchListFriend(context, _userViewModel.user.token, model.user.id, 0);
          setState(() {
            listFriend = _friendViewModel.listFriend;
            if(listFriend.length==0){
              friend = true;
            }
          });
        }
      } else {
        setState(() {
          listFriend = _friendViewModel.listFriend;
        });
      }
    } else {
        FakeBookService().get_user_friends(_userViewModel.user.token, model.user.id, 0, 6).then((res) {
          setState(() {
            listFriend = (res["data"]["friends"] as List).map((friend) => Friend.fromJson(friend)).toList();
            if(listFriend.length==0){
              friend = true;
            }
          });
          print(res["data"]["friends"]);
          print(listFriend);
        });
    }
  }

  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            ConstString.all_friend
          ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: (){}
              )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: <Widget>[
            _getHeader(),
            _getListFriend()
          ],
        ),
      )
    );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: <Widget>[
          (listFriend.length >0 && listFriend != null)
            // (friend == true)
            ?Text(
          listFriend.length.toString()+" bạn bè",
          style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
        )
            : Shimmer.fromColors(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey,
                ),
                height: 30,
                width: 100,
          ),
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100]
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                ConstString.sort,
                style: TextStyle(
                  color: HexColor(ConstColor.text_color_blue)
                ),
              )
            ),
          )
        ],
      ),
    );
  }

  Widget _getListFriend(){
    if (listFriend != null && listFriend.length > 0) {
      return Container(
        // height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            itemCount: listFriend.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => _onTapShowPersonalPage(listFriend[index]),
                contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                leading: (listFriend[index].avatar != "")
                    ?CircleAvatar(
                  backgroundImage: NetworkImage(listFriend[index].avatar),
                  backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                  radius: 25,
                )
                    :CircleAvatar(
                  radius: 25,
                  backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                  child: ClipRRect(
                    child: Image.asset("images/user_grey.png"),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child:  Text(
                        listFriend[index].username,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),

                  ],
                ),
                subtitle: Align(
                  alignment: Alignment.centerLeft,
                  child: (_userViewModel.user.id != listFriend[index].id)?Text(
                    listFriend[index].same_friends.toString() + " bạn chung",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black45),
                  ):Container(),
                ),
                trailing: Icon(Icons.more_horiz),
              );
            }
        ),
      );
    } else if (friend == true){
      return Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: Center(
            child: Column(
              children: [
                Text(
                  "Chưa có bạn bè nào !!!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: FlatButton.icon(
                    label: Text('Gợi ý kết bạn',
                      style: new TextStyle(
                        fontSize: 19.0,
                        color: Colors.black45,
                      ),
                    ),
                    icon: Icon(Icons.person_add_alt_1_outlined),
                    padding: EdgeInsets.all(8.0),
                    color: HexColor(Constants_Color.empty_space_color),
                    textColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    //minWidth: MediaQuery.of(context).size.width * 0.76,
                    onPressed: (){
                      Navigator.pushNamed(
                          context,
                          ListSuggestFriendPage.route
                      );
                    },
                  ),
                ),
              ],
            )
        ),
      );
    } else {
      return Container(
        // height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            itemCount: 8,
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
                  ),
                  baseColor: Colors.grey[200],
                  highlightColor:  Colors.grey[100]
              );
            }
        ),
      );
    };
   // return ListFriendWidgetHelper.getItemFriend(context, false, _onPressAccept, _onPressDelete);
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

  Future<Void> _onRefresh() async {
    model = ModalRoute.of(context).settings.arguments;
    // Load new friend
    await _friendViewModel.fetchListFriend(context, _userViewModel.user.token, model.user.id, 0);
    setState(() {
    });
    return null;
  }
}
