import 'dart:convert';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_date.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;

class ScreenName extends StatefulWidget {
  static String route = '/signup/name';

  @override
  _ScreenNameState createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  final String title = "Tên";

  TextEditingController textControlFirstName = TextEditingController();

  TextEditingController textControlLastName = TextEditingController();

  Widget errorMessageWidget = Container();

  BuildContext context;

  User _user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context).settings.arguments as User;
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(Constants_Color.back_color), size: 24,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        backgroundColor: HexColor(Constants_Color.color_white),
        title: Text(title, style: TextStyle(color: HexColor(Constants_Color.text_color_header), fontSize: 18),),
      ),
      body: getBody(),
    );
  }

  Widget getBody(){
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 25),
                child: Text(
                  Constants_String.screen2_your_name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: HexColor(Constants_Color.text_color_header)
                  ),
                ),
              ),
              errorMessageWidget,
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        height: 55,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: TextField(
                            controller: textControlFirstName,
                            cursorColor: Colors.blue,
                            cursorWidth: 1,
                            onChanged: (text) => _onTextChange(text),
                            decoration: getInputDecoration(Constants_String.screen2_first_name),
                            style: TextStyle(
                              fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 55,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: TextField(
                            controller: textControlLastName,
                            cursorColor: Colors.blue,
                            cursorWidth: 1,
                            onChanged: (text) => _onTextChange(text),
                            decoration: getInputDecoration(Constants_String.screen2_last_name),
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              getButtonNext()
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration getInputDecoration(String labelText){
    return InputDecoration(
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 17, color: HexColor(Constants_Color.ConstColor.text_color_blue)),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder()
    );
  }

  Widget getButtonNext(){
    return RaisedButton(
      onPressed: _onPressNext,
      color: HexColor(Constants_Color.button_active_color),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.5)
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Center(
          child: Text(
            Constants_String.button_next,
            style: TextStyle(
              fontSize: 14,
              color: HexColor(Constants_Color.color_white)
            ),
          ),
        ),
      ),
    );

  }


  void _onPressNext(){
    setState(() {
      String firstName = textControlFirstName.text;
      String lastName = textControlLastName.text;

      if (firstName == null || lastName == null || firstName.trim().length == 0 || lastName.trim().length == 0){
        errorMessageWidget = _getWidgetErrorMessage(Constants_String.screen2_error_message_empty);
        return;
      } else {
        firstName = firstName.trim();
        lastName = lastName.trim();
        errorMessageWidget = Container();
      }

      _user.name = firstName + " " + lastName;

      Navigator.pushNamed(
        context,
        ScreenDate.route,
        arguments: _user
      );

    });
  }
  
  void _onTextChange(String text){
    setState(() {
        if (text != null || text.length > 0){
          errorMessageWidget = Container();
        }
      });
  }

  Widget _getWidgetErrorMessage(String message){
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: HexColor(Constants_Color.text_error_message)
          ),
        ),
      ),
    );
  }
}
