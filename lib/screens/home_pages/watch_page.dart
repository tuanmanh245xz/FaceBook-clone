import 'dart:wasm';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_widget/circle_button.dart';
import 'package:fake_app/screens/custom_widget/list_post_widget.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';

import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/post_view_model.dart';

import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class WatchPage extends StatefulWidget {
  WatchPage({Key key}) : super(key : key);

  @override
  _WatchPageState createState() => _WatchPageState();

}

class _WatchPageState extends State<WatchPage> implements Notification {
  bool _isShowLoadingMore = false;
  UserViewModel _userViewModel;
  PostViewModel _postViewModel;
  List<Widget> _childrenBody = [];
  bool loadVideo = false;

  @override
  void initState() {
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _postViewModel = Provider.of<PostViewModel>(context, listen: false);
    _initScroll();
    _initListPost();
  }

  void _initListPost() async {
    if(_postViewModel.listPostVideo == null || _postViewModel.listPostVideo.length == 0){
      List<Post> posts = await SharedPreferencesHelper.instance.getListPostVideo();
      String lastIdVideo = await SharedPreferencesHelper.instance.getLastIdPostVideo();
      if (posts.length > 0){
        _postViewModel.replaceAllVideoWith(posts);
        _postViewModel.lastIdVideo = lastIdVideo;
      }else if (_postViewModel.listPostVideo.length == 0){
        await _postViewModel.fetchListPostVideo(context, _userViewModel.user.token, "", "");
        setState(() {
          if(_postViewModel.listPostVideo.length == 0){
            loadVideo = true;
          }
        });
      }
    }
  }

  void _initScroll(){
    _postViewModel.scrollListVideos.addListener(() {
      double maxScroll = _postViewModel.scrollListVideos.position.maxScrollExtent;
      double currentScroll =  _postViewModel.scrollListVideos.position.pixels;
      double delta = 500;
      if (maxScroll  <= currentScroll){
        if (!_postViewModel.isLoadingMorePost) {
          _addLoadingMoreWidget();
          _onLoadMorePosts();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _childrenBody = [
      _getHeader(),
      _emptySpace(10),
      // ListPost(isVideoPage: true),
      _getListVideo(),
      _isShowLoadingMore ? Center( // For loading More post
          child: Container(
              padding: EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 4),
              child: Constant.getDefaultCircularProgressIndicator(20)
          )
      ) : Container()
    ];
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        controller: _postViewModel.scrollListVideos,
        padding: EdgeInsets.all(0),
        children: _childrenBody,
      ),
    );
  }
  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: <Widget>[
          Text(
            ConstString.watch,
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 22),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CircleButton(
                iconData: Icons.search,
                sizeIcon: 50,
                onTap: () {},
                backgroundColor: HexColor(ConstColor.grey_fake_transparent),
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget _emptySpace(int height){
    return SizedBox(
      height: height.toDouble(),
      child: Container(
          color: HexColor(Constants_Color.empty_space_color)
      ),
    );
  }
  Widget _getListVideo(){
    if (_postViewModel.listPostVideo != null && _postViewModel.listPostVideo.length > 0) {
      return ListPost(isVideoPage: true);
    } else if (loadVideo == true){
      return Container(
        padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              ConstString.add_new_friend,
              style: Theme.of(context).textTheme.headline6,
            ),
            Container(height: 20,),
            Text(
              ConstString.add_new_friends,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Container(height: 20,),
            Container(
              padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
              child: Center(
                  child: RaisedButton(
                    onPressed: _onPressFindFriend,
                    color: HexColor(ConstColor.button_active_color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          ConstString.find_friends,
                          style: TextStyle(
                              color: HexColor(ConstColor.color_white),
                              fontSize: 16),
                        ),
                      ),
                    ),
                  )),
            )
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100],
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                child: ListTile(
                  onTap: (){},
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                  leading:  CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                      child: Image.asset("images/user_grey.png"),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  title: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                  subtitle:  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100],
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                child: ListTile(
                  onTap: (){},
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                  leading:  CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                      child: Image.asset("images/user_grey.png"),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  title: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                  subtitle:  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100],
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                child: ListTile(
                  onTap: (){},
                  contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                  leading:  CircleAvatar(
                    radius: 25,
                    child: ClipRRect(
                      child: Image.asset("images/user_grey.png"),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  title: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                  subtitle:  Container(
                    margin: EdgeInsets.only(top: 4),
                    height: 20,
                    width: MediaQuery.of(context).size.width * 0.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _onPressFindFriend() {
    Provider.of<UserViewModel>(context, listen: false).tabController.animateTo(
        1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
    );
  }
  void _addLoadingMoreWidget() {
    setState(() {
      _isShowLoadingMore = true;
    });
  }
  
  Future<Void> _onRefresh() async {
    // Load new post
    await _postViewModel.fetchListPostVideo(context, _userViewModel.user.token, "", "");
    setState(() {
    });
    return null;
  }

  void _onLoadMorePosts() async {
    _postViewModel.isLoadingMorePost = true;
    await _postViewModel.fetchListPostVideo(context, _userViewModel.user.token, "", _postViewModel.lastIdVideo);
    _postViewModel.isLoadingMorePost = false;
    setState(() {
      _isShowLoadingMore = false;
    });
  }

  @override
  void debugFillDescription(List<String> description) {
    // TODO: implement debugFillDescription
  }

  @override
  void dispatch(BuildContext target) {
    // TODO: implement dispatch
  }

  @override
  bool visitAncestor(Element element) {
    // TODO: implement visitAncestor
    throw UnimplementedError();
  }



  void _onTapSeeProfile() {
    Navigator.of(context).pushNamed(PersonalPage.route);
  }
}
