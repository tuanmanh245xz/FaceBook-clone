
import 'dart:wasm';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_widget/list_post_widget.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/service/fakebook_service.dart';

import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/post_view_model.dart';

import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:shimmer/shimmer.dart';

class NewFeedPage extends StatefulWidget {

  NewFeedPage({Key key}) : super(key: key);

  @override
  _NewFeedPageState createState() => _NewFeedPageState();
}

class _NewFeedPageState extends State<NewFeedPage> implements Notification {
  List<String> nameUser = ["Mai Thị", "Trần Thị Lý", "Giang Nguyên", "Joey Hiếu", "Đinh T. Tươi", "Hong Hanh"];
  bool isPosting = false;
  bool _isShowLoadingMore = false;
  UserViewModel _userViewModel;
  PostViewModel _postViewModel;
  List<Widget> _childrenBody = [];
  bool loadingPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _postViewModel = Provider.of<PostViewModel>(context, listen: false);
    _initScroll();
    _initListPost();
  }

  void _initListPost() async {
    if(_postViewModel.listPost == null || _postViewModel.listPost.length == 0){
      List<Post> posts = await SharedPreferencesHelper.instance.getListPost();
      String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
      if (posts.length > 0){
        _postViewModel.replaceAllWith(posts);
        _postViewModel.lastId = lastId;
      }else if (_postViewModel.listPost.length == 0){
        await _postViewModel.fetchListPost(context, _userViewModel.user.token, "", 0, "");
        setState(() {
          if(_postViewModel.listPost.length == 0){
            loadingPost = true;
          }
        });
      }
    }
  }

  void _initScroll() async {
    _postViewModel.scrollListPost.addListener(() {
      double maxScroll = _postViewModel.scrollListPost.position.maxScrollExtent;
      double currentScroll =  _postViewModel.scrollListPost.position.pixels;
      if (maxScroll - 500  <= currentScroll){
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
      _postWidget(),
      actionMorePost(),
      _emptySpace(10),
      _activeFriends(),
      _emptySpace(10),
      isPosting ? _loadingWidget() : Container(),
      _storiesWidget(),
      _emptySpace(10),
      // ListPost(isNewFeedpage: true),
      _getListPost(),
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

        controller: _postViewModel.scrollListPost,
        padding: EdgeInsets.all(0),
        children: _childrenBody,
        // controller: widget.scrollNewFeed,
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

  Widget _postWidget(){
    final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    return Container(
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.only(top: 8, bottom: 8, left: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.5
          ),
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1.5
          )
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          (model.user.link_avatar != null && model.user.link_avatar.length > 0)
              ?GestureDetector(
            onTap: (){
              UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
              Navigator.pushNamed(
                  context,
                  PersonalPage.route,
                  arguments: model
              );
            },
                child: CircleAvatar(
            backgroundImage: NetworkImage(model.user.link_avatar),
            backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
            radius: 25,
          ),
              )
              :CircleAvatar(
            backgroundImage: AssetImage("images/user_grey.png"),
            backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
            radius: 25,
          ),
          Expanded(
            child: Container(
              height: 35,
              padding: EdgeInsets.only(right: 20, left: 20),
              child: InkWell(
                onTap: _onTapPost,
                borderRadius: BorderRadius.circular(20),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: Constants_String.mainP_what_do_you_think,
                      hintStyle: Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.normal,),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(width: 1, color: Theme.of(context).dividerColor,)
                      ),
                    contentPadding: EdgeInsets.only(top: 0, bottom: 0, right: 0, left: 15)
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  enabled: false,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget actionMorePost(){
    final double container_w_size = 120;
    return Container(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
                Container(
                  width: container_w_size,
                  padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.video_call, size: 20, color: Colors.red,),
                      Text(
                        'Phát trực tiếp',
                        style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              Container(margin: EdgeInsets.only(top: 6, bottom: 6), height: 20, child: VerticalDivider(color: Theme.of(context).dividerColor, thickness: 1.5,)),
              Container(
                width: container_w_size - 30,
                padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.image, size: 20, color: Colors.green,),
                    Text(
                      'Ảnh',
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
          Container(margin: EdgeInsets.only(top: 6, bottom: 6), height: 20, child: VerticalDivider(color: Theme.of(context).dividerColor, thickness: 1.5,)),
              Container(
                width: container_w_size,
                    padding: EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.video_call, size: 20,),
                        Text(
                          'Phòng họp mặt',
                          style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )
                      ],
                    ),
              )
        ],
      ),
    );
  }

  Widget _activeFriends(){
    final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.all(8),
      height: 60,
      child: ListView.builder(itemCount: 7, scrollDirection: Axis.horizontal, itemBuilder: (BuildContext context, int index){
        if (index == 0){
          return Container(
            width: 120,
            padding: EdgeInsets.only(left: 8, right: 8),
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1.5,
                color: HexColor("CDE5FF")
              ),

            ),
            child: Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(right: 6),
                    child: Icon(Icons.video_call, size: 24, color: HexColor("#6761D4"),)),
                Expanded(
                  child: Text(
                    Constants_String.mainP_create_metting_room,
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor("#2874DC"),
                      fontWeight: FontWeight.bold
                    ),
                    maxLines: 2,
                  ),
                )
              ],
            ),
          );
        }
        return Container(
          margin: EdgeInsets.only(right: 5),
          padding: EdgeInsets.all(4),
          child: Stack(
            children: [
              CircleAvatar(
                  backgroundImage: AssetImage("images/avatar_" + (index).toString() +".jpg"),
                backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 7,
                  child: Align(
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 5,
                    ),
                  ),
                ),
              ),

            ],
          )
        );
      }),
    );
  }

  Widget _storiesWidget(){
    final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    return Container(
      height: 180,
      margin: EdgeInsets.only(bottom: 10),
      child: ListView.builder(itemCount: 7, scrollDirection: Axis.horizontal, itemBuilder: (BuildContext context, int index){
        if (index == 0){
          return Container(
            margin: EdgeInsets.only(left: 4, top: 8),
            child: SizedBox(
              height: 180,
              width: 110,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
              ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10)),
                        color: HexColor(Constants_Color.grey_fake_transparent),
                        image: DecorationImage(
                            image: (model.user.link_avatar != null && model.user.link_avatar.length > 0)
                                      ?NetworkImage(model.user.link_avatar)
                                      :AssetImage("images/user_grey_1.png"),
                            fit: BoxFit.cover
                        ),
                      ),

                    ),
                    Positioned(
                      top: 80,
                      left: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.add_circle, size: 40,),
                      ),
                    ),
                    Positioned(
                      left: 25,
                      bottom: 10,
                      child: Text(
                        "Tạo tin",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return Container(
            margin: EdgeInsets.only(left: 0, top: 8),
            child: SizedBox(
              height: 180,
              width: 110,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: HexColor(Constants_Color.grey_fake_transparent),
                        image: DecorationImage(
                            image: AssetImage("images/avatar_" + (index).toString() +".jpg"),
                            fit: BoxFit.cover
                        ),
                      ),

                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 18,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage("images/avatar_" + (index).toString() +".jpg"),
                          backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                        ),
                      ),
                    ),
                    Positioned(
                      width: 95,
                      left: 10,
                      bottom: 10,
                      child: Text(
                        nameUser[index-1],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Container();
      }),
    );
  }

  Widget _loadingWidget(){
    return Column(
      children: [
        Container(
          height: 50,
          padding: EdgeInsets.only(top: 8, bottom: 8, right: 10, left: 10),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(_userViewModel.user.link_avatar),
                radius: 20,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    Constants_String.ConstString.posting,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 3,)
                  )
                ),
              )
            ],
          ),
        ),
        _emptySpace(10)
      ],
    );
  }

  Widget _getListPost(){
    if (_postViewModel.listPost != null && _postViewModel.listPost.length > 0) {
      return ListPost(isNewFeedpage: true);
    } else if (loadingPost == true){
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



  void _onTapPost() async {
    final UserViewModel _userModel = Provider.of<UserViewModel>(context, listen: false);

    var  contentPost = await Navigator.pushNamed(
      context,
      PostScreen.route,
      arguments: _userModel.user
    ) as Map<String, dynamic>;

    if (contentPost != null){
      setState(() {
        isPosting = true;
      });
      var response = await FakeBookService().add_post2(_userModel.user.token, contentPost['images'], contentPost['videos'], contentPost['thumbs'],contentPost['described'], contentPost['status']);
      if (response != null){
        switch(int.parse(response['code'])){
          case 1000:
            var responsePost = await FakeBookService().get_post(_userModel.user.token, response['data']['id']);
            if (responsePost != null){
              int code = int.parse(responsePost['code']);
              if (code == 1000){
                Provider.of<PostViewModel>(context, listen: false).addPostHead(Post.fromJson(responsePost['data']));
              } else {
                // Do need change in here;
              }
            }
            setState(() {
              isPosting = false;
            });
            break;
          default:
            _showErrorUploadPost();
        }
      } else {
        _showErrorUploadPost();
      }
    }
  }

  void _showErrorUploadPost(){
    setState(() {
      isPosting = false;
    });
    DialogHelper.showDialogErrorAction(context, Constants_String.ConstString.error_post, Constants_String.ConstString.error_post_content);
  }

  Future<Void> _onRefresh() async {
    // Load new post
    await _postViewModel.fetchListPost(context, _userViewModel.user.token, "", 0, "");
    setState(() {
    });
    return null;
  }

  void _onLoadMorePosts() async {
    _postViewModel.isLoadingMorePost = true;
    await _postViewModel.fetchListPost(context, _userViewModel.user.token, "", _postViewModel.index, _postViewModel.lastId);
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
