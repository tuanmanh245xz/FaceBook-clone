import 'dart:convert';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_name.dart';
import 'package:fake_app/screens/new_account/new_account_date.dart';
import 'package:fake_app/screens/new_account/new_account_phone.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constant_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constant_Color;

class ScreenSignUp extends StatelessWidget {
  BuildContext context;
  static String route = '/signup';

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(Constant_Color.back_color), size: 24,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(
          Constant_String.create_account,
          style: TextStyle(
            fontSize: 18,
            color: HexColor(Constant_Color.text_color_header)
          ),
        ),
        backgroundColor: HexColor(Constant_Color.color_white),
      ),
      body: getBody(),
    );
  }

  Widget getBody(){
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 40, left: 32, right: 32, bottom: 20),
            child: Image(
              image: AssetImage('images/new_account_screen1.jpg'),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                Constant_String.create_account1,
                style: TextStyle(
                  fontSize: 18,
                  color: HexColor(Constant_Color.text_color_header),
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    Constant_String.create_account2,
                    style: TextStyle(
                      fontSize: 15,
                      color: HexColor(Constant_Color.text_normal),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: getButton(Constant_String.button_next, Constant_Color.button_active_color, Constant_Color.color_white) ,
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FlatButton(
                onPressed: _onPressHaveOne,
                color: Colors.transparent,
                splashColor: Colors.grey,
                child: Text(
                  Constant_String.button_has_one,
                  style: TextStyle(
                      fontSize: 14,
                      color: HexColor(Constant_Color.text_color_blue)
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getButton(String text, String buttonColor, String textColor){
    return RaisedButton(
      onPressed: _onPressNext,
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
        Center(child: Text(text, style: TextStyle(fontSize: 16))),
      ),
    );
  }

  void _onPressNext(){
      Navigator.pushNamed(
          context,
          ScreenName.route,
          arguments: User());
  }

  void _onPressHaveOne(){

  }
}
