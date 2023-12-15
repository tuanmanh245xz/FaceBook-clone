import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_screen/edit_media_screen.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/home_pages/watch_page.dart';

import 'package:fake_app/utils/helper/media_helper.dart';
import 'package:fake_app/utils/helper/post_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostMoreDetailScreen extends StatefulWidget {
  static String route = "/post_more_detail";
  static List<MediaUrl> defaultListMedia = [
    MediaUrl(isImage: true, urlImage: "https://scontent.fhan2-1.fna.fbcdn.net/v/t1.0-9/119948878_1254229711625117_5903636201598269135_o.jpg?_nc_cat=102&_nc_sid=730e14&_nc_ohc=fhJ7fxG7TeEAX_yeAgx&_nc_ht=scontent.fhan2-1.fna&oh=cf652efa6e5f11027a541f1a051ef363&oe=5FAAB218", urlVideo: null),
    MediaUrl(isImage: true, urlImage: "https://scontent.fhan2-1.fna.fbcdn.net/v/t1.0-9/120138428_1255250811523007_6357495164522830776_o.jpg?_nc_cat=101&_nc_sid=730e14&_nc_ohc=2PWfugHq6GQAX8IsxF6&_nc_ht=scontent.fhan2-1.fna&oh=3cf0de21c28cffa1bd51fa3c2bba55f6&oe=5FAAC108", urlVideo: null),
    MediaUrl(isImage: true, urlImage: "https://scontent.fhan2-3.fna.fbcdn.net/v/t1.0-9/119933366_1250460272002061_3544201100572028710_o.jpg?_nc_cat=108&_nc_sid=730e14&_nc_ohc=HC0ft_jy6SgAX-QHJum&_nc_ht=scontent.fhan2-3.fna&oh=d36c864fb06d7e3e141e639a490ffdd9&oe=5FACA302", urlVideo: null)
  ];

  @override
  _PostMoreDetailScreenState createState() => _PostMoreDetailScreenState();
}

class _PostMoreDetailScreenState extends State<PostMoreDetailScreen> {
  Post post;
  List<MediaUrl> listMedia = List();
  bool isLiked;
  UserViewModel _userViewModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    post = ModalRoute.of(context).settings.arguments;
    listMedia = _getListMedia(post);
    isLiked = post.isLiked;

    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop();
        return;
      },
      child: Scaffold(
          body: _getBody(),
      ),
    );
  }

  Widget _getBody(){
    return ListView(
      padding: EdgeInsets.all(0),
      children: <Widget>[
        Container(height: MediaQuery.of(context).padding.top, color: Colors.transparent,),
        PostWidgetHelper.getPostHeader(context, post, _onTapAvatar, _onTapUserName, _onPressMore),
        PostWidgetHelper.getContentPost(context, post, false),
        (post.numOfLike > 0 || post.numOfComment > 0) ? PostWidgetHelper.getInfoPost(context, post, _onPressComment, false, user: _userViewModel.user) : Container(width: 0, height: 0,),
        Container(padding: EdgeInsets.symmetric(horizontal: 20),child: Divider(thickness: 1, height: 0.5,)),
        PostWidgetHelper.getActions(context, post, _onPressLike, _onPressComment, _onPressShare, _userViewModel.user),
        Divider(thickness: 1, height: 2,),
        MediaHelper.columnMediaFromUrlWidget(context, listMedia)
      ],
    );
  }

  void _onTapAvatar(){

  }

  void _onTapUserName(){

  }

  void _onPressMore() {
  }

  void _onPressComment() async {
    await BottomSheetHelper.showCommentsPost(context , post);
    setState(() {
    });
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

  void _onPressShare(){

  }

  List<MediaUrl> _getListMedia(Post post){
    if (post == null) return List();
    List<MediaUrl> listMedia = List();
    if (post.images != null){
      post.images.forEach((element) {
        listMedia.add(MediaUrl(isImage: true, urlImage: element.url, urlVideo: null));
      });
    }
    if (post.videos != null){
      post.videos.forEach((element) {
        listMedia.add(MediaUrl(isImage: false, urlImage: element.thumb, urlVideo: element.urlVideo));
      });
    }
    return listMedia;
  }
}
