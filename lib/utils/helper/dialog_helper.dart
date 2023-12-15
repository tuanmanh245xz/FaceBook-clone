import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:flutter/material.dart';

import '../constants/constants_colors.dart';
import '../constants/custom_enum.dart';
import 'color_helper.dart';


class DialogHelper {
  static showDialogLoginFailed(BuildContext context, String title, String content){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  static showDialogErrorAction(BuildContext context, String title, String content) async {
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(title),
            content: (content != "")?Text(content):null,
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  static showDialogMaxImagesPost(BuildContext context, String title, String content){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  static Future<int> showDialogConfirm(
      BuildContext context,
      String title,
      String content,
      String titleNativeBtn,
      String titleNegativeBtn,
    ) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text(title, style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 17, color: HexColor(ConstColor.black)),),
          content: Text(content, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16,color: HexColor(ConstColor.text_color_grey)),),
          actions: <Widget>[
            FlatButton(
              child: Text(titleNegativeBtn, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.text_color_grey)),),
              onPressed: (){
                Navigator.of(context).pop(-1);
              },
            ),
            FlatButton(
              child: Text(titleNativeBtn, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.text_color_blue)),),
              onPressed: (){
                Navigator.of(context).pop(1);
              },
            )
          ],
        );
      }
    );
  }

  static Future<DialogCode> showDialogConfirmThreeButton(
      BuildContext context,
      String title,
      String content,
      String okBtn,
      String anotherBtn,
      String noBtn
    ) async {
    print('Enter here');
    return await showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text(title, style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 17, color: HexColor(ConstColor.black)),),
            content: Text(content, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16,color: HexColor(ConstColor.text_color_grey)),),
            actions: <Widget>[
              FlatButton(
                child: Text(okBtn, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.text_color_blue)),),
                onPressed: (){
                  Navigator.of(context).pop(DialogCode.ON_DELETE_POST);
                },
              ),
              FlatButton(
                child: Text(anotherBtn, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.text_color_grey)),),
                onPressed: (){
                  Navigator.of(context).pop(DialogCode.ON_EDIT_POST);
                },
              ),
              FlatButton(
                child: Text(noBtn, style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.text_color_grey)),),
                onPressed: (){
                  Navigator.of(context).pop(DialogCode.ON_CANCEL);
                },
              )
            ],
          );
        }
    );
  }

  static showDialogNoSupport(BuildContext context){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Tính năng tương lai !'),
          content: Text('Tính năng này sẽ phải triển trong tương lai không xa'),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.blue, fontSize: 16.5),
             ),
            )
          ],
        );
      }
    );
  }

  static showDialogNoInternet(BuildContext context){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text(
            ConstString.error_no_internet_title
          ),
          content: Text(
            ConstString.error_no_internet
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: (){
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.blue, fontSize: 16.5),
              ),
            )
          ],
        );
      }
    );
  }

  static Future<void> showLoading(BuildContext context, GlobalKey key) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
            backgroundColor: HexColor(ConstColor.color_white),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 10,),
                    Text(
                      ConstString.post_loading_edit,
                      style: Theme.of(context).textTheme.bodyText1
                    )
                  ],
                ),
              )
            ],
          ),
        );
      }
    );
  }
}