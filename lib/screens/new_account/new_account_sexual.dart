import 'dart:convert';
import 'package:fake_app/screens/new_account/new_account_phone.dart';
import 'package:fake_app/utils/constants/constants.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;

class ScreenSexual extends StatefulWidget {
  static String route = '/signup/name/date/sexual';
  @override
  _ScreenSexualState createState() => _ScreenSexualState();
}

class _ScreenSexualState extends State<ScreenSexual> {
  final String title = "Giới tính";
  BuildContext context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
              fontSize: 20, color: HexColor(Constants_Color.text_color_header)),
        ),
        backgroundColor: HexColor(Constants_Color.color_white),
      ),
      body: getBody(),
    );
  }

  int _sexualValue = 0;
  bool _isShowMoreOptional = true;
  TextEditingController textEditingController = new TextEditingController();
  Widget moreOptionalSexual = Container();
  Widget getBody() {
    return ListView(children: <Widget>[
      Container(
        margin: EdgeInsets.all(18),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  Constants_String.screen4_sexual,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: Center(
                child: Text(
                  Constants_String.screen4_sexual_change,
                  style: Theme.of(context).textTheme.subtitle2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              child: ListTile(
                onTap: () {
                  setState(() {
                    _sexualValue = 1;
                    moreOptionalSexual = Container();
                  });
                },
                title: Text(
                  Constants_String.screen4_female,
                  style: getStyleTitle(),
                ),
                trailing: Radio(
                  value: 1,
                  groupValue: _sexualValue,
                  onChanged: _onChangeSexual,
                ),
              ),
            ),
            Divider(),
            Container(
              child: ListTile(
                onTap: () {
                  setState(() {
                    _sexualValue = 2;
                    moreOptionalSexual = Container();
                  });
                },
                title: Text(
                  Constants_String.screen4_male,
                  style: getStyleTitle(),
                ),
                trailing: Radio(
                  value: 2,
                  groupValue: _sexualValue,
                  onChanged: _onChangeSexual,
                ),
              ),
            ),
            Divider(),
            Container(
              child: ListTile(
                onTap: () {
                  setState(() {
                    _sexualValue = 3;
                    moreOptionalSexual = _getMoreOptional();
                  });
                },
                title: Text(
                  Constants_String.screen4_optional,
                  style: getStyleTitle(),
                ),
                subtitle: Text(
                  Constants_String.screen4_optional_more,
                  style: getStyleSub(),
                ),
                trailing: Radio(
                  value: 3,
                  groupValue: _sexualValue,
                  onChanged: _onChangeSexual,
                ),
              ),
            ),
            moreOptionalSexual,
            Container(margin: EdgeInsets.only(bottom: 30), child: Divider()),
            getButtonNext()
          ],
        ),
      ),
    ]);
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
    Navigator.pushNamed(
      context,
      ScreenPhone.route,
      arguments: ModalRoute.of(context).settings.arguments
    );
  }

  void _onChangeSexual(int value) {
    setState(() {
      if (value == 3){
        moreOptionalSexual = _getMoreOptional();
      } else {
        moreOptionalSexual = Container();
      }
      _sexualValue = value;
    });
  }

  void _onTapChangeSexual(int value){

  }

  Widget _getMoreOptional() {
    return Container(
      margin: EdgeInsets.all(10),
      child: TextField(
        controller: textEditingController,
        cursorColor: Colors.blue,
        cursorWidth: 1,
        decoration: InputDecoration(
          hintText: Constants_String.screen4_hint_sexual,
        ),
      ),
    );
  }

  TextStyle getStyleTitle() {
    return TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: HexColor(Constants_Color.text_color_header));
  }

  TextStyle getStyleSub() {
    return TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: HexColor(Constants_Color.text_normal));
  }
}
