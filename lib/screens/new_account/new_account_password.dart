import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_complete.dart';
import 'package:fake_app/utils/helper/check_helper.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;

class ScreenPassword extends StatefulWidget {
  static String route = '/signup/password';
  @override
  _ScreenPasswordState createState() => _ScreenPasswordState();
}

class _ScreenPasswordState extends State<ScreenPassword> {
  BuildContext context;
  TextEditingController _tdPasswordControl = TextEditingController();
  User _user;
  bool _isValidate = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    _user = ModalRoute.of(context).settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(Constants_Color.back_color), size: 24,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(Constants_String.screenPassword_title,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: HexColor(Constants_Color.text_color_header)
          ),),
        backgroundColor: HexColor(Constants_Color.color_white),
      ),
      body: getBody(),
    );
  }

  Widget getBody(){
    return ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(32),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 30),
                child: Center(
                  child: Text(
                    Constants_String.screenPassword_choose_password,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: getTextFieldPassword(),
              ),
              Container(
                margin: EdgeInsets.only(top: 30),
                child: getButtonNext(),
              )
            ],
          ),
        )
      ],
    );
  }

  TextField getTextFieldPassword(){
    return TextField(
      controller: _tdPasswordControl,
      cursorWidth: 1,
      cursorColor: HexColor(Constants_Color.text_color_blue),
      onChanged: (text) => _onChangePassword(text),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(),
          border: OutlineInputBorder(),
          labelText: Constants_String.screenPassword_title,
        labelStyle: TextStyle(
          fontSize: 16,
          color: HexColor(Constants_Color.text_color_blue)
        ),
        errorText: !_isValidate ? "Mật khẩu phải từ 6 đến 10 kí tự" : null
      ),
      style: TextStyle(
          fontSize: 18,
          color: HexColor(Constants_Color.text_normal)
      ),
      obscureText: true,
    );
  }

  Widget getButtonNext() {
    return RaisedButton(
      onPressed: _onPressNext,
      color: HexColor(Constants_Color.button_active_color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 40,
        child: Center(
          child: Text(
            Constants_String.button_next,
            style: TextStyle(
                color: HexColor(Constants_Color.color_white), fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _onPressNext() {
    if (CheckHelper.isValidPassword(_tdPasswordControl.text)){
      // Ma hoa password
      var bytes = utf8.encode(_tdPasswordControl.text.trim());
      var digest = sha256.convert(bytes);
      _user.password = _tdPasswordControl.text;
      Navigator.pushNamed(
          context,
          ScreenComplete.route,
          arguments: _user
      );
    } else {
      setState(() {
        _isValidate = false;
      });
    }
  }

  void _onChangePassword(String text){
    setState(() {
      if (!_isValidate){
        if (CheckHelper.isValidPassword(text)){
          _isValidate = true;
        } else if (text.length == 0){
          _isValidate = true;
        }
      }
    });
  }
}
