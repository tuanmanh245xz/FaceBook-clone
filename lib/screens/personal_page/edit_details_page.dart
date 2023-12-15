
import 'dart:ui';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/view_models/info_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';

class EditDetailsPage extends StatefulWidget {
  static String route = "/editdetailspage";
  @override
  _EditDetailsPageState createState() => _EditDetailsPageState();
}

class _EditDetailsPageState extends State<EditDetailsPage>{
  UserViewModel account;
  InfoViewModel _infoViewModel;
  final String title = "Tên";

  TextEditingController textControlDescription = TextEditingController();
  TextEditingController textControlAddress = TextEditingController();
  TextEditingController textControlCity = TextEditingController();
  TextEditingController textControlCountry = TextEditingController();

  Widget errorMessageWidget = Container();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _infoViewModel = Provider.of<InfoViewModel>(context, listen: false);
    textControlDescription.text = _infoViewModel.userInfo.description;
    textControlAddress.text = _infoViewModel.userInfo.address;
    textControlCity.text = _infoViewModel.userInfo.city;
    textControlCountry.text = _infoViewModel.userInfo.country;
  }

// @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    account = Provider.of<UserViewModel>(context, listen: false);
    return ProgressDialog(
        loadingText: "Đang cập nhật thông tin...",
       backgroundColor: Colors.black45,
       child:  Scaffold(
           appBar: AppBar(
             title: Text(
                 "Chỉnh sửa tên"
             ),
           ),
           body: getBody(),
         backgroundColor: Colors.white,
       ),
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
              errorMessageWidget,
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child:  Container(
                  height: 55,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: TextField(
                      controller: textControlDescription,
                      cursorColor: Colors.blue,
                      cursorWidth: 1,
                      onChanged: (text) => _onTextChange(text),
                      decoration: getInputDecoration(Constants_String.input_description),
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child:  Container(
                  height: 55,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: TextField(
                      controller: textControlAddress,
                      cursorColor: Colors.blue,
                      cursorWidth: 1,
                      onChanged: (text) => _onTextChange(text),
                      decoration: getInputDecoration(Constants_String.input_address),
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child:  Container(
                  height: 55,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: TextField(
                      controller: textControlCity,
                      cursorColor: Colors.blue,
                      cursorWidth: 1,
                      onChanged: (text) => _onTextChange(text),
                      decoration: getInputDecoration(Constants_String.input_city),
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child:  Container(
                  height: 55,
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: TextField(
                      controller: textControlCountry,
                      cursorColor: Colors.blue,
                      cursorWidth: 1,
                      onChanged: (text) => _onTextChange(text),
                      decoration: getInputDecoration(Constants_String.input_country),
                      style: TextStyle(
                          fontSize: 18
                      ),
                    ),
                  ),
                ),
              ),
              getButtonNext(),

            ],
          ),
        ),
      ],
    );
  }

  InputDecoration getInputDecoration(String labelText){
    return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            fontSize: 17,
            color: HexColor(Constants_Color.ConstColor.text_color_blue)
        ),
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder()
    );
  }

  Widget getButtonNext(){
    return RaisedButton(
      onPressed: _onPressSave,
      color: HexColor(Constants_Color.button_active_color),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.5)
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: Center(
          child: Text(
            "Lưu",
            style: TextStyle(
                fontSize: 18,
                color: HexColor(Constants_Color.color_white)
            ),
          ),
        ),
      ),
    );

  }


  void _onPressSave() async {
    account = Provider.of<UserViewModel>(context, listen: false);
    String description = textControlDescription.text;
    String address = textControlAddress.text;
    String city = textControlCity.text;
    String country = textControlCountry.text;

    showProgressDialog();
    var res = await FakeBookService().set_user_info(account.user.token, "", description, address, city, country, "", "", "");

        if(res != null) {
          if (res["code"] == "1000") {
            _infoViewModel.userInfo.description = description;
            _infoViewModel.userInfo.address = address;
            _infoViewModel.userInfo.city = city;
            _infoViewModel.userInfo.country = country;
            dismissProgressDialog();
            DialogHelper.showDialogErrorAction(context, "Cập nhật thành công", "");

          } else {
            dismissProgressDialog();
            DialogHelper.showDialogErrorAction(
                context, "Lỗi", "Xảy ra lỗi, vui lòng thử lại sau...");
          }
        } else {
          Future.delayed(
              const Duration(milliseconds: 100),
                  () {
                dismissProgressDialog();
              }
          );
          DialogHelper.showDialogNoInternet(context);
        }
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

