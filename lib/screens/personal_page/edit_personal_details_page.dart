
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/models/user_info.dart';
import 'package:fake_app/screens/personal_page/edit_username_page.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/screens/personal_page/edit_details_page.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/info_view_model.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter_progress_dialog/flutter_progress_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:fake_app/service/fakebook_service.dart';

class EditPersonalDetailsPage extends StatefulWidget {
  static String route = "/editpersonaldetailspage";
  @override
  _EditPersonalDetailsPageState createState() => _EditPersonalDetailsPageState();
}

class _EditPersonalDetailsPageState extends State<EditPersonalDetailsPage>{
  UserViewModel model;
  File _imageAvatar;
  File _imageBackground;
  UserInfo userInfo;
  InfoViewModel _infoViewModel;
  // String loadingText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = Provider.of<UserViewModel>(context, listen: false);
    _infoViewModel = Provider.of<InfoViewModel>(context, listen: false);
  }


  Widget build(BuildContext context) {

    return ProgressDialog(
      loadingText: "Đang cập nhật ... ",
      backgroundColor: Colors.black45,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              "Chỉnh sửa trang cá nhân"
          ),
        ),
        body: ListView(
          shrinkWrap: true
          ,
          children: <Widget>[
            editAvatar(),
            editBackground(),
            editUserName(),
            editDetails()
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget editAvatar(){
    return Container(
      margin: EdgeInsets.only(top: 10, left: 15, right: 15),
     // height: 240,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text("Ảnh đại diện", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:  Container(
                    child: FlatButton(
                        child: Text(
                          "Chỉnh sửa",
                          style: TextStyle(fontSize: 18, color: HexColor(ConstColor.azure), fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.all(8.0),
                        //color: HexColor(Constants_Color.empty_space_color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minWidth: MediaQuery.of(context).size.width * 0.14,
                        onPressed: _setAvatarImage
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Center(
              child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width * 0.171,
                  backgroundColor: Colors.white,
                  child: (_imageAvatar != null)
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.34),
                      child: RawMaterialButton(
                        onPressed: _setAvatarImage,
                        child: Image.file(
                          _imageAvatar,
                          width: MediaQuery.of(context).size.width * 0.34,
                          height: MediaQuery.of(context).size.width * 0.34,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                  )

                      : Container(
                      child: (model.user.link_avatar != null && model.user.link_avatar.length > 0)
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(model.user.link_avatar),
                        radius: MediaQuery.of(context).size.width * 0.17,
                        child: RawMaterialButton(
                          onPressed: _setAvatarImage,
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.17),
                          shape: CircleBorder(),
                        ),
                      )
                          : CircleAvatar(
                        backgroundImage: AssetImage("images/user_grey.png"),
                        radius: MediaQuery.of(context).size.width * 0.17,
                        child: RawMaterialButton(
                          onPressed: _setAvatarImage,
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.17),
                          shape: CircleBorder(),
                        ),
                      )
                  )
              ),
            ),
          ),
          Divider(
            height: 1,
            color: HexColor(Constants_Color.empty_space_color),
            thickness: 1,
            // indent: 15,
            // endIndent: 15,
          ),
        ],
      ),
    );
  }

  Widget editBackground() {
    // userInfo = ModalRoute.of(context).settings.arguments;
    userInfo = _infoViewModel.userInfo;
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      //height: 280,
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text("Ảnh bìa", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:  Container(
                    child: FlatButton(
                        child: Text(
                          "Chỉnh sửa",
                          style: TextStyle(fontSize: 18, color: HexColor(ConstColor.azure), fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.all(8.0),
                        //color: HexColor(Constants_Color.empty_space_color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minWidth: MediaQuery.of(context).size.width * 0.14,
                        onPressed: _setBackgroudImage
                    ),
                  ),
                ),
              )
            ],
          ),
          (_imageBackground != null)
              ? Container(
            // margin: const EdgeInsets.all(15.0),
            height: 220,
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue
            ),
            child: RawMaterialButton(
              onPressed: _setBackgroudImage,
              child: Container(
                // margin: const EdgeInsets.all(15.0),
                  height: 220,
                  width: MediaQuery.of(context).size.width * 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageBackground,
                      fit: BoxFit.cover,
                    ),
                  )
              ),
            ),
          )
              : Container(
            // margin: const EdgeInsets.all(15.0),
            height: 220,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                    image: (userInfo != null && userInfo.cover_image.length > 0)
                        ?NetworkImage(userInfo.cover_image)
                        :AssetImage("images/my_avatar.jpg"),
                    fit: BoxFit.cover
                )
            ),
            child: RawMaterialButton(
              onPressed: _setBackgroudImage,
              child: Container(
                // margin: const EdgeInsets.all(15.0),
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: HexColor(Constants_Color.empty_space_color),
            thickness: 1,
            // indent: 15,
            // endIndent: 15,
          ),
        ],
      ),
    );
  }

  Widget editUserName() {
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text("Tên", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:  Container(
                    child: FlatButton(
                        child: Text(
                          "Chỉnh sửa",
                          style: TextStyle(fontSize: 18, color: HexColor(ConstColor.azure), fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.all(8.0),
                        //color: HexColor(Constants_Color.empty_space_color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minWidth: MediaQuery.of(context).size.width * 0.14,
                        onPressed: (){
                          Navigator.pushNamed(
                              context,
                              EditUsernamePage.route,
                              arguments: model
                          );
                        }
                    ),
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              model.user.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey
              ),
            ),
          ),
          Divider(
            height: 1,
            color: HexColor(Constants_Color.empty_space_color),
            thickness: 1,
            // indent: 15,
            // endIndent: 15,
          ),
        ],
      ),
    );
  }

  Widget editDetails() {
    userInfo = ModalRoute.of(context).settings.arguments;
    return Container(
      margin: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Text("Thông tin chi tiết", style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child:  Container(
                    child: FlatButton(
                        child: Text(
                          "Chỉnh sửa",
                          style: TextStyle(fontSize: 18, color: HexColor(ConstColor.azure), fontWeight: FontWeight.w400),
                        ),
                        padding: EdgeInsets.all(8.0),
                        //color: HexColor(Constants_Color.empty_space_color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        minWidth: MediaQuery.of(context).size.width * 0.14,
                        onPressed: (){
                          Navigator.pushNamed(
                              context,
                              EditDetailsPage.route,
                              arguments: model
                          );
                        }
                    ),
                  ),
                ),
              )
            ],
          ),
          (userInfo != null && userInfo.description.length > 0)? ListTile(
            leading: Icon(Icons.account_box_outlined),
            // title: Text("Sống tại " +"<bold>"+ userInfo.address +"<bold>"),
            title: RichText(
              text: TextSpan(
                text: 'Mô tả ',
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: <TextSpan>[
                  TextSpan(text: userInfo.description, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ):Container(),
          (userInfo != null && userInfo.address.length > 0)? ListTile(
            leading: Icon(Icons.house),
            // title: Text("Sống tại " +"<bold>"+ userInfo.address +"<bold>"),
            title: RichText(
              text: TextSpan(
                text: 'Sống tại ',
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: <TextSpan>[
                  TextSpan(text: userInfo.address, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ):Container(),
          (userInfo != null && userInfo.city.length > 0 && userInfo.country.length > 0)
              ?ListTile(
            leading: Icon(Icons.gps_fixed),
            title: RichText(
              text: TextSpan(
                text: 'Đến từ ',
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: <TextSpan>[
                  TextSpan(text: userInfo.city + ", " + userInfo.country, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
              :(userInfo != null && userInfo.city.length > 0)
                ?ListTile(
            leading: Icon(Icons.gps_fixed),
            title: RichText(
              text: TextSpan(
                text: 'Đến từ ',
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: <TextSpan>[
                  TextSpan(text: userInfo.city, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
                :(userInfo != null && userInfo.country.length > 0)
                  ?ListTile(
            leading: Icon(Icons.gps_fixed),
            title: RichText(
              text: TextSpan(
                text: 'Đến từ ',
                style: TextStyle(color: Colors.black, fontSize: 18),
                children: <TextSpan>[
                  TextSpan(text: userInfo.country, style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          )
                  :Container(),
        ],
      ),
    );
  }

  void _setAvatarImage () async {
    File image = await ImagePicker.pickImage (
        source: ImageSource.gallery, imageQuality: 50
    );
    //Navigator.of(context).pop();
    print(image);
    if (image == null) return;
    setState(() {
      _imageAvatar = image;
    });
    final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    String token = model.user.token;
    String username = model.user.name;
    String stringImage = base64Encode(image.readAsBytesSync());

    showProgressDialog();

    await FakeBookService().changeInfoAfterSignUp(token, username, stringImage)
        .then((res) {
      print(res);
      Provider.of<UserViewModel>(context, listen: false).user.link_avatar = res["data"]["avatar"];
    });

    await FakeBookService().change_avatar(token, stringImage).then(
        (responseP){
          if (responseP != null){
            int code = int.parse(responseP['code']);
            if (code == 1000){
              Provider.of<PostViewModel>(context, listen: false).addPostHead(Post.fromJson(responseP['data']));
            } else {
              // Do need change in here;
            }
          }
        }
    );
    dismissProgressDialog();
    DialogHelper.showDialogErrorAction(context, "Thay avatar thành công", "");

    SharedPreferencesHelper.instance.setCurrentUser(model.user);
    List<User> models = await SharedPreferencesHelper.instance.getListAccount();
    for (int i = 0; i < models.length; i++){
      if (models[i].id == model.user.id){
        models[i].link_avatar = model.user.link_avatar;
        break;
      }
    }
    SharedPreferencesHelper.instance.setListAccount(models);
  }

  void _setBackgroudImage () async {
    File image = await ImagePicker.pickImage (
        source: ImageSource.gallery, imageQuality: 50
    );
    // Navigator.of(context).pop();
    print(image);
    setState(() {
      _imageBackground = image;
    });
    if (image == null) return;
    // final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    String token = model.user.token;
    String username = model.user.name;
    String description = userInfo.description;
    String address = userInfo.address;
    String city = userInfo.city;
    String country = userInfo.country;
    String link = userInfo.link;
    String avatar = userInfo.avatar;
    String cover_image = userInfo.cover_image;
    String stringImage = base64Encode(image.readAsBytesSync());
    print(stringImage);

    showProgressDialog();
    await FakeBookService().set_user_info(token, username, description, address, city, country, link, "", stringImage)
        .then((res) {
      print(res);
      setState(() {
        _infoViewModel.userInfo.cover_image = res["data"]["cover_image"];
        // userInfo.cover_image = res["data"]["cover_image"];
      });
    });

    var responseP = await FakeBookService().change_background(token, stringImage);
    if (responseP != null){
      int code = int.parse(responseP['code']);
      if (code == 1000){
        print(responseP);
        Provider.of<PostViewModel>(context, listen: false).addPostHead(Post.fromJson(responseP['data']));
      } else {
        // Do need change in here;
      }
    }
    dismissProgressDialog();
    DialogHelper.showDialogErrorAction(context, "Thay ảnh bìa thành công", "");

    // SharedPreferencesHelper.instance.setCurrentUser(model.user);
    // List<User> models = await SharedPreferencesHelper.instance.getListAccount();
    // for (int i = 0; i < models.length; i++){
    //   if (models[i].id == model.user.id){
    //     models[i].link_avatar = model.user.link_avatar;
    //     break;
    //   }
    // }
    // SharedPreferencesHelper.instance.setListAccount(models);
  }

}


