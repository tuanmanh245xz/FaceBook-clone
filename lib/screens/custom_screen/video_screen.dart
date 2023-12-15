import 'dart:io';

import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';

import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/screens/custom_widget/chewie_item_widget.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:provider/provider.dart';
import 'package:fake_app/utils/helper/post_helper.dart';


class VideoScreen extends StatefulWidget {
  static String route = "/video_screen";
  // final Post post;
  // VideoScreen({this.post});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  VideoPlayerController _videoPlayerController;
  Future<void> _initVieoPlayerFuture;
  Media media;
  Post post;
  bool isUrlVideo = false;
  bool isShowContentPost = false;
  UserViewModel _userViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map arg =  ModalRoute.of(context).settings.arguments;
    print(arg['post']);
    post = arg['post'] as Post;
    media = arg['media'] as Media;
    // media = ModalRoute.of(context).settings.arguments as Media;
    if (media is MediaUrl){
       _videoPlayerController = VideoPlayerController.network((media as MediaUrl).urlVideo);
      _initVieoPlayerFuture = _videoPlayerController.initialize();
      _videoPlayerController.setLooping(false);
      _videoPlayerController.setVolume(1);
      isUrlVideo = true;
    } else {
      _videoPlayerController = VideoPlayerController.network((media as MediaMemory).filePathVideo);
      _initVieoPlayerFuture = _videoPlayerController.initialize();
      _videoPlayerController.setLooping(false);
      _videoPlayerController.setVolume(1);
      isUrlVideo = false;
    }

    return Scaffold(
      // backgroundColor: HexColor(ConstColor.black),
      body: ListView(
        children: [
          PostWidgetHelper.getPostHeader(context, post, _onTapAvatar, _onTapUserName, _onPressMore),
          Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height - 180,
            child: ClipRRect(
              child: FutureBuilder(

                future: _initVieoPlayerFuture,
                builder: (context, snapshot){
                  if (snapshot.connectionState == ConnectionState.done){
                    return Center(
                        child: ChewieItem(
                          videoPlayerController: _videoPlayerController,
                          loop: true,
                        )
                    );
                  } else {
                    return Container(
                      height: 400,
                      child: Center(
                          child: CircularProgressIndicator()
                      ),
                    );
                  }
                },
              ),
            )
          ),
         (post.numOfLike != 0 || post.numOfComment != 0) ? PostWidgetHelper.getInfoPost(context, post, _onPressComment, false, user: _userViewModel.user) : Container(height: 35, color: Colors.white,),
          Container(padding: EdgeInsets.symmetric(horizontal: 20),child: Divider(thickness: 0.5, height: 1,)),
          PostWidgetHelper.getActions(context, post, _onPressLike, _onPressComment, _onPressShare, _userViewModel.user),
        ],
      )
    );
  }
  void _onPressLike() async {
    setState(() {
      if (post.isLiked)
        post.numOfLike -= 1;
      else
        post.numOfLike += 1;
      post.isLiked = !post.isLiked;
    });
    bool ok = await _userViewModel.likePost(post);
    setState(() {
      if (ok){
        // Do nothing
      } else {
        // Return state
        if (post.isLiked){
          post.numOfLike -= 1;
        } else {
          post.numOfLike +=1;
        }
        post.isLiked = ! post.isLiked;
      }
    });
  }

  void _onPressComment() async {
    await BottomSheetHelper.showCommentsPost(
        context,
        post
    );
    setState(() {
    });
  }

  void _onPressShare(){

  }
  void _onTapName(){
  }
  void _onTapUserName(){
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = post.author.id;
    user.name = post.author.name;
    user.link_avatar = post.author.avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
        context,
        PersonalPage.route,
        arguments: _user
    );
  }

  void _onTapAvatar(){
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = post.author.id;
    user.name = post.author.name;
    user.link_avatar = post.author.avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
        context,
        PersonalPage.route,
        arguments: _user
    );
  }

  void _onPressMore() async {
  }

}

