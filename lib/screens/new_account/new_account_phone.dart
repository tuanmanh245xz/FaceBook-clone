import 'dart:convert';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_password.dart';
import 'package:fake_app/utils/helper/check_helper.dart';
import 'package:fake_app/utils/constants/constants.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;


class ScreenPhone extends StatefulWidget {
  static String route = '/signup/name/date/sexual/phone';
  @override
  _ScreenPhoneState createState() => _ScreenPhoneState();
}

class _ScreenPhoneState extends State<ScreenPhone> {
  User _user;
  bool _isValidate = true;
  TextEditingController _tdPhoneControl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context).settings.arguments as User;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Constants_String.screen5_title_app_bar,
          style: TextStyle(
            color: HexColor(Constants_Color.text_color_header),
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: HexColor(Constants_Color.color_white),
      ),
      body: getBody(),
    );
  }

  Widget getBody(){
    return Container(
      margin: EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 15),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top : 30 , bottom: 20),
            child: Center(
              child: Text(
                Constants_String.screen5_title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 40),
            child: getTextFieldPhoneWidget()
          ),
          getButtonNext(),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                Constants_String.screen5_register_email,
                style: TextStyle(
                  fontSize: 16
                    ,
                  fontWeight: FontWeight.bold,
                  color: HexColor(Constants_Color.text_color_blue)
                ),
              ),
            ),
          )
        ],
      ),
    );

  }

  Widget getTextFieldPhoneWidget(){
    return Container(
      height: 55,
      child: TextField(
        controller: _tdPhoneControl,
        cursorWidth: 1,
        onChanged: (text) => _onChangeTdPhone(text),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(),
          border: OutlineInputBorder(),
          labelText: Constants_String.screen5_hint_text_field,
          labelStyle: TextStyle(
            fontSize: 16,
            color: HexColor(Constants_Color.text_color_blue)
          ),
          errorText: _isValidate ? null : "Đi động gồm 10 kí tự số bắt đầu bằng số 0"
        ),
        style: TextStyle(
            fontSize: 18,
            color: HexColor(Constants_Color.text_normal)
        ),
        keyboardType: TextInputType.number,
      ),
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
    // Check phone number;
    if (CheckHelper.isValidPhoneNumber(_tdPhoneControl.text)){
      _user.phone = _tdPhoneControl.text.trim();
      Navigator.pushNamed(
          context,
          ScreenPassword.route,
          arguments: _user
      );
    } else {
      setState(() {
        _isValidate = false;
      });
    }
  }

  void _onChangeTdPhone(text){
    setState(() {
      if (CheckHelper.isValidPhoneNumber(text)){
        _isValidate = true;
      }
    });
  }
}
