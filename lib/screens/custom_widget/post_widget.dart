import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_screen/image_screen.dart';
import 'package:fake_app/screens/custom_screen/post_detail_more_screen.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:fake_app/screens/custom_screen/report_screen.dart';
import 'package:fake_app/screens/custom_screen/video_screen.dart';
import 'package:fake_app/screens/custom_widget/list_post_widget.dart';
import 'package:fake_app/screens/home_pages/watch_page.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';

import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/constants/custom_enum.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/media_helper.dart';
import 'package:fake_app/utils/helper/post_helper.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class PostWidget extends StatefulWidget {
  static String defaultImage = "https://sieupet.com/sites/default/files/pictures/images/gia-cho-shiba-inu-02.jpg";
  static String defaultTimeStamp = "21 phút trước";
  static String defaultUserName = "Shiba Inu";
  static String defaultString = "🧭 Est ut pede magna dolor ultrices. Tempor magnam sociosqu. Aenean lacus sapien. Sociis adipiscing tincidunt urna quis libero maecenas odio amet eget enim rutrum ut scelerisque at in sodales nunc. Lacus in vestibulum condimentum phasellus erat ornare metus quisque. Donec duis at. Sapien vehicula eget cursus est sit amet vestibulum fringilla. Ut adipiscing sollicitudin aliquet leo erat. Suspendisse vel ipsum. Sed parturient aliquam sociis lorem wisi neque metus auctor in per quis. Molestie ut quis imperdiet luctus pharetra. Conubia neque molestie. At risus mauris. Accumsan pede vestibulum. Justo parturient leo.";
  static int defaultNumberLiked = 100;
  static int defaultNumberComment = 99;
  static bool isLiked = false;
  static String id;

  final Post post;

  PostWidget({this.post});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  UserViewModel _userViewModel;
  List<Media> _listMedia;
  Widget loadImageWidget = Container(
    color: HexColor(ConstColor.color_grey),
    height: 350,
    child: Center(
        child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    List<Media> listMedia;
    if (_listMedia == null) listMedia = getListMedia();
    else listMedia = _listMedia;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PostWidgetHelper.getPostHeader(context, widget.post, _onTapAvatar, _onTapUserName, _onPressMore),
        PostWidgetHelper.getContentPost(context, widget.post, false),
        (listMedia.length != null && listMedia.isNotEmpty && (widget.post.state == "đã cập nhật ảnh đại diện" || widget.post.state == "đã cập nhật ảnh bìa"))
            ? GestureDetector(
                onTap: _onTapSeeDetail,
                child: PostWidgetHelper.getImages(context, widget.post)
              )
            : GestureDetector(
                onTap: _onTapSeeDetail,
                child: MediaHelper.getMediaWidget(context, listMedia),
              ),
        (widget.post.numOfLike != 0 || widget.post.numOfComment != 0) ? PostWidgetHelper.getInfoPost(context, widget.post, _onPressComment, false, user: _userViewModel.user) : Container(),
        //PostWidgetHelper.getImages(context,widget.post),
        Container(padding: EdgeInsets.symmetric(horizontal: 20),child: Divider(thickness: 0.5, height: 1,)),
        PostWidgetHelper.getActions(context, widget.post, _onPressLike, _onPressComment, _onPressShare, _userViewModel.user),
        Container(
          height: 10,
          color: HexColor(ConstColor.color_grey)
        )
      ],
    );
  }

  _onTapUserName(){
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = widget.post.author.id;
    user.name = widget.post.author.name;
    user.link_avatar = widget.post.author.avatar;
    user.password = '';
    user.token = '';
    _user.setUser(user);
    Navigator.pushNamed(
        context,
        PersonalPage.route,
        arguments: _user
    );
  }

  _onTapAvatar(){
    User user = new User();
    UserViewModel _user = new UserViewModel();
    user.id = widget.post.author.id;
    user.name = widget.post.author.name;
    user.link_avatar = widget.post.author.avatar;
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
    if (_userViewModel.user.id == widget.post.author.id){
      var result = await BottomSheetHelper.showMoreActionPostAuthor(context);
      print(result == 2);
      if (result != null){
        switch(result){
          case 2:
            print('Enter here');
            _onTapDelete();
            break;
          case 1:
            _onTapEdit();
            break;
          default:
            break;
        }
      }
    } else {
      BottomSheetHelper.showMoreActionPost(context, _onTapReport, _onTapUnFollow);
    }
  }


  void _onPressComment() async {
    await BottomSheetHelper.showCommentsPost(context , widget.post);
    setState(() {
    });
  }

  void _onClosingBottomSheet(){
   setState(() {

   });
  }

  void _onSubmitCmt(String content){

  }

  void _onPressShare() {
  }

  void _onPressLike() async {
    setState(() {
      if (widget.post.isLiked)
        widget.post.numOfLike -= 1;
      else
        widget.post.numOfLike += 1;
      widget.post.isLiked = !widget.post.isLiked;
    });
    bool ok = await _userViewModel.likePost(widget.post);
    setState(() {
      if (ok){
        // Do nothing
      } else {
        // Return state
        if (widget.post.isLiked){
          widget.post.numOfLike -= 1;
        } else {
          widget.post.numOfLike +=1;
        }
        widget.post.isLiked = ! widget.post.isLiked;
      }
    });
  }


  void _onTapEdit() async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => PostScreen(post: widget.post,))
    );
    if(result != null){
      setState(() {
        _listMedia = result as List<Media>;
      });
    }else{
      // Need change in here;
    }
  }

  void _onTapDelete() async {
    var actionCode = await DialogHelper.showDialogConfirmThreeButton(context, ConstString.post_delete_title, ConstString.post_delete_content, ConstString.delete_cap, ConstString.edit_cap, ConstString.cancel_cap);
    switch(actionCode){
      case DialogCode.ON_CANCEL:
        return;
      case DialogCode.ON_DELETE_POST:
        break;
      case DialogCode.ON_EDIT_POST:
        _onTapEdit();
        return;
      default:
        return;
    }
    Provider.of<PostViewModel>(context, listen: false).removePost(widget.post);
   // PostViewModel().listPost.re
    var response = await _userViewModel.deletePost(widget.post.idPost);
    int code = int.parse(response['code']);
    if (code == 100){ // Do nothing
    }
  }

  void _onTapReport() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportScreen(post: widget.post)));
  }

  void _onTapUnFollow() {
  }

  void _onTapSeeDetail(){
    List<Media> listMedia = getListMedia();
    if (listMedia.length != 0){
      if (listMedia.length == 1){
        if (listMedia.first.isImage){
          Navigator.of(context)
              .pushNamed(ImageScreen.route, arguments: widget.post);
        } else {
          Navigator.of(context)
              .pushNamed(VideoScreen.route,
              // arguments: listMedia.first
            arguments: {"post": widget.post, "media": listMedia.first}
          );
        }
      } else {
        Navigator.of(context)
            .pushNamed(PostMoreDetailScreen.route, arguments: widget.post);
      }
    }
  }

  List<Media> getListMedia(){
    List<MediaUrl> listMedia = List();
    if (widget.post.images != null)
      widget.post.images.forEach((element) {
        listMedia.add(MediaUrl(isImage: true, urlImage: element.url, urlVideo: null));
      });
    if (widget.post.videos != null)
      widget.post.videos.forEach((element) {
        listMedia.add(MediaUrl(isImage: false, urlImage: element.thumb, urlVideo: element.urlVideo));
      });
    return listMedia;
  }
}


