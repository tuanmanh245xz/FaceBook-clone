import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/screens/home_pages/terms_policies.dart';

class MenuPage extends StatefulWidget {
  final ScrollController scrollMenuPage = ScrollController();

  MenuPage({Key key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();

  void scrollToTop(){
    if(scrollMenuPage.hasClients){
      scrollMenuPage.animateTo(
          scrollMenuPage.position.minScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn
      );
    }
  }
}

class _MenuPageState extends State<MenuPage> {
  bool isShowMoreHelp = false;
  bool isShowMoreSettings = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollMenuPage,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.all(0),
      children: <Widget>[
        actionProfile(),
        Divider(height: 1, thickness: 1.5,),
        actionOptional(),
        actionWidget(Constants_String.menuP_help, "images/help.png", _onTapHelp),
        isShowMoreHelp ? moreHelpWidget() : Container(),
        Divider(height: 1, thickness: 1.5,),
        actionWidget(Constants_String.menuP_settings, "images/settings.png", _onTapSettings),
        isShowMoreSettings ? moreSettingsWidget() : Container(),
        Divider(height: 1, thickness: 1.5,),
        actionWidget(Constants_String.menuP_logout, "images/logout.png", _onTapLogout),
        Divider(height: 1, thickness: 1.5),
        actionWidget(ConstString.exit, "images/exit.png", _onTapExit)
      ],
    );
  }

  Widget actionProfile(){
    UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    return ListTile(
      onTap: _onTapSeeProfile,
      leading: Consumer<UserViewModel>(
        builder: (context, model, child) => (model.user.link_avatar != null && model.user.link_avatar.length > 0)
            ? CircleAvatar(
          backgroundImage: NetworkImage(model.user.link_avatar),
          backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
          radius: 20,
        )
            :CircleAvatar(
          backgroundImage: AssetImage("images/user_grey.png"),
          backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
          radius: 20,
        ),
      ),
      title: Text(
        model.user.name,
        style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.5, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        ConstString.see_profile,
        style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16),
      ),
    );
  }
  
  Widget actionOptional(){
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                getCardView("images/friends.png", ConstString.friends, 2),
                getCardView("images/group.png", ConstString.group, null),
                getCardView("images/marketplace.png", ConstString.marketplace, 3),
                getCardView("images/hearts.png", ConstString.date, null),
              ],
            ),
          ),
          Container(width: 10,),
          Expanded(
            flex: 1,
            child: Column(
              children: <Widget>[
                getCardView("images/friends.png", ConstString.friends, null),
                getCardView("images/group.png", ConstString.group, null),
                getCardView("images/marketplace.png", ConstString.marketplace, null),
                getCardView("images/hearts.png", ConstString.date, null),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget actionWidget(String title, String srcImage, Function _onTap){
    return Ink(
      color: HexColor(Constants_Color.ConstColor.anti_flash_white),
      child: ListTile(
        leading: Image.asset(srcImage, width: 24, height: 24,),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18),
        ),
        onTap: _onTap,
        trailing: Icon(
          Icons.arrow_drop_down
        ),
      ),
    );
  }

  Widget subActionWidget(String title, String srcImage, Function onTap){
    return Card(
      elevation: 5.0,
      color: HexColor(Constants_Color.ConstColor.color_white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(
        leading: Image.asset(
          srcImage,
          width: 20,
          height: 20,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.5),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    );
  }

  Widget moreHelpWidget(){
    return Ink(
      color: HexColor(Constants_Color.ConstColor.anti_flash_white),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          subActionWidget(ConstString.report_problem, "images/report.png", _onTapReport),
          Container(height: 10,),
          subActionWidget(ConstString.terms_policies, "images/term_and_policies.png", _onTapTermAndPolicies),
          Container(height: 10,)
        ],
      ),
    );
  }

  Widget moreSettingsWidget(){
    return Ink(
      color: HexColor(Constants_Color.ConstColor.anti_flash_white),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          subActionWidget(ConstString.settings, "images/account.png", _onTapReport),
          Container(height: 10,),
          subActionWidget(ConstString.terms_policies, "images/language.png", _onTapTermAndPolicies),
          Container(height: 10,)
        ],
      ),
    );
  }
  
  Widget getCardView(String srcIcon, String title, int numNew){
    final double iconSize = 25;
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 5),
              child: Image.asset(
                srcIcon,
                width: iconSize,
                fit: BoxFit.fitWidth,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16),
            ),
            numNew != null ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.brightness_1, color: HexColor(Constants_Color.ConstColor.color_red,), size: 9,),
                Container(width: 4,),
                Text(
                  numNew.toString() + " " + ConstString.neww,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(Constants_Color.ConstColor.text_color_grey), fontSize: 13),
                )
              ],
            ) : Container(),
            Container()
          ],
        ),
      ),
    );
  }

  void _onTapLogout() async {
    SharedPreferencesHelper.instance.setListPost(null);
    Constant.onLogOut(context);
  }


  void _onTapSettings(){
    setState(() {
      if (isShowMoreSettings)
        isShowMoreSettings = false;
      else isShowMoreSettings = true;
    });
  }

  void _onTapHelp(){
    setState(() {
      if (isShowMoreHelp)
        isShowMoreHelp = false;
      else isShowMoreHelp = true;
    });
  }

  void _onTapReport(){

  }

  void _onTapTermAndPolicies(){
    var url ="https://www.facebook.com/legal/terms";
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }


  void _onTapSeeProfile() {
    UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    print("person");
    Navigator.pushNamed(
      context,
      PersonalPage.route,
      arguments: model
    );
  }

  void _onTapExit() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}

