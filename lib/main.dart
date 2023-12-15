import 'dart:convert';
import 'package:fake_app/firebase/notification/notification_manager.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_screen/edit_media_screen.dart';
import 'package:fake_app/screens/custom_screen/emotion_screen.dart';
import 'package:fake_app/screens/custom_screen/image_screen.dart';
import 'package:fake_app/screens/custom_screen/post_detail_more_screen.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:fake_app/screens/custom_screen/video_screen.dart';
import 'package:fake_app/screens/home_pages/home_page.dart';
import 'package:fake_app/screens/home_pages/list_friends_page.dart';
import 'package:fake_app/screens/home_pages/suggest_friend.dart';
import 'package:fake_app/screens/custom_screen/login_screen.dart';
import 'package:fake_app/screens/messenger/boxchat_screen.dart';
import 'package:fake_app/screens/messenger/messenger_screen.dart';
import 'package:fake_app/screens/messenger/search_mess_screen.dart';
import 'package:fake_app/screens/personal_page/edit_username_page.dart';
import 'package:fake_app/screens/personal_page/edit_details_page.dart';
import 'package:fake_app/screens/personal_page/list_blocks_page.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/screens/personal_page/edit_personal_details_page.dart';
import 'package:fake_app/screens/custom_screen/login_again_screen.dart';
import 'package:fake_app/screens/new_account/new_account_begin.dart';
import 'package:fake_app/screens/new_account/new_account_name.dart';
import 'package:fake_app/screens/new_account/new_account_date.dart';
import 'package:fake_app/screens/new_account/new_account_sexual.dart';
import 'package:fake_app/screens/new_account/new_account_phone.dart';
import 'package:fake_app/screens/new_account/new_account_complete.dart';
import 'package:fake_app/screens/new_account/new_account_password.dart';
import 'package:fake_app/screens/new_account/new_account_watting.dart';
import 'package:fake_app/screens/post_page.dart';
import 'package:fake_app/screens/search/result_search.dart';
import 'package:fake_app/screens/search/search_screen.dart';
import 'package:fake_app/test.dart';
import 'package:fake_app/view_models/mess_view_model.dart';
import 'package:fake_app/view_models/notify_view_model.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/accept_view_model.dart';
import 'package:fake_app/view_models/friend_view_model.dart';
import 'package:fake_app/view_models/suggest_view_model.dart';
import 'package:fake_app/view_models/info_view_model.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';



var initialRoute = HomePage.route;

var logged = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  User _user;
  String curUser = prefs.getString(Prefs.CUR_USER);
  if (curUser != null && curUser.length > 0){
    _user = User.fromJson(jsonDecode(curUser));
    initialRoute = HomePage.route;
  } else {
    String listAccount = prefs.getString(Prefs.ACCOUNTS);
    if (listAccount != null && listAccount.length > 0){
      initialRoute = LoginAgain.route;
    } else {
      initialRoute = LoginScreen.route;
    }
  }
  //initialRoute = Test.route;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel(user: _user),),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => MessengerViewModel(context)),
        ChangeNotifierProvider(create: (context) => NotifyViewModel()),
        ChangeNotifierProvider(create: (context) => AcceptViewModel()),
        ChangeNotifierProvider(create: (context) => FriendViewModel()),
        ChangeNotifierProvider(create: (context) => SuggestViewModel()),
        ChangeNotifierProvider(create: (context) => InfoViewModel()),
      ],
      child: FakebookApp(initRoute: initialRoute,),
    )
  );

}

class FakebookApp extends StatefulWidget {
  FakebookApp({this.initRoute});
  final String initRoute;

  @override
  _FakebookAppState createState() => _FakebookAppState();
}

class _FakebookAppState extends State<FakebookApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PushNotificationManager.instance.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: widget.initRoute,
      routes: {
        HomePage.route: (context) => HomePage(),
        LoginScreen.route: (context) => LoginScreen(),
        ScreenSignUp.route: (context) => ScreenSignUp(),
        ScreenName.route: (context) => ScreenName(),
        ScreenDate.route: (context) => ScreenDate(),
        ScreenSexual.route: (context) => ScreenSexual(),
        ScreenPhone.route: (context) => ScreenPhone(),
        ScreenComplete.route: (context) => ScreenComplete(),
        ScreenPassword.route: (context) => ScreenPassword(),
        ScreenWaitting.route: (context) => ScreenWaitting(),
        ImagesScreen.route: (context) => ImagesScreen(),
        VideoScreen.route: (context) => VideoScreen(),
        LoginAgain.route: (context) => LoginAgain(),
        PostMoreDetailScreen.route: (context) => PostMoreDetailScreen(),
        ImageScreen.route: (context) => ImageScreen(),
        PostScreen.route: (context) => PostScreen(),
        EmotionScreen.route: (context) => EmotionScreen(),
        PersonalPage.route: (context) => PersonalPage(),
        MessengerScreen.route: (context) => MessengerScreen(),
        BoxChatScreen.route: (context) => BoxChatScreen(),
        ListFriendPage.route: (context) => ListFriendPage(),
        Test.route: (context) => Test(),
        ListSuggestFriendPage.route: (context) => ListSuggestFriendPage(),
        SearchScreen.route: (context) => SearchScreen(),
        ResultSearchScreen.route: (context) => ResultSearchScreen(),
        SearchMessScreen.route: (context) => SearchMessScreen(),
        PostPage.route: (context) => PostPage(),
        EditPersonalDetailsPage.route: (context) => EditPersonalDetailsPage(),
        EditUsernamePage.route: (context) => EditUsernamePage(),
        EditDetailsPage.route: (context) => EditDetailsPage(),
        ListBlockPage.route: (context) => ListBlockPage(),
      },
      title: 'None',
      theme: ThemeData(
          primaryColor: HexColor(Constants_Color.primary_color),
          accentColor: HexColor(Constants_Color.accent_color),
          iconTheme: IconThemeData(
            color: HexColor(Constants_Color.accent_color),
          ),
          textTheme: TextTheme(
            headline6: TextStyle(
                fontSize: 20,
                color: HexColor(Constants_Color.text_color_header),
                fontWeight: FontWeight.bold),
            subtitle1: TextStyle(
                fontSize: 16,
                color: HexColor(Constants_Color.text_color_header),
                fontWeight: FontWeight.normal),
            subtitle2: TextStyle(
                fontSize: 14,
                color: HexColor(Constants_Color.text_color_header),
                fontWeight: FontWeight.normal),
          )),
    );
  }
}