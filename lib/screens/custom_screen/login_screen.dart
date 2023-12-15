
import 'dart:convert';

import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/home_pages/home_page.dart';
import 'package:fake_app/screens/new_account/new_account_begin.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';

import 'package:fake_app/utils/helper/check_helper.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants.dart' as Constants;
import 'package:fake_app/utils/constants/constants_colors.dart' as Contants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  static String route = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  BuildContext context;

  TextEditingController _tdPhoneControl = TextEditingController();

  TextEditingController _tdPasswordControl = TextEditingController();

  bool _isValidate_pass = true;

  bool _isValidate_phone = true;

  bool isLoging = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      body: isLoging ? _getLoadingWidget() : ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Image(
                image: AssetImage('images/login_facebook.jpeg'),
              ),
              Container(
                margin: EdgeInsets.only(left: 34, right: 34, top: 30),
                child: getTfPhoneWidget()
              ),
              Container(
                margin: EdgeInsets.only(left: 32, right: 32, top : 16),
                child: getTfPasswordWidget()
              ),
              Container(
                margin: const EdgeInsets.only(left: 28, right: 28, top: 14),
                child: getButton(Constants_String.text_login, Contants_Color.button_active_color, Contants_Color.color_white, _onPressLogin)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top : 10),
                    child: FlatButton(
                      color: Colors.transparent,
                      onPressed: _onPressForgetPassword,
                      child: Text(
                        Constants_String.text_forget_password,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: HexColor(Contants_Color.button_active_color)
                        ),
                      ),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30, top : 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Divider(
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right : 8.0),
                      child: Text('HOẶC'),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 50, right: 50, top: 16),
                padding: const EdgeInsets.all(0.0),
                child: getButton(Constants_String.create_a_new_account, Contants_Color.button_color_green, Contants_Color.color_white, _onPressSignUp),
              )
            ],
          ),
        ],
      ),
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

  Widget getTfPhoneWidget(){
    return TextField(
      controller: _tdPhoneControl,
      onChanged: (text) => _onChangePhone(text),
      style: TextStyle(
          color: HexColor(Contants_Color.default_color_textField),
          fontSize: Constants.default_font_size
      ),
      cursorWidth: 1,
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: HexColor(Contants_Color.color_under_textField)
            )
        ),
        hintText: Constants_String.hint_text_field,
        hintStyle: TextStyle(
            fontSize: Constants.hint_text_size
        ),
        errorText: _isValidate_phone ? null : "Điện thoại bao gồm 10 - 11 kí tự số"
      ),
    );
  }

  Widget getTfPasswordWidget(){
    return TextField(
      controller: _tdPasswordControl,
      obscureText: true,
      cursorWidth: 1,
      onChanged: (text) => _onChangePassword(text),
      style: TextStyle(
          color: HexColor(Contants_Color.default_color_textField),
          fontSize: Constants.default_font_size
      ),
      decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: HexColor(Contants_Color.color_under_textField),
                width: 0.5
            ),
          ),
          hintText: Constants_String.hint_password,
          hintStyle: TextStyle(
              fontSize: Constants.hint_text_size
          ),
        errorText: _isValidate_pass ? null : "Mật khẩu không đúng định dạng"
      ),
    );
  }

  Widget getButton(String text, String buttonColor, String textColor, Function() onPress){
    return RaisedButton(
      onPressed: onPress,
      textColor: HexColor(textColor),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        decoration: BoxDecoration(
            color: HexColor(buttonColor),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(4)
        ),
        padding: const EdgeInsets.all(10.0),
        child:
        Center(child: Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ),
    );
  }



  void _onPressSignUp(){
    Navigator.pushNamed(this.context, ScreenSignUp.route);
  }

  void _onPressLogin() async {
    String phone = _tdPhoneControl.text;
    String password = _tdPasswordControl.text;
    if (CheckHelper.isValidPhoneNumber(phone) && CheckHelper.isValidPassword(password)){
      setState(() {
        isLoging = true;
      });
      String uuid = await Constant.getDeviceId();
      var response = await FakeBookService().login(phone, password, uuid);
      if (response != null){
        switch(int.parse(response['code'])){
          case 1000:
            // For current user
            User currentUser = _getUserFromData(response['data']);
            currentUser.password = password;
            currentUser.phone = phone;
            Provider.of<UserViewModel>(context, listen: false).setUser(currentUser);
            SharedPreferencesHelper.instance.setCurrentUser(currentUser);
            // For list accounts
            List<User> accounts = await SharedPreferencesHelper.instance.getListAccount();

            if (accounts == null) accounts = List();
            bool accountExisted = false;
            accounts.forEach((element) {
              if (element.phone == currentUser.phone) accountExisted = true;
            });
            if (!accountExisted)
              accounts.add(currentUser);

            SharedPreferencesHelper.instance.setListAccount(accounts);

            Navigator.popAndPushNamed(context, HomePage.route);
            break;
          case 9995:
            DialogHelper.showDialogLoginFailed(context, ConstString.error_login, ConstString.error_wrong_info);
            break;
          default:
            DialogHelper.showDialogLoginFailed(context, ConstString.error_login, ConstString.error_no_internet);
        }
      } else {
        DialogHelper.showDialogLoginFailed(context, ConstString.error_login, ConstString.error_no_internet);
      }
    }
  }

  User _getUserFromData(Map<String, dynamic> data){
    return User(
      name: data['username'],
      id: data['id'],
      token: data['token'],
      link_avatar: data['avatar'],
    );
  }


  void _onPressForgetPassword(){
  }

  void _onChangePassword(String text){
    setState(() {
      if (!_isValidate_pass){
        if (CheckHelper.isValidPassword(_tdPasswordControl.text)){
          _isValidate_pass = true; return;
        }
        if (_tdPasswordControl.text.length == 0) {
          _isValidate_pass = true; return;
        }
      }
    });
  }

  void _onChangePhone(String phone){
    setState(() {
      if (!_isValidate_phone){
        if (CheckHelper.isValidPhoneNumber(_tdPhoneControl.text)){
          _isValidate_phone = true;
          return;
        }
        if (_tdPhoneControl.text.length == 0){
          _isValidate_phone = true;
          return;
        }
      }
    });
  }
}
