import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:wasm';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/suggest.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/circle_button.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants.dart' as Constants;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' ;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/view_models/suggest_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';

import 'package:fake_app/service/fakebook_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

class ListSuggestFriendPage extends StatefulWidget {
  static String route = "/listsuggestfriendpage";
  @override
  _ListSuggestFriendPageState createState() => _ListSuggestFriendPageState();
}

class _ListSuggestFriendPageState extends State<ListSuggestFriendPage>{
  List<Suggest> listSuggestFriend = List();
  List<Suggest> listNewFriend = List();
  UserViewModel model;
  bool suggest = false;
  SuggestViewModel _suggestViewModel;
  UserViewModel _userViewModel;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = Provider.of<UserViewModel>(context, listen: false);
    _suggestViewModel = Provider.of<SuggestViewModel>(context, listen: false);
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _getListSuggestFriends();
  }

  void _getListSuggestFriends() async {
    if(_suggestViewModel.listSuggest == null || _suggestViewModel.listSuggest.length == 0){
      List<Suggest> suggests = await SharedPreferencesHelper.instance.getListSuggest();
      // String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
      if (suggests.length > 0){
        _suggestViewModel.replaceAllWith(suggests);
        setState(() {
          listSuggestFriend = _suggestViewModel.listSuggest;
        });
        print("here");
        print(_suggestViewModel.listSuggest);
      }else if (_suggestViewModel.listSuggest.length == 0){
        await _suggestViewModel.fetchListSuggest(context, model.user.token, 0);
        setState(() {
          listSuggestFriend = _suggestViewModel.listSuggest;
          if(listSuggestFriend.length==0){
            suggest = true;
          }
        });
        print("here2");
        print(listSuggestFriend);
      }
    } else {
      setState(() {
        listSuggestFriend = _suggestViewModel.listSuggest;
      });
    }
  }

  // void _getListSuggestFriends() async {
  //   FakeBookService().get_list_suggested_friends(model.user.token, 0, 10).then((res) {
  //     setState(() {
  //       listSuggestFriend = (res["data"]["list_users"] as List).map((suggest) => Suggest.fromJson(suggest)).toList();
  //       if(listSuggestFriend.length==0){
  //         suggest = true;
  //       }
  //     });
  //     //print(res["data"]["list_users"]);
  //     print(listSuggestFriend);
  //   });
  // }

  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
            ConstString.suggest
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
            _getListSuggestFriend()
          ],
        ),
      )
    );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Text(
            "Những người bạn có thể biết",
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _getListSuggestFriend(){
    if (listSuggestFriend != null && listSuggestFriend.length > 0) {
      return Container(
        // height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            itemCount: listSuggestFriend.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () => _onTapShowPersonalPage(listSuggestFriend[index]),
                contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                leading: (listSuggestFriend[index].avatar != "")
                    ?CircleAvatar(
                      backgroundImage: NetworkImage(listSuggestFriend[index].avatar),
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
                title: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child:  Text(
                        listSuggestFriend[index].username,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        listSuggestFriend[index].same_friends.toString() + " bạn chung",
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.black45),
                      ),
                    )
                  ],
                ),
                subtitle:  Container(
                    child: Row(
                      children: [
                        Expanded(
                          //margin: EdgeInsets.only(right: 6),
                          child: Container(
                            margin: EdgeInsets.only(right: 6),
                            child: FlatButton(
                              child: Text('Thêm bạn bè',
                                style: new TextStyle(
                                  fontSize: 17.0,
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
                              onPressed: () => _onPressAddFriend(listSuggestFriend[index]),
                            ),
                          )
                        ),
                        Expanded(
                          child: FlatButton(
                            child: Text('Gỡ',
                              style: new TextStyle(
                                fontSize: 17.0,
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
              );
            }
        ),
      );
    } else if(suggest == true){
      return Container(
        padding: EdgeInsets.all(20),
        height: 400,
        child: Center(
          child: Text(
            "Không có gợi ý nào !",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
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
    };
    // return ListSuggestFriendWidgetHelper.getItemFriend(context, false, _onPressAccept, _onPressDelete);
  }

  void _onTapShowPersonalPage(Suggest suggest) {
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = suggest.id;
    user.name = suggest.username;
    user.link_avatar = suggest.avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
        context,
        PersonalPage.route,
        arguments: _user
    );
  }
  void _onPressAddFriend(Suggest newFriend){
    listNewFriend.add(newFriend);
    listSuggestFriend.remove(newFriend);
    setState(() {
      listNewFriend = listNewFriend;
      listSuggestFriend =listSuggestFriend;
      if(listSuggestFriend.length == 0) {
        suggest = true;
      }
    });
    FakeBookService().set_request_friend(model.user.token, newFriend.id);
  }
  void _onPressDelete(){

  }
  Future<Void> _onRefresh() async {
    model = ModalRoute.of(context).settings.arguments;
    // Load new friend
    await _suggestViewModel.fetchListSuggest(context, _userViewModel.user.token,  0);
    setState(() {
    });
    return null;
  }
}

