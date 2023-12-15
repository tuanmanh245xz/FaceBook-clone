import 'dart:convert';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_screen/login_again_screen.dart';
import 'package:fake_app/screens/home_pages/home_page.dart';
import 'package:fake_app/service/fakebook_service.dart';

import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:provider/provider.dart';

class ScreenWaitting extends StatefulWidget {
  static String route = "/signup/waitting";
  @override
  _ScreenWaittingState createState() => _ScreenWaittingState();
}

class _ScreenWaittingState extends State<ScreenWaitting> {
  BuildContext context;
  User _user;
  bool _isFinish = false;
  String uuid;
  FakeBookService fkService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fkService = FakeBookService();
    Constant.getDeviceId().then((value) => doneLoadUuid(value));
  }

  void doneLoadUuid(String value){
    uuid = value;
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    _user = ModalRoute.of(context).settings.arguments as User;

    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody(){
    return FutureBuilder(
      future: fkService.customSignUp(_user.phone, _user.password, uuid, _user.name).then((value) => _onOptSignUp(value)),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        List<Widget> children;
        if (snapshot.hasData){
          children = <Widget>[
            Icon(
              Icons.check_circle_outline,
              color: HexColor(Constants_Color.button_active_color),
              size: 60,
            ),
            Text(
              'Đăng ký thành công',
              style: Theme.of(context).textTheme.headline5,
            )
          ];
        } else {
          children = <Widget>[
            Constant.getDefaultCircularProgressIndicator(40),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Text(
                'Loading...',
                style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 22, fontWeight: FontWeight.bold)
              ),
            )
          ];
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  Widget getDialogWaitting(){
    showDialog(
      context: null,
      barrierDismissible: false,
      builder: (BuildContext context){
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              Text('Loading')
            ],
          ),
        );
      }
    );
  }

  void _onOptSignUp(Map<String, dynamic> data) async {
    if (data == null) return;
    print(data);
    switch(int.parse(data['code'].toString())){
      case ConstantCodeMessage.OK:
        // DK thanh cong, dang nhap, changeInfo luon
        _user.id = data['id'];
        _user.token = data['token'];
        SharedPreferencesHelper.instance.setCurrentUser(_user);
        Provider.of<UserViewModel>(context, listen: false).setUser(_user);
        // For list accounts
        List<User> accounts = await SharedPreferencesHelper.instance.getListAccount();

        if (accounts == null) accounts = List();
        bool accountExisted = false;
        accounts.forEach((element) {
          if (element.phone == _user.phone) accountExisted = true;
        });
        if (!accountExisted)
          accounts.add(_user);
        SharedPreferencesHelper.instance.setListAccount(accounts);

        Navigator.pushNamedAndRemoveUntil(
            context,
            HomePage.route,
            (Route<dynamic> route) => false,
            arguments: _user
        );

        break;
      case ConstantCodeMessage.USER_EXISTED:
        print('Enter here');
        Navigator.of(context).pop(ConstantCodeMessage.USER_EXISTED);
        break;
      default:
        print('Enter here 2');
        return;
    }
  }

}
