import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:wasm';

import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/models/user_info.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:fake_app/screens/custom_widget/list_post_widget.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/home_pages/list_friends_page.dart';
import 'package:fake_app/screens/home_pages/suggest_friend.dart';
import 'package:fake_app/screens/messenger/messenger_screen.dart';
import 'package:fake_app/screens/personal_page/edit_personal_details_page.dart';
import 'package:fake_app/screens/personal_page/list_blocks_page.dart';
import 'package:fake_app/screens/search/search_screen.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' as Constants_String;
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/friend_view_model.dart';
import 'package:fake_app/view_models/info_view_model.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PersonalPage extends StatefulWidget {
  static String route = "/personalpage";
  // PersonalPage({this.account});
  // User account;
  @override
  _PersonalPageState createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage>{
  File _image;
  File _imageB;
  List<Friend> listFriend = List();
  List<Post> listPost = List();
  UserViewModel model;
  UserViewModel _userViewModel;
  InfoViewModel _infoViewModel;
  PostViewModel _postViewModel;
  FriendViewModel _friendViewModel;
  String userId;
  UserInfo userInfo ;
  bool isPosting = false;
  bool friend = false;
  bool isMyAccount = false;
  bool loadingPost = true;
  bool _isShowLoadingMore = false;
  // ListPost listPostP = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _postViewModel = Provider.of<PostViewModel>(context, listen: false);
    _infoViewModel = Provider.of<InfoViewModel>(context, listen: false);
    _friendViewModel = Provider.of<FriendViewModel>(context, listen: false);
    // print(_infoViewModel.userInfo);

    Future.delayed(Duration(milliseconds: 1)).then((_) {
      _getHeadPersonal();
      _getListFriends();
      _getListPost();
      _initScroll();
    });

  }
  // @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

  void _getListPost() async {
    model = ModalRoute.of(context).settings.arguments;
    if(_userViewModel.user.id == model.user.id){
      if(_postViewModel.listPostPersonal == null || _postViewModel.listPostPersonal.length == 0){
        print("avvv");
        List<Post> posts = await SharedPreferencesHelper.instance.getListPostP();
        String lastIdP = await SharedPreferencesHelper.instance.getLastIdPostP();
        if (posts.length > 0){
          _postViewModel.replaceAllWithP(posts);
          _postViewModel.lastIdP = lastIdP;
        }else if (_postViewModel.listPostPersonal.length == 0){
          await _postViewModel.fetchListPostPersonal(context, _userViewModel.user.token, model.user.id, 0, "");
          setState(() {
            if(_postViewModel.listPostPersonal.length == 0){
              loadingPost = false;
            }
          });
        }
      }
    }else{
      print("heeee");
      await FakeBookService().get_list_posts( _userViewModel.user.token, model.user.id, 0, 10, "").then(
              (res) {
                print("heeee");
                if (res["code"] == "1000") {
                  print("hahah");
                  listPost = (res['data']['posts'] as List).map((post) => Post.fromJson(post)).toList();
                  print(res);
                  setState(() {
                    if (listPost == 0)
                      loadingPost = false;
                  });
                }
              }
      );
    }
  }

  void _getListFriends() async {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;

    if (_userViewModel.user.id == model.user.id) {
      if(_friendViewModel.listFriend == null || _friendViewModel.listFriend.length == 0){
        List<Friend> friends = await SharedPreferencesHelper.instance.getListFriend();
        // String lastId = await SharedPreferencesHelper.instance.getLastIdPost();
        if (friends.length > 0){
          _friendViewModel.replaceAllWith(friends);
          setState(() {
            listFriend = _friendViewModel.listFriend;
          });
        }else if (_friendViewModel.listFriend.length == 0){
          await _friendViewModel.fetchListFriend(context, _userViewModel.user.token, model.user.id, 0);
          setState(() {
            listFriend = _friendViewModel.listFriend;
            if(listFriend.length==0){
              friend = true;
            }
          });
        }
      } else {
        setState(() {
          listFriend = _friendViewModel.listFriend;
        });
      }
    } else {
      FakeBookService().get_user_friends(_userViewModel.user.token, model.user.id, 0, 6).then((res) {
        setState(() {
          listFriend = (res["data"]["friends"] as List).map((friend) => Friend.fromJson(friend)).toList();
          if(listFriend.length==0){
            friend = true;
          }
        });
        print(res["data"]["friends"]);
        print(listFriend);
      });
    }
  }

  void _getHeadPersonal() async {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;
    if (_userViewModel.user.id == model.user.id) {
      if (_infoViewModel.userInfo == null) {
        FakeBookService().get_user_info(_userViewModel.user.token, _userViewModel.user.id).then((res){
          if(res["code"] == "1000") {
            print(res["data"]);
            setState(() {
              userInfo = UserInfo.fromJson(res["data"]);
              _infoViewModel.setUserInfo(userInfo);
            });
          }
        });
      } else {
        userInfo = _infoViewModel.userInfo;
      }
    } else {
      FakeBookService().get_user_info(_userViewModel.user.token, model.user.id).then((res){
        print(res);
        if(mounted) {
          setState(() {
            userInfo = UserInfo.fromJson(res["data"]);
          });
        }
      });
    }
  }

  Widget build(BuildContext context) {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;
    if (_userViewModel.user.id == model.user.id) userInfo = _infoViewModel.userInfo;
    List<Widget> children = [];
    children.add(HeadPersonalPage());
    children.add(Information());
    children.add(Friends());
    children.add(_postWidget());
    children.add(actionMorePost());
    children.add(_emptySpace(10));
    if(isPosting) {
      _postViewModel.scrollListPost.animateTo(1100, duration: new Duration(milliseconds: 1500), curve: Curves.ease);
      children.add(_loadingWidget());
    } else {
      children.add(Container());
    }
    // children.add(isPosting ? _loadingWidget() : Container());
    children.add((_userViewModel.user.id == model.user.id)?_getListPostP():ListPostP(listPost));
    children.add(_isShowLoadingMore ? Center( // For loading More post
        child: Container(
            padding: EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 4),
            child: Constant.getDefaultCircularProgressIndicator(20)
        )
    ) : Container());
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
              "Trang cá nhân"
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: _onPressSearch
            )
          ],
        ),
        body: ListView(
            // controller: _scrollController,
            controller: _postViewModel.scrollListPost,
            children: children
        ),
      ),
    );
  }

  Widget _getListPostP(){
    if (_postViewModel.listPostPersonal != null && _postViewModel.listPostPersonal.length > 0) {
      return ListPost(isPersonPage: true);
    } else if (loadingPost == false){
      return Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Center(
          child: Text(
            "Bạn chưa cập nhật bài viết nào",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
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

  Widget ListPostP(List<Post> listPost){

    if(listPost != null && listPost.length > 0) {
      List<Widget> children = [];
      print(listPost);
      listPost.forEach((post) {
        children.add(PostWidget(post: post,));
      });
      return Column(
        children: children,
      );
    } else if (loadingPost == false) {
      return Container(
        padding: EdgeInsets.all(20),
        height: 300,
        child: Center(
          child: Text(
            "Không có bài viết nào",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
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

  Widget HeadPersonalPage(){
   if(model == null ){
     return Column(
       children: [
         Stack(
           children: <Widget>[
             Container(
               margin: const EdgeInsets.all(15.0),
               height: 330.0,
               decoration: BoxDecoration(
                 //color: Colors.amberAccent[400],
                   borderRadius: BorderRadius.circular(10.0)
               ),
             ),
             Shimmer.fromColors(child: Container(
               margin: const EdgeInsets.all(15.0),
               height: 220,
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.only(
                       topRight: Radius.circular(10),
                       topLeft: Radius.circular(10)
                   ),
                   image: DecorationImage(
                       image: AssetImage("images/my_avatar.jpg"),
                       fit: BoxFit.cover
                   )
               ),
             ), baseColor: Colors.grey[200], highlightColor: Colors.grey[100]),
             Container(
                 margin: EdgeInsets.fromLTRB(0, 140, 0, 0),
                 alignment: Alignment.center,
                 child: Container(
                   width: MediaQuery.of(context).size.width * 0.545,
                   height: MediaQuery.of(context).size.width * 0.545,
                   child: Stack(
                     children: [
                       CircleAvatar(
                           radius: MediaQuery.of(context).size.width * 0.265,
                           backgroundColor: Colors.white24,
                           child:  Shimmer.fromColors(child: CircleAvatar(
                             backgroundColor: Colors.white,
                             radius: MediaQuery.of(context).size.width * 0.25,
                           ), baseColor: Colors.grey[200], highlightColor:  Colors.grey[100])
                       ),
                     ],
                   ),
                 )
             ),
           ],
         ),

       ],
     );
   } else {
     if(_userViewModel.user.id == model.user.id) {
       return Column(
         children: [
           Stack(
             children: <Widget>[
               Container(
                 margin: const EdgeInsets.all(15.0),
                 height: 330.0,
                 decoration: BoxDecoration(
                   //color: Colors.amberAccent[400],
                     borderRadius: BorderRadius.circular(10.0)
                 ),
               ),
               (_imageB != null)
                   ? Container(
                 margin: const EdgeInsets.all(15.0),
                 height: 220,
                 width: MediaQuery.of(context).size.width * 1,
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.only(
                         topRight: Radius.circular(10),
                         topLeft: Radius.circular(10)
                     ),
                   color: Colors.blue
                 ),
                 child: RawMaterialButton(
                   onPressed: _setBackgroudImage,
                   child: Container(
                     // margin: const EdgeInsets.all(15.0),
                     height: 220,
                     width: MediaQuery.of(context).size.width * 1,
                     child: ClipRRect(
                       borderRadius: BorderRadius.only(
                           topRight: Radius.circular(10),
                           topLeft: Radius.circular(10)
                       ),
                       child: Image.file(
                         _imageB,
                         fit: BoxFit.cover,
                       ),
                     )
                   ),
                 ),
               )
                   :(userInfo == null)
                     ?Shimmer.fromColors(
                     child: Container(
                       margin: const EdgeInsets.all(15.0),
                       height: 220,
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.only(
                             topRight: Radius.circular(10),
                             topLeft: Radius.circular(10)
                         ),
                         color: Colors.blue,
                       ),
                     ),
                     baseColor: Colors.grey[200],
                     highlightColor: Colors.grey[100]
                 )
                     :Container(
                 margin: const EdgeInsets.all(15.0),
                 height: 220,
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.only(
                       topRight: Radius.circular(10),
                       topLeft: Radius.circular(10)
                   ),
                   color: HexColor(ConstColor.grey_fake_transparent),
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
                     margin: const EdgeInsets.all(15.0),
                     height: 220,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.only(
                           topRight: Radius.circular(10),
                           topLeft: Radius.circular(10)
                       ),
                     ),
                   ),
                 ),
               ),
               Container(
                   margin: EdgeInsets.fromLTRB(0, 140, 0, 0),
                   alignment: Alignment.center,
                   child: Container(
                     width: MediaQuery.of(context).size.width * 0.545,
                     height: MediaQuery.of(context).size.width * 0.545,
                     child: Stack(
                       children: [
                         CircleAvatar(
                             radius: MediaQuery.of(context).size.width * 0.265,
                             backgroundColor: Colors.white,
                             child: (_image != null)

                                 ? ClipRRect(
                                 borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.5),
                                 child: RawMaterialButton(
                                   onPressed: _setAvatarImage,
                                   child: Image.file(
                                     _image,
                                     width: MediaQuery.of(context).size.width * 0.5,
                                     height: MediaQuery.of(context).size.width * 0.5,
                                     fit: BoxFit.cover,
                                   ),
                                 )
                             )

                                 : Container(
                                 child: (model.user.link_avatar != null && model.user.link_avatar.length > 0)
                                     ? CircleAvatar(
                                   backgroundImage: NetworkImage(model.user.link_avatar),
                                   backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                                   radius: MediaQuery.of(context).size.width * 0.25,
                                   child: RawMaterialButton(
                                     onPressed: _setAvatarImage,
                                     padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.25),
                                     shape: CircleBorder(),
                                   ),
                                 )
                                     : CircleAvatar(
                                   backgroundImage: AssetImage("images/user_grey.png"),
                                   backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                                   radius: MediaQuery.of(context).size.width * 0.25,
                                   child: RawMaterialButton(
                                     onPressed: _setAvatarImage,
                                     padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.25),
                                     shape: CircleBorder(),
                                   ),
                                 )
                             )
                         ),
                         Align(
                           alignment: Alignment.bottomRight,
                           child: RawMaterialButton(
                             onPressed: _setAvatarImage,
                             fillColor: HexColor(Constants_Color.empty_space_color),
                             child: Icon(
                               Icons.camera_alt_rounded,
                               size: MediaQuery.of(context).size.width * 0.06,
                               color: Colors.black,
                             ),
                             padding: EdgeInsets.all(13.0),
                             shape: CircleBorder(),
                           ),
                         ),
                       ],
                     ),
                   )
               ),
               (userInfo == null)
                   ?Container()
                   :Container(
                 // camera on title image
                   margin: EdgeInsets.fromLTRB(0, 170, 10, 0),
                   child: Align(
                     alignment: Alignment.bottomRight,
                     child: RawMaterialButton(
                       onPressed: _setBackgroudImage,
                       fillColor: HexColor(Constants_Color.empty_space_color),
                       child: Icon(
                         Icons.camera_alt_rounded,
                         size: MediaQuery.of(context).size.width * 0.06,
                         color: Colors.black,
                       ),
                       padding: EdgeInsets.all(13.0),
                       shape: CircleBorder(),
                     ),
                   )
               )
             ],
           ),
           Container(
             margin: const EdgeInsets.all(10.0),
             child: Center(
               child: Text(
                 model.user.name,
                 style: TextStyle(fontSize: 33,
                     fontWeight: FontWeight.w600),

               ),
             ),
           ),
           (userInfo != null && userInfo.description.length > 0)
               ? Container(
             margin: const EdgeInsets.all(2.0),
             child: Center(
               child: Text(
                 userInfo.description,
                 style: TextStyle(fontSize: 18,),
               ),
             ),
           )
                : Container(),
           Container(
             margin: const EdgeInsets.all(15.0),
             decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10)
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 Container(
                   child: FlatButton.icon(
                     label: Text('Thêm vào tin',
                       style: new TextStyle(
                         fontSize: 19.0,
                         color: Colors.white,
                       ),
                     ),
                     icon: Icon(Icons.add_circle),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.button_active_color),
                     textColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.76,
                     onPressed: (){
                       print('You tapped on FlatButton');
                     },
                   ),
                 ),
                 Container(
                   child: FlatButton(
                     child: Icon(Icons.more_horiz_rounded),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.empty_space_color),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.14,
                     onPressed: _onPressMoreAccount
                   ),
                 ),
               ],
             ),
           ),
           (userInfo != null ) ? Divider(
             height: 1,
             color: HexColor(Constants_Color.empty_space_color),
             thickness: 1,
             indent: 15,
             endIndent: 15,
           ): Container(),
         ],
       );
     } else {
       return Column(
         children: [
           Stack(
             children: <Widget>[
               Container(
                 margin: const EdgeInsets.all(15.0),
                 height: 330.0,
                 decoration: BoxDecoration(
                   //color: Colors.amberAccent[400],
                     borderRadius: BorderRadius.circular(10.0)
                 ),
               ),
               (userInfo == null)
                   ?Shimmer.fromColors(
                       child: Container(
                         margin: const EdgeInsets.all(15.0),
                         height: 220,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.only(
                                 topRight: Radius.circular(10),
                                 topLeft: Radius.circular(10)
                             ),
                           color: Colors.blue,
                         ),
                       ),
                       baseColor: Colors.grey[200],
                       highlightColor: Colors.grey[100]
                    )
                   :Container(
                 margin: const EdgeInsets.all(15.0),
                 height: 220,
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.only(
                         topRight: Radius.circular(10),
                         topLeft: Radius.circular(10)
                     ),
                     image: DecorationImage(
                         image: (userInfo != null && userInfo.cover_image.length > 0)
                             ?NetworkImage(userInfo.cover_image)
                             :AssetImage("images/my_avatar.jpg"),
                         fit: BoxFit.cover
                     )
                 ),
                 child: RawMaterialButton(
                   onPressed: _seeBackground,
                   child: Container(
                     margin: const EdgeInsets.all(15.0),
                     height: 220,
                     decoration: BoxDecoration(
                       borderRadius: BorderRadius.only(
                           topRight: Radius.circular(10),
                           topLeft: Radius.circular(10)
                       ),
                     ),
                   ),
                 ),
               ),
               Container(
                   margin: EdgeInsets.fromLTRB(0, 140, 0, 0),
                   alignment: Alignment.center,
                   child: Container(
                     width: MediaQuery.of(context).size.width * 0.545,
                     height: MediaQuery.of(context).size.width * 0.545,
                     child: CircleAvatar(
                       radius: MediaQuery.of(context).size.width * 0.265,
                       backgroundColor: Colors.white,
                       child: (model.user.link_avatar != null && model.user.link_avatar.length > 0)
                           ? CircleAvatar(
                         backgroundImage: NetworkImage(model.user.link_avatar),
                         backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                         radius: MediaQuery.of(context).size.width * 0.26,
                         child: RawMaterialButton(
                           onPressed: (){},
                           padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.25),
                           shape: CircleBorder(),
                         ),
                       )
                           : CircleAvatar(
                         backgroundImage: AssetImage("images/user_grey.png"),
                         backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                         radius: MediaQuery.of(context).size.width * 0.26,
                         child: RawMaterialButton(
                           onPressed: (){},
                           padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.25),
                           shape: CircleBorder(),
                         ),
                       )
                     )
                   )
               ),
             ],
           ),
           Container(
             margin: const EdgeInsets.all(10.0),
             child: Center(
               child: Text(
                 model.user.name,
                 style: TextStyle(fontSize: 33,
                     fontWeight: FontWeight.w600),

               ),
             ),
           ),
           (userInfo != null && userInfo.description.length > 0)
               ? Container(
             margin: const EdgeInsets.all(2.0),
             child: Center(
               child: Text(
                 userInfo.description,
                 style: TextStyle(fontSize: 18,),
               ),
             ),
           )
               : Container(),
           (userInfo == null)
               ?Container()
               :Container(
             margin: const EdgeInsets.all(15.0),
             decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(10)
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 Container(
                   child: (userInfo == null)
                       ?Container()
                       :(userInfo.relationship == "their_request")
                       ?FlatButton.icon(
                     label: Text('Trả lời',
                       style: new TextStyle(
                         fontSize: 19.0,
                         color: Colors.white,
                       ),
                     ),
                     icon: Icon(Icons.person_add_alt_1),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.button_active_color),
                     textColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.62,
                     onPressed: _onPressAccept,
         )
                       :(userInfo.relationship == "your_request")
                       ?FlatButton.icon(
                     label: Text('Đã gửi lời mời',
                       style: new TextStyle(
                         fontSize: 19.0,
                         color: Colors.white,
                       ),
                     ),
                     icon: Icon(Icons.person_add_alt_1),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.button_active_color),
                     textColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.62,
                     onPressed: _onPressRequest,
               )
                       :(userInfo.relationship == "is_friend")
                       ?FlatButton.icon(
                     label: Text('Nhắn tin',
                       style: new TextStyle(
                         fontSize: 19.0,
                         color: Colors.white,
                       ),
                     ),
                     icon: Icon(Icons.message),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.button_active_color),
                     textColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.62,
                     onPressed: _onPressMess,
                 )
                       :FlatButton.icon(
                     label: Text('Thêm bạn bè',
                       style: new TextStyle(
                         fontSize: 19.0,
                         color: Colors.white,
                       ),
                     ),
                     icon: Icon(Icons.person_add_alt_1_rounded),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.button_active_color),
                     textColor: Colors.white,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.62,
                     onPressed: _onPressAddFriend,
                 ),
                 ),
                 Container(
                   child: (userInfo == null)
                        ?Container()
                        :(userInfo.relationship == "is_friend")
                        ?FlatButton(
                     child: Image.asset('images/is_friend.png', filterQuality: FilterQuality.high, width: 22, height: 22,),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.empty_space_color),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.14,
                     onPressed: _onPressActionFriend,
                   )
                        :FlatButton(
                     child: Image.asset('images/messenger.png', filterQuality: FilterQuality.high, width: 22, height: 22,),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.empty_space_color),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.14,
                     onPressed: _onPressMess,
                   ),
                 ),
                 Container(
                   child: FlatButton(
                     child: Icon(Icons.more_horiz_rounded),
                     padding: EdgeInsets.all(8.0),
                     color: HexColor(Constants_Color.empty_space_color),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(6.0),
                     ),
                     minWidth: MediaQuery.of(context).size.width * 0.14,
                     onPressed: _onPressMore,
                   ),
                 ),
               ],
             ),
           ),
           (userInfo != null ) ? Divider(
             height: 1,
             color: HexColor(Constants_Color.empty_space_color),
             thickness: 1,
             indent: 15,
             endIndent: 15,
           ): Container(),
         ],
       );
     }
   }
  }

  Widget Information(){

    if (userInfo == null) {
      return Container();
    } else {
      return Column(
        children: [
          Container(
            child: Column(
              children: <Widget>[
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
                (userInfo != null && userInfo.city.length > 0 && userInfo.country.length > 0)? ListTile(
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
                ):(userInfo != null && userInfo.city.length > 0)? ListTile(
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
                ):(userInfo != null && userInfo.country.length > 0)? ListTile(
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
                ):Container(),
                (userInfo != null) ? ListTile(
                  leading: Icon(Icons.more_horiz_rounded),
                  title: Text(
                    "Xem thông tin của " + userInfo.username,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ): Container(),
              ],
            ),
          ),
          (_userViewModel.user.id == model.user.id)
              ?Container(
            margin: EdgeInsets.all(10),
            child: FlatButton(
                child: Text(
                  "Chỉnh sửa chi tiết công khai",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      color: HexColor(ConstColor.button_active_color),
                      fontWeight: FontWeight.w500
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                //color: HexColor(Constants_Color.empty_space_color),
                color: HexColor('#e6f0ff'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                minWidth: MediaQuery.of(context).size.width * 1,
                onPressed: (){
                  Navigator.pushNamed(
                      context,
                      EditPersonalDetailsPage.route,
                      arguments: userInfo
                  );
                }
            ),
          )
              :Container(),
          (userInfo != null && userInfo.address.length > 0)
              ?Divider(
            height: 1,
            color: HexColor(Constants_Color.empty_space_color),
            thickness: 1,
            indent: 15,
            endIndent: 15,
          )
              :Container(),
        ],
      );
    }
  }

  Widget Friends() {

    if (listFriend != null && listFriend.length > 0){
      return Column(
        children: [
          ListTile(
            title: Row(
              children: <Widget>[
                Text("Bạn bè", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
                (_userViewModel.user.id == model.user.id)
                  ?Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child:  Container(
                      child: FlatButton(
                        child: Text(
                          "Tìm bạn bè",
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
                              ListSuggestFriendPage.route,
                              arguments: model
                          );
                        }
                      ),
                    ),
                  ),
                ) :Container(),
              ],
            ),
            subtitle: Text(listFriend.length.toString() +" bạn bè", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),),
          ),
          Container(
            // margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.27),
            // constraints: BoxConstraints(
            //     minHeight: MediaQuery.of(context).size.width * 0.85,
            //     minWidth: double.infinity,
            //     maxHeight: 350),
            //height: MediaQuery.of(context).size.width * 0.85,
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: listFriend.length,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: MediaQuery.of(context).size.width * 0.0019,
                ),
                itemBuilder: (context, index){
                  return  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RawMaterialButton(
                        onPressed: () => _seePersonalFriend(listFriend[index].id, listFriend[index].avatar, listFriend[index].username) ,
                        //onPressed: () => {print("advc")},
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: (listFriend[index].avatar != null && listFriend[index].avatar.length >0)
                          ?Container(
                            width: MediaQuery.of(context).size.width * 0.27,
                            height: MediaQuery.of(context).size.width * 0.27,
                            decoration: BoxDecoration(
                              color: HexColor(Constants_Color.grey_fake_transparent),
                              image: DecorationImage(
                                  image: NetworkImage(listFriend[index].avatar),
                                  fit: BoxFit.cover),
                            ),
                          )
                          :Container(
                            width: MediaQuery.of(context).size.width * 0.27,
                            height: MediaQuery.of(context).size.width * 0.27,
                            decoration: BoxDecoration(
                              color: HexColor(Constants_Color.grey_fake_transparent),
                              image: DecorationImage(
                                  image: AssetImage("images/user_grey_1.png"),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        width: MediaQuery.of(context).size.width * 0.27,
                        child: Text(
                         listFriend[index].username,
                          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.045,
                              fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  );
                }
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 10, right: 10, left: 10),
            child: FlatButton(
                child: Text(
                  "Xem tất cả bạn bè",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontWeight: FontWeight.w500
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                color: HexColor(Constants_Color.empty_space_color),
                //color: HexColor('#e3e5e8'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                minWidth: MediaQuery.of(context).size.width * 1,
                onPressed: (){
                  Navigator.pushNamed(
                      context,
                      ListFriendPage.route,
                      arguments: model
                  );
                }
            ),
          ),
          Container(
              height: 10,
              color: HexColor(ConstColor.color_grey),
          ),
        ],
      );
    }else if (friend == true){
      return Column(
        children: [
          ListTile(
            title: Text("Bạn bè", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
          ),
          Container(
            padding: EdgeInsets.all(20),
            height: 180,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Chưa có bạn bè nào !!!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  (_userViewModel.user.id == model.user.id)
                  ?Container(
                    margin: EdgeInsets.only(top: 10),
                    child: FlatButton.icon(
                      label: Text('Gợi ý kết bạn',
                        style: new TextStyle(
                          fontSize: 19.0,
                          color: Colors.black45,
                        ),
                      ),
                      icon: Icon(Icons.person_add_alt_1_outlined),
                      padding: EdgeInsets.all(8.0),
                      color: HexColor(Constants_Color.empty_space_color),
                      textColor: Colors.black45,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      //minWidth: MediaQuery.of(context).size.width * 0.76,
                      onPressed: (){
                        Navigator.pushNamed(
                            context,
                            ListSuggestFriendPage.route
                        );
                      },
                    ),
                  ):Container(),
                ],
              )
            ),
          ),
          Container(
              height: 10,
              decoration: BoxDecoration(
                color: HexColor(Constants_Color.empty_space_color),
              )
          ),
        ],
      );
    } else {
      return Column(
        children: [
          ListTile(
            // title: Text("Bạn bè", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),),
            subtitle: Shimmer.fromColors(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 25,
                  width: 40,
                  color: Colors.grey,
                ),
              ),
              baseColor: Colors.grey[200],
              highlightColor: Colors.grey[100])
          ),
          Shimmer.fromColors(
              child: Container(
                // margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.27),
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.width * 0.85,
                    minWidth: double.infinity,
                    maxHeight: 350),
                //height: MediaQuery.of(context).size.width * 0.85,
                child: GridView.builder(
                    itemCount: 6,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: MediaQuery.of(context).size.width * 0.0019,
                    ),

                    itemBuilder: (context, index){
                      return  Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(

                              child: RawMaterialButton(
                                onPressed: (){} ,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.27,
                                    height: MediaQuery.of(context).size.width * 0.27,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                            width: MediaQuery.of(context).size.width * 0.27,
                            child: Align(
                              alignment: Alignment.centerLeft,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width * 0.27,
                                    color: Colors.grey,
                                  ),
                                )
                            ),
                          ),
                        ],
                      );
                    }
                ),
              ),
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100]
          ),
          Container(
              height: 10,
              decoration: BoxDecoration(
                color: HexColor(Constants_Color.empty_space_color),
              )
          ),
        ],
      );
    }
  }

  Widget _postWidget(){
     _userViewModel = Provider.of<UserViewModel>(context, listen: false);
     model = ModalRoute.of(context).settings.arguments;
     if (_userViewModel.user.id == model.user.id) {
       return Column(
         children: [
           Container(
             margin: EdgeInsets.all(10),
             alignment: Alignment.centerLeft,
             child: Text("Bài viết", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
           ),
           Container(
             margin: EdgeInsets.all(0),
             padding: EdgeInsets.only(top: 8, bottom: 8, left: 8),
             decoration: BoxDecoration(
               border: Border(
                 bottom: BorderSide(
                     color: Theme.of(context).dividerColor,
                     width: 1.5
                 ),
                 // top: BorderSide(
                 //     color: Theme.of(context).dividerColor,
                 //     width: 1.5
                 // )
               ),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: <Widget>[
                 (model.user.link_avatar != null && model.user.link_avatar.length > 0)
                     ?CircleAvatar(
                   backgroundImage: NetworkImage(model.user.link_avatar),
                   backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
                   radius: 25,
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
           )
         ],
       );
       // CircularProgressIndicator(strokeWidth: 3,)
     } else {
       return Container(
         margin: EdgeInsets.all(10),
         alignment: Alignment.centerLeft,
         child: Row(
           children: [
             Text("Bài viết", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),),
             // (loadingPost == true) ? Expanded(
             //   child: Align(
             //       alignment: Alignment.centerRight,
             //       child: Container(
             //           width: 20,
             //           height: 20,
             //           child: CircularProgressIndicator(strokeWidth: 3,)
             //       )
             //   ),
             // ) : Container()
           ],
         )
       );
     }

  }

  Widget actionMorePost(){
    final double container_w_size = 120;
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;
    if (_userViewModel.user.id == model.user.id) {
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
    } else {
      return Container();
    }

  }

  Widget _emptySpace(int height){
    return SizedBox(
      height: height.toDouble(),
      child: Container(
        height: 10,
        color: HexColor(ConstColor.color_grey),
      ),
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
                backgroundImage: (_userViewModel.user.link_avatar != null && _userViewModel.user.link_avatar.length > 0)
                    ?NetworkImage(_userViewModel.user.link_avatar)
                    :AssetImage("images/user_grey.png"),
                radius: 20,
                backgroundColor: HexColor(Constants_Color.grey_fake_transparent),
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

  void _addLoadingMoreWidget() {
    setState(() {
      _isShowLoadingMore = true;
    });
  }

  void _onLoadMorePosts() async {
   if(_userViewModel.user.id == model.user.id) {
     _postViewModel.isLoadingMorePost = true;
     await _postViewModel.fetchListPostPersonal(context, _userViewModel.user.token, model.user.id, _postViewModel.indexP, _postViewModel.lastIdP);
     _postViewModel.isLoadingMorePost = false;
     setState(() {
       _isShowLoadingMore = false;
     });
   }
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

  void _seePersonalFriend (String id, String avatar, String name) {
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = id;
    user.name = name;
    user.link_avatar = avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
      context,
      PersonalPage.route,
      arguments: _user
    );
  }
  void _setBackgroudImage () {
    BottomSheetHelper.showActionBackgroud(context, _imgFromGalleryBackground);
  }
  void _setAvatarImage () {
    BottomSheetHelper.showActionAvatar(context, _imgFromGalleryAvatar);
  }
  void _imgFromGalleryAvatar () async {
    File image = await ImagePicker.pickImage (
        source: ImageSource.gallery, imageQuality: 50
    );
    Navigator.of(context).pop();
    print(image);
    if (image == null) return;
    setState(() {
      _image = image;
    });
    final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    String token = model.user.token;
    String username = model.user.name;
    String stringImage = base64Encode(image.readAsBytesSync());
    print(stringImage);
    setState(() {
      isPosting = true;
    });
    await FakeBookService().changeInfoAfterSignUp(token, username, stringImage)
        .then((res) {
      print(res);
      model.user.link_avatar = res["data"]["avatar"];
      // setState(() {
      //   isPosting = true;
      // });
    });

    var responseP = await FakeBookService().change_avatar(token, stringImage);
    if (responseP != null){
      int code = int.parse(responseP['code']);
      if (code == 1000){
        Provider.of<PostViewModel>(context, listen: false).addPostHead(Post.fromJson(responseP['data']));
      } else {
        // Do need change in here;
      }
    }
    setState(() {
      isPosting = false;
    });

    SharedPreferencesHelper.instance.setCurrentUser(model.user);
    List<User> accounts = await SharedPreferencesHelper.instance.getListAccount();
    for (int i = 0; i < accounts.length; i++){
      if (accounts[i].id == model.user.id){
        accounts[i].link_avatar = model.user.link_avatar;
        break;
      }
    }
    SharedPreferencesHelper.instance.setListAccount(accounts);
  }

  void _imgFromGalleryBackground () async {
    File image = await ImagePicker.pickImage (
        source: ImageSource.gallery, imageQuality: 50
    );
    Navigator.of(context).pop();
    print(image);
    if (image == null) return;
    setState(() {
      _imageB = image;
    });
    // final UserViewModel model = Provider.of<UserViewModel>(context, listen: false);
    String token = _userViewModel.user.token;
    String username = model.user.name;
    String description = userInfo.description;
    String address = userInfo.address;
    String city = userInfo.city;
    String country = userInfo.country;
    String link = userInfo.link;
    String avatar = userInfo.avatar;
    String cover_image = userInfo.cover_image;
    String stringImage = base64Encode(image.readAsBytesSync());

    setState(() {
      isPosting = true;
    });
    await FakeBookService().set_user_info(token, username, description, address, city, country, link, "", stringImage)
        .then((res) {
      print(res);
      setState(() {
         userInfo.cover_image = res["data"]["cover_image"];
        // isPosting = true;
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
    setState(() {
      isPosting = false;
    });

    // SharedPreferencesHelper.instance.setCurrentUser(model.user);
    // List<User> accounts = await SharedPreferencesHelper.instance.getListAccount();
    // for (int i = 0; i < accounts.length; i++){
    //   if (accounts[i].id == model.user.id){
    //     accounts[i].link_avatar = model.user.link_avatar;
    //     break;
    //   }
    // }
    // SharedPreferencesHelper.instance.setListAccount(accounts);
  }

  void _onPressAccept () async {
    BottomSheetHelper.showActionAccept(context, _onTapAccept, _onTapReject);
  }
  void _onPressActionFriend () async {
    BottomSheetHelper.showActionFriend(context, _onTapDiscardFriend);
  }
  void _onPressMore () async {
    BottomSheetHelper.showActionMore(context, _onTapBlock);
  }
  void _onPressMoreAccount () async {
    BottomSheetHelper.showActionMoreAccount(context, _onTapGetListBlocks);
  }
  void _onTapBlock () {
    Navigator.of(context).pop();
    FakeBookService().set_block(_userViewModel.user.token , model.user.id, '0');
    DialogHelper.showDialogErrorAction(context, "Chặn", "Bạn đã chặn "+model.user.name);
  }
  void _onTapGetListBlocks (){
    Navigator.of(context).pop();
    Navigator.pushNamed(
        context,
        ListBlockPage.route,
        arguments: model
    );

  }
  void _onTapDiscardFriend() {
    Friend newFreind = new Friend();
    newFreind.id = _userViewModel.user.id;
    newFreind.avatar = _userViewModel.user.link_avatar;
    newFreind.username = _userViewModel.user.name;
    setState(() {
      userInfo.relationship = "";
      listFriend.remove(newFreind);
      // listFriend.forEach((friend) {
      //   if (friend.id == account.user.id) listFriend.remove(friend);
      // });
    });
    Navigator.of(context).pop();
    FakeBookService().unfriend(_userViewModel.user.token, model.user.id);
  }
  void _onPressAddFriend ()  {
    setState(() {
      userInfo.relationship = "your_request";
    });
    Navigator.of(context).pop();
    FakeBookService().set_request_friend(_userViewModel.user.token, model.user.id);
  }

  void _onTapAccept() {
    // account = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;
    Friend newFreind = new Friend();
    newFreind.id = _userViewModel.user.id;
    newFreind.avatar = _userViewModel.user.link_avatar;
    newFreind.username = _userViewModel.user.name;
    //newFreind.created = ;
    setState(() {
      userInfo.relationship = "is_friend";
      listFriend.add(newFreind);
    });
    Navigator.of(context).pop();
    FakeBookService().set_accept_friend(_userViewModel.user.token, model.user.id, "1");
  }
  void _onTapReject() {
    setState(() {
      userInfo.relationship = "";
    });
    Navigator.of(context).pop();
    FakeBookService().set_accept_friend(_userViewModel.user.token, model.user.id, "0");
  }

  void _onPressRequest() async {
    BottomSheetHelper.showActionRequest(context, _onTapRequestFriend);
  }

  void _onTapRequestFriend() {
    setState(() {
      userInfo.relationship = "";
    });
    Navigator.of(context).pop();
    FakeBookService().set_request_friend(_userViewModel.user.token, model.user.id);
  }

  void _seeBackground () {
  }

  void _onPressSearch(){
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) =>
          SearchScreen(isSearchPersonalUser: true,))
    );
  }

  void _onPressMess(){
    Navigator.of(context).pushNamed(MessengerScreen.route);
  }

  Future<Void> _onRefresh() async {
    // Load new friend
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    model = ModalRoute.of(context).settings.arguments;

    if (_userViewModel.user.id == model.user.id) {
        await _friendViewModel.fetchListFriend(context, _userViewModel.user.token, model.user.id, 0);
        setState(() {
          print(listFriend);
          listFriend = _friendViewModel.listFriend;
        });
    } else {
      await FakeBookService().get_user_friends(_userViewModel.user.token, model.user.id, 0, 6).then((res) {
        setState(() {
          listFriend = (res["data"]["friends"] as List).map((friend) => Friend.fromJson(friend)).toList();
          if(listFriend.length==0){
            friend = true;
          }
        });
      });
    }

    // Load new post
    if (_userViewModel.user.id == model.user.id) {
      await _postViewModel.fetchListPostPersonal(context, _userViewModel.user.token, model.user.id, 0, "");
      setState(() {
        listPost = _postViewModel.listPostPersonal;
      });
      return null;
    } else {
      await FakeBookService().get_list_posts(
          _userViewModel.user.token, model.user.id, 0, 10, "").then(
              (res) {
            if (res["code"] == "1000") {
              setState(() {
                listPost = (res['data']['posts'] as List).map((post) =>
                    Post.fromJson(post)).toList();
              });
              return null;
            }
          }
      );
    }
  }

}

