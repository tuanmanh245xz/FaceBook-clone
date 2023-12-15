import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_watting.dart';
import 'package:fake_app/utils/constants/constants.dart';

import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;


class ScreenComplete extends StatefulWidget {
  static String route = '/signup/name/date/sexual/phone/complete';
  @override
  _ScreenCompleteState createState() => _ScreenCompleteState();
}

class _ScreenCompleteState extends State<ScreenComplete> {
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context).settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Text(Constants_String.screen6_title_app_bar,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            margin: EdgeInsets.all(32),
            child: getButtonCompl()),
      ],
    );
  }

  Widget getButtonCompl() {
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
            Constants_String.screen6_complete_button,
            style: TextStyle(
                color: HexColor(Constants_Color.color_white), fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _onPressNext() async {
    // Thuc hien gui len server dang ky
    var result = await Navigator.pushNamed(
      context,
      ScreenWaitting.route,
      arguments: _user
    );

    if(result == ConstantCodeMessage.USER_EXISTED){
      DialogHelper.showDialogErrorAction(context, Constants_String.ConstString.error_register, Constants_String.ConstString.error_user_existed);
    }
  }

}
