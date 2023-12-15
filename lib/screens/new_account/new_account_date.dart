import 'dart:convert';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/new_account/new_account_sexual.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';


class ScreenDate extends StatefulWidget {
  static String route = '/signup/name/date';

  @override
  _ScreenDateState createState() => _ScreenDateState();
}

class _ScreenDateState extends State<ScreenDate> {
  final String title = "Ngày sinh";
  User _user;
  DateTime datetime = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _user = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: HexColor(Constants_Color.back_color), size: 24,),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text(title, style: TextStyle(fontSize: 20, color: HexColor(Constants_Color.text_color_header)),),
        backgroundColor: HexColor(Constants_Color.color_white),
      ),
      body: getBody(),
    );
  }

  Widget getBody(){
    return Container(
      margin: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 20),
            child: Center(
              child: Text(
                Constants_String.screen3_birthday,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 50),
            child: DatePickerWidget(
              looping: false,
              firstDate: DateTime(1905, 01, 01),
              lastDate: DateTime.now(),
              initialDate: DateTime.now(),
              locale: DatePicker.localeFromString("vi"),
              onChange: (DateTime newDate, _) => _onChangeDate(newDate),
              pickerTheme: DateTimePickerTheme(
                itemTextStyle: TextStyle(
                  fontSize: 14,
                  color: HexColor(Constants_Color.text_normal)
                ),
                dividerColor: HexColor("#4f4f4f")
              ),
            ),
          ),
          getButtonNext()
        ],
      ),
    );
  }

  Widget getButtonNext(){
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
              fontSize: 16,
              color: HexColor(Constants_Color.color_white)
            ),
          ),
        ),
      ),
    );
  }

  void _onPressNext(){
    if (datetime != null){
      // Set Date for user in here
      Navigator.pushNamed(
          context,
          ScreenSexual.route,
          arguments: _user
      );
    }
  }

  void _onChangeDate(DateTime newDate){
    datetime= newDate;
  }
}
