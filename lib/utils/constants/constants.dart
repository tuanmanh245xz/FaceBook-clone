
// Image link
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/screens/custom_screen/login_screen.dart';
import 'package:fake_app/screens/custom_screen/login_again_screen.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/accept_view_model.dart';
import 'package:fake_app/view_models/friend_view_model.dart';
import 'package:fake_app/view_models/info_view_model.dart';
import 'package:fake_app/view_models/notify_view_model.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/suggest_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants_colors.dart';
import 'constants_prefs.dart';

String login_facebook = 'images/login_facebook';
// Default for pixel size
double default_font_size = 20;
double hint_text_size = 18;


class Constant {
  static const int code_login_failed = 1000;
  static const int code_login_successful = 1001;
  static const int code_no_internet = 1002;
  static const int code_maintaince_server = 1003;
  static const int code_throw_post = 1;
  static const int code_continue_edit_post = 2;
  static final Widget defaultAvatar = CircleAvatar(
    child: CircleAvatar(
      radius: 18,
      child: Icon(Icons.person, color: HexColor(ConstColor.text_color_blue)),
      backgroundColor: HexColor(ConstColor.color_white),
    ),
    backgroundColor: HexColor(ConstColor.color_grey),
    radius: 20,
  );


  static Post post = Post(
      idPost: "abc",
      described: PostWidget.defaultString,
      created: DateTime.now(),
      modified: null,
      numOfLike: PostWidget.defaultNumberLiked,
      numOfComment: PostWidget.defaultNumberComment,
      isLiked: true,
      images: [
      ],
      videos: [
        VideoUrl(id: "abc", urlVideo: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4", thumb: "https://www.gannett-cdn.com/presto/2019/10/04/USAT/26cae653-5f5d-4622-9666-016ee594a026-AP_Music-Justin_Bieber.JPG?crop=2985,1680,x0,y207&width=1600&height=800&format=pjpg&auto=webp")
      ],
      author: ShortUser(id: "abc", name: "Nguyễn Tuấn Nam", avatar: PostWidget.defaultImage),
      state: "Hao hung",
      isBlocked: false,
      canEdit: true,
      banned: false,
      canComment: true
  );

  // static Conversation conversation = Conversation(
  //   isBlocked: false,
  //   message: Message(
  //     messageId: "abc",
  //     message: "Chào cậu",
  //     unread: false,
  //     created: DateTime.now(),
  //     sender: ShortUser(
  //       id: "abc",
  //       name: "Tuấn Nam",
  //       avatar: PostWidget.defaultImage
  //     )
  //   )
  // );

  static List<String> list_emotion = [
    'icon_awsome',
    'icon_cold',
    'icon_disapointed',
    'icon_emotion',
    'icon_happy',
    'icon_insance',
    'icon_love',
    'icon_sad',
    'icon_sick',
    'icon_thankful',
    'icon_very_happy',
    'icon_angry',
    'icon_fashion',
    'icon_relax',
    'icon_terrible',
    'icon_sleep'
  ];

  static List<String> list_emotion_mean = [
    'tuyệt vời',
    'lạnh',
    'thất vọng',
    'xúc động',
    'vui vẻ',
    'điên',
    'đang yêu',
    'buồn',
    'ốm',
    'rất cảm kích',
    'rất hạnh phúc',
    'tức giận',
    'thời trang',
    'thư giãn',
    'khủng khiếp',
    'đang ngủ'
  ];

  static List<String> list_action = [
    'icon_attend',
    'icon_congrat',
    'icon_eat',
    'icon_fly',
    'icon_play_game',
    'icon_search',
  ];

  static List<String> list_action_mean = [
    'Đang tham gia',
    'Đang chúc mừng',
    'Đang ăn',
    'Đang đi tới',
    'Đang chơi',
    'Đang tìm'
  ];

  static Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static void backOnError(BuildContext context, int error_code){
    Navigator.of(context).pop(error_code);
  }

  static bool parseBoolFromDigit(String boolean){
    if (int.parse(boolean) == 0) return false;
    else return true;
  }

  static Widget getAvatar({@required String urlImage, @required double sizeAvatar}){
    if(urlImage == null || urlImage.length == 0){
      return CircleAvatar(
        radius: sizeAvatar,
        child: Image.asset(
          'images/user_grey.png'
        )
      );
    }
    return CircleAvatar(
      radius: sizeAvatar,
      backgroundImage: CachedNetworkImageProvider(urlImage),
      child: Align(
          alignment: Alignment.bottomRight,
          child:
          CircleAvatar(
            radius: sizeAvatar / 3.5,
            backgroundColor: HexColor(ConstColor.color_white),
            child: CircleAvatar(
              radius: (sizeAvatar / 3.5 - 2),
              backgroundColor: HexColor(ConstColor.color_green),
            ),
          )
      ),
    );
  }

  static Widget getNoInternetWidget(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          ConstString.error_no_internet_title,
          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 17, color: HexColor(ConstColor.text_color_grey)),
        ),
        Container(height: 8,),
        Text(
          ConstString.error_no_internet,
          style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(ConstColor.text_color_grey)),
        )
      ],
    );
  }

  static Widget getDefaultCircularProgressIndicator(double size, {String color}){
    return Container(
        constraints: BoxConstraints(
            maxWidth: size,
            maxHeight: size
        ),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(HexColor(color != null ? color : ConstColor.color_grey)),
        )
    );
  }

  static Widget getDefaultDropDownButton(context, List<String> actions, onChange){
    return DropdownButton<String>(
      items: actions.map((e) => DropdownMenuItem(
        value: e,
        child: Text(
          e,
          style: Theme.of(context).textTheme.bodyText1
        ),
      )).toList(),
      onChanged: (value) => onChange(value)
    );
  }



  static void onLogOut(context) async {
    SharedPreferencesHelper.instance.setCurrentUser(null);
    List<User> accounts = await SharedPreferencesHelper.instance.getListAccount();
    SharedPreferencesHelper.instance.removeAllUSerData();

    Provider.of<AcceptViewModel>(context, listen: false).reset();
    Provider.of<FriendViewModel>(context, listen: false).reset();
    Provider.of<NotifyViewModel>(context, listen: false).reset();
    Provider.of<PostViewModel>(context, listen: false).reset();
    Provider.of<SuggestViewModel>(context, listen: false).reset();

    Provider.of<InfoViewModel>(context, listen: false).setUserInfo(null);

    if (accounts != null && accounts.isNotEmpty){
      Navigator.pushReplacementNamed(context, LoginAgain.route);
      return;
    }
    Navigator.pushReplacementNamed(context, LoginScreen.route);
    return;
  }
}

class ConstantCodeMessage {
  static const int OK = 1000;
  static const int POST_IS_NOT_EXISTED = 9992;
  static const int CODE_VERIFY_IS_INCORRECT = 9993;
  static const int NO_DATA = 9994;
  static const int USER_IS_NOT_VALIDATED = 9995;
  static const int USER_EXISTED = 9996;
  static const int METHOD_IS_INVALID = 9997;
  static const int TOKEN_INVALID = 9998;
  static const int EXCEPTION_ERROR = 9999;
  static const int CANNOT_CONNECT_TO_DB = 10001;
  static const int PARAM_NOT_ENOUGHT = 1002;
  static const int PARAM_TYPE_INVALID = 1003;
  static const int PARAM_VALUE_INVALID = 1004;
  static const int UNKNOW_ERROR = 1005;
  static const int FILE_SIZE_TOO_BIG = 1006;
  static const int UPLOAD_FILE_FAILED = 1007;
  static const int MAXIMUM_NUMBER_OF_IMAGES = 1008;
  static const int NOT_ACCESS = 1009;
  static const int ACTION_HAS_BEEN_DONE = 1010;
}