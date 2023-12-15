import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/home_pages/watch_page.dart';
import 'package:fake_app/utils/helper/post_helper.dart';

import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ImageScreen extends StatefulWidget {
  static String route = "/image_screen";

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  Post post;
  bool isShowContentPost = false;
  UserViewModel _userViewModel;
  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments as Post;
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      backgroundColor: HexColor(ConstColor.black),
      body: _getBody(),
    );
  }

  Widget _getBody(){
    double wScreen = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        GestureDetector(
          onTap: _onTapHideWidget,
          child: Center(
            child: Image.network(
              post.images.first.url,
              width: wScreen,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        isShowContentPost ? Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PostWidgetHelper.getPostHeaderBlack(context, post, _onTapName),
              PostWidgetHelper.getContentPost(context, post, true),
              PostWidgetHelper.getInfoPost(context, post, _onPressComment, true, user: _userViewModel.user),
              Divider(thickness: 1.5, height: 1, color: Theme.of(context).dividerColor,),
              PostWidgetHelper.getActionsBlack(context, post, _onPressLike, _onPressComment, _onPressShare),
            ],
          ),
        ) : Container()
      ],
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

  void _onTapHideWidget() {
    setState(() {
      if (isShowContentPost)
        isShowContentPost = false;
      else isShowContentPost = true;
    });
  }
}
