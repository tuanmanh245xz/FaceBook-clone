import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/home_pages/home_page.dart';
import 'package:fake_app/screens/custom_screen/login_screen.dart';
import 'package:fake_app/screens/new_account/new_account_begin.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';

import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



class LoginAgain extends StatefulWidget {
  static String route = "login_again";
  @override
  _LoginAgainState createState() => _LoginAgainState();
}


enum moreAction {
  removeUser,
  turnOffNotify
}

class _LoginAgainState extends State<LoginAgain> {
  static String defaultImage = "images/my_avatar.jpg";
  static String defaultName = "Nguyen Tuan Nam";

  List<User> accounts;
  List<Widget> _childrenUser = [];
  bool isLogging = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAccounts().then((value) => _initAccount(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLogging ? _getLoadingWidget() : ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 80, bottom: 20),
            child: Center(
              child: Image.asset(
                "images/facebook_logo2.png",
                width: 40,
                height: 40,
              ),
            ),
          ),
          Column(
            children: _childrenUser,
          ),
          ListTile(
            onTap: _onTapLoginOthers,
            contentPadding: EdgeInsets.symmetric(horizontal: 40),
            leading: Container(
              color: HexColor(ConstColor.blue_fade),
              child: Icon(
                Icons.add,
              ),
            ),
            title: Text(
              ConstString.login_with_another,
              style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(text_color_blue), fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            onTap: _onTapSeachAccount,
            contentPadding: EdgeInsets.symmetric(horizontal: 40),
            leading: Container(
              color: HexColor(ConstColor.blue_fade),
              child: Icon(
                Icons.add,
              ),
            ),
            title: Text(
              ConstString.search_account,
              style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(text_color_blue), fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            margin: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: FlatButton(
              onPressed: _onPressCreateAccount,
              color: HexColor(ConstColor.blue_fade),
              child: Center(
                child: Text(
                  ConstString.create_new_account,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, color: HexColor(ConstColor.text_color_blue)),
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  Widget _getLoadingWidget(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(),
          ),
          Container(
            margin: EdgeInsets.only(top : 30),
            child: Text(
              "Đang đăng nhập",
              style: Theme.of(context).textTheme.headline6,
            ),
          )
        ],
      ),
    );
  }


  Future<List<User>> getAccounts() async {
    return await SharedPreferencesHelper.instance.getListAccount();
  }

  void _initAccount(List<User> users){
    setState(() {
      this.accounts = users;
      users.forEach((element) {
        _childrenUser.add(
            ListTile(
                key: Key(element.phone),
                onTap: () {
                  onTapLoginAgain(element.phone);
                },
                contentPadding: EdgeInsets.symmetric(horizontal: 30),
                leading: element.link_avatar != null ? CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(element.link_avatar),
                  backgroundColor: HexColor(ConstColor.color_grey),
                  radius: 20,
                ) : CircleAvatar(
                  backgroundColor: HexColor(ConstColor.color_grey),
                  radius: 20,
                ),
                title: Text(
                  element.name,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 16.5),
                ),
                trailing: PopupMenuButton<moreAction>(
                  onSelected: (moreAction action){
                    if (action == moreAction.removeUser){
                      _onRemoveAccount(element.phone);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<moreAction>>[
                    PopupMenuItem<moreAction>(
                      value: moreAction.removeUser,
                      child: Text(
                          ConstString.remove_user
                      ),
                    ),
                    PopupMenuItem<moreAction>(
                      value: moreAction.turnOffNotify,
                      child: Text(
                          ConstString.turn_off_notifi
                      ),
                    )
                  ],
                )
            )
        );
      });
    });
  }

  void _onRemoveAccount(String keyUser) async {
    int result = await DialogHelper.showDialogConfirm(
        context,
        ConstString.remove_user,
        ConstString.content_remove_user,
        ConstString.native_remove_user,
        ConstString.cancel,
    );

    if (result == 1){ // OK
      _removeAccount(keyUser);
    }
  }
  void _removeAccount(keyUser) async {
    setState(() {
      this._childrenUser.removeWhere((element) => element.key == Key(keyUser));
    });
    accounts.removeWhere((element) => element.phone == keyUser);
    SharedPreferencesHelper.instance.setListAccount(accounts);
  }

  void _onTapLoginOthers() {
    Navigator.of(context)
        .pushReplacementNamed(LoginScreen.route);
  }

  void _onTapSeachAccount() {
    DialogHelper.showDialogNoSupport(context);
  }

  void _onPressCreateAccount(){
    Navigator.of(context).pushNamed(
      ScreenSignUp.route,
    );
  }

  void onTapLoginAgain(String phone) async {
    User user = accounts.firstWhere((element) => element.phone == phone);

    setState(() {
      isLogging = true;
    });
    String uuid = await Constant.getDeviceId();
    var responseLogin = await FakeBookService().login(user.phone, user.password, uuid);
    switch(int.parse(responseLogin['code'])){
      case ConstantCodeMessage.OK:
        user.token = responseLogin['data']['token'];
        user.link_avatar = responseLogin['data']['avatar'];
        SharedPreferencesHelper.instance.setCurrentUser(user);
        Provider.of<UserViewModel>(context, listen: false).setUser(user);
        Navigator.of(context).pushReplacementNamed(HomePage.route);
        break;
      default:
        Navigator.of(context).pushReplacementNamed(LoginScreen.route);
    }
  }
}

