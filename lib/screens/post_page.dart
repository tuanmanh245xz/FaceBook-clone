import 'dart:convert';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:fake_app/models/comment.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'dart:async';
import 'package:fake_app/screens/custom_screen/image_screen.dart';
import 'package:fake_app/screens/custom_screen/post_detail_more_screen.dart';
import 'package:fake_app/screens/custom_screen/video_screen.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';

import 'package:fake_app/service/fakebook_service.dart';
import 'package:shimmer/shimmer.dart';

import 'custom_widget/circle_button.dart';
import 'package:fake_app/utils/helper/media_helper.dart';
import 'package:fake_app/utils/helper/post_helper.dart';

class PostPage extends StatefulWidget {
  static String route = "/postpage";
  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage>{
  Post post;
  String post_id ;
  UserViewModel _userViewModel;
  List<Media> _listMedia;
  List<Comment> comments = List();
  Future<List<Comment>> futureComments;
  int index = 0;
  bool loadingPost = false;

  final double sizeFont = 14;
  final double sizeIcon = 16;
  final double sizeLIcon = 22;
  static int numberCommnet = 10;
  static int numberLike = 10;
  FocusNode myFocusNode;

  final ScrollController scrollController = ScrollController();
  final TextEditingController tdCommentControl = TextEditingController();
  static const int DEFAULT_COUNT_COMMENT = 5;
  static Widget loadingWidget = Center(
    child: Container(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        backgroundColor: HexColor(ConstColor.color_grey),
      ),
    ),
  );
  bool canComment = false;
  bool isShowEmojiPicker = false;

  bool isLoadMoreTop = false;
  bool onRefreshLoadComment = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    scrollController.addListener(() {
      print(scrollController.position);
    });
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    Future.delayed(Duration(milliseconds: 1)).then((_) {
      _getPost();
    });
  }

  void  _getPost()  async {
    post_id = ModalRoute.of(context).settings.arguments;
    final UserViewModel _userModel = Provider.of<UserViewModel>(context, listen: false);
     FakeBookService().get_post(_userModel.user.token, post_id).then((res){
      if (res != null) {
        setState(() {
          if (res["code"] == "1000") {
            post = Post.fromJson(res["data"]);
            FakeBookService().get_comment(_userModel.user.token, post.idPost, 0, 10).then((resComment){
              if (resComment["code"] == "1000") {
                setState(() {
                  comments = (resComment['data'] as List).map((comment) => Comment.fromJson(comment)).toList();
                  print(resComment);
                });
              }
            });
          }
          if(res["code"] == "9992"){
            loadingPost = true;
          }
        });
      }  else {
        DialogHelper.showDialogNoInternet(context);
      }


     });
  }

  // @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myFocusNode.dispose();
    scrollController.dispose();
  }

  Widget build(BuildContext context) {

    List<Widget> children = [];
    children.add(_emptySpace(6));
    children.add(_postWidget(post));
    children.add(_getListComment());
    //children.add(_getCommentWidget());
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Row(
            children: <Widget>[
              (post != null )
                  ? Text(
                post.author.name,
                style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 20),
              )
                  : Shimmer.fromColors(
                      child: Container(
                        height: 30,
                        color: Colors.blue,
                      ) ,
                      baseColor: Colors.grey[200],
                      highlightColor: Colors.grey[100]),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CircleButton(
                    iconData: Icons.search,
                    sizeIcon: 50,
                    onTap: (){},
                    backgroundColor: HexColor(ConstColor.grey_fake_transparent),
                  ),
                ),
              )
            ],
          ),
      ),
      body: SingleChildScrollView(
        child:  Column(
            mainAxisSize: MainAxisSize.min,
            //children: children,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 1.0-160 ,
                child: ListView(
                  shrinkWrap: true,
                  children: children,
                ),
              ),
              _getCommentWidget(),
              isShowEmojiPicker ? _getEmojiPicker() : Container()
            ]
        ),
      ),
      //bottomSheet: _getCommentWidget(),
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

  Widget _postWidget(Post post) {
    if  (post != null ) {
      List<Media> listMedia;
      if (_listMedia == null) listMedia = getListMedia();
      else listMedia = _listMedia;
      _userViewModel = Provider.of<UserViewModel>(context, listen: false);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          PostWidgetHelper.getPostHeader(context,post, _onTapAvatar, _onTapUserName, _onPressMore),
          PostWidgetHelper.getContentPost(context, post, false),
          //(post.state !=  "đã cập nhật ảnh đại diện")?PostWidgetHelper.getContentPost(context,post, false):Container(),
          (listMedia.length != null && listMedia.isNotEmpty && post.state != "đã cập nhật ảnh đại diện")
              ? GestureDetector(
              onTap: _onTapSeeDetail,
              child: MediaHelper.getMediaWidget(context, listMedia)
          )
              : GestureDetector(
              onTap: _onTapSeeDetail,
              child: PostWidgetHelper.getImages(context,post),
          ),

          Container(padding: EdgeInsets.symmetric(horizontal: 10),child: Divider(thickness: 1, height: 1,)),
          PostWidgetHelper.getActions(context,post, _onPressLike, _onPressComment, _onPressShare, _userViewModel.user),
          Container(padding: EdgeInsets.symmetric(horizontal: 0),child: Divider(thickness: 1, height: 1,)),
          (post.numOfLike != 0 ||post.numOfComment != 0) ? PostWidgetHelper.getInfoPost(context,post, _onPressComment, false, user: _userViewModel.user) : Container(),

          // Container(
          //     height: 10,
          //     color: HexColor(ConstColor.color_grey)
          // )
        ],
      );
    } else if(loadingPost == true) {
      return Container(
        margin: EdgeInsets.only(top: 200),
        padding: EdgeInsets.all(20),
        height: 400,
        child: Center(
            child: Column(
              children: [
                Text(
                  "Bài viết không tồn tại",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            )
        ),
      );
    } else {
      return Shimmer.fromColors(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                leading: GestureDetector(
                  onTap: (){},
                  child:  CircleAvatar(
                    child: CircleAvatar(
                      child: Icon(Icons.person),
                      radius: 20,
                      backgroundColor: HexColor(ConstColor.color_white),
                    ),
                    backgroundColor: HexColor(ConstColor.color_grey),
                    radius: 22,
                  ),
                ),
                title: Container(
                  height: 15,
                  color:  Colors.blue,
                  margin: EdgeInsets.only(bottom: 5),
                ),
                subtitle:  Container(
                  height: 15,
                  color:  Colors.blue,
                ),
                trailing: IconButton(
                  onPressed: _onPressMore,
                  icon: Icon(Icons.more_horiz),
                ),
              )
            ],
          ),
          baseColor: Colors.grey[200],
          highlightColor: Colors.grey[100]);
    }

  }

  Widget _getListComment() {
    if (comments != null) {
      return Container(
        //height: 500,
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: comments.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 5, top: 5, right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: (comments[index].user.avatar != null && comments[index].user.avatar.length > 0)  ? CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  comments[index].user.avatar
                              ),
                              radius: 20,
                            ) : Constant.defaultAvatar,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: HexColor(ConstColor.grey_fake_transparent),
                                borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 4),
                                  child: Text(
                                      comments[index].user.name,
                                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15.5)
                                  ),
                                ),
                                Text(
                                  comments[index].content,
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 15.4),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 2, left: 8),
                              child: Text(
                                  ConvertHelper.convertDateTimeToStringComment(comments[index].date),
                                  style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(ConstColor.text_color_grey), fontSize: 14.5, fontWeight: FontWeight.w500)
                              )
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _getCommentWidget() {
    if (post != null){
      return Container(
        height: 55,
        decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: Theme.of(context).dividerColor
                )
            )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: IconButton(
                onPressed: () {},
                icon: Icon(
                    Icons.camera_alt,
                    size: 28,
                    color: HexColor(ConstColor.color_grey)
                ),
              ),
            ),
            Expanded(
                flex: 9,
                child: Container(
                  padding: EdgeInsets.only(bottom: 8, right: 0, top: 4, left: 0),
                  child: Stack(
                    children: [
                      TextField(
                          focusNode: myFocusNode,
                          controller: tdCommentControl,
                          onChanged: (value) => onChangeComment(value),
                          onSubmitted: (value) => _onPressSendComment(),
                          decoration: _getInputDecoration(),
                          onTap : (){
                            if (isShowEmojiPicker){
                              setState(() {
                                isShowEmojiPicker = false;
                              });
                            }
                          }
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          onPressed: _onTapInsertEmoji,
                          icon: Icon(Icons.insert_emoticon, color: HexColor(ConstColor.color_grey)), iconSize: 28,),
                      )
                    ],
                  ),
                )
            ),
            Expanded(
              flex: 2,
              child: IconButton(
                icon: Icon(Icons.send, size: 28),
                onPressed: _onPressSendComment,
                iconSize: sizeLIcon,
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _getEmojiPicker(){
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      recommendKeywords: ["racing", "horse"],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        tdCommentControl.text = tdCommentControl.text + emoji.emoji;
      },
    );
  }

  void _onTapReport() {
  }

  void _onTapUnFollow() {
  }

  _onTapUserName(){
  }

  _onTapAvatar(){}


  void _onPressShare() {
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
    await BottomSheetHelper.showCommentsPost(context , post);
    setState(() {
    });
  }

  void _onPressMore() async {
    if (_userViewModel.user.id == post.author.id){
      var result = await BottomSheetHelper.showMoreActionPostAuthor(context);
      print(result == 2);
      if (result != null){
        switch(result){
          case 2:
            print('Enter here');
            (){};
            break;
          case 1:
            (){};
            break;
          default:
            break;
        }
      }
    } else {
      BottomSheetHelper.showMoreActionPost(context, _onTapReport, _onTapUnFollow);
    }
  }

  void _onTapSeeDetail(){
    List<Media> listMedia = getListMedia();
    if (listMedia.length != 0){
      if (listMedia.length == 1){
        if (listMedia.first.isImage){
          Navigator.of(context)
              .pushNamed(ImageScreen.route, arguments: post);
        } else {
          Navigator.of(context)
              .pushNamed(
              VideoScreen.route,
              arguments: {"post": post, "media": listMedia.first}
          );
        }
      } else {
        Navigator.of(context)
            .pushNamed(PostMoreDetailScreen.route, arguments: post);
      }
    }
  }


  List<Media> getListMedia(){
    List<MediaUrl> listMedia = List();
    if (post.images != null)
     post.images.forEach((element) {
        listMedia.add(MediaUrl(isImage: true, urlImage: element.url, urlVideo: null));
      });
    if (post.videos != null)
     post.videos.forEach((element) {
        listMedia.add(MediaUrl(isImage: false, urlImage: element.thumb, urlVideo: element.urlVideo));
      });
    return listMedia;
  }

  void _loadMoreComment() async {
    setState(() {
      isLoadMoreTop = true;
    });
    var response = FakeBookService().get_comment(_userViewModel.user.token, post.idPost, index, DEFAULT_COUNT_COMMENT);
    if (post.numOfComment > 0) {
      var response = await FakeBookService().get_comment(_userViewModel.user.token, post.idPost, index, DEFAULT_COUNT_COMMENT);
      if (response != null){
        switch(int.parse(response['code'])){
          case ConstantCodeMessage.OK:
            setState(() {
              comments.insertAll(0, (response['data'] as List).map((comment) => Comment.fromJson(comment)).toList());
              isLoadMoreTop = false;
            });
            break;
          case ConstantCodeMessage.TOKEN_INVALID:
            ErrorHelper.instance.errorTokenInValid(context);
            return;
          case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
            ErrorHelper.instance.errorActionHasBeenDone(context, post);
            return;
          case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
            ErrorHelper.instance.errorUserIsNotValidate(context);
            return;
          case ConstantCodeMessage.POST_IS_NOT_EXISTED:
            ErrorHelper.instance.errorPostIsNotExist(context, post);
            return;
          case ConstantCodeMessage.NOT_ACCESS:
            ErrorHelper.instance.errorNotAccess(context, post);
            return;
          default:
            break;
        }
      }
    }
  }

  onChangeComment(String value) {
    setState(() {
      if (value != null && value.length > 0){
        canComment = true;
      } else {
        canComment = false;
      }
    });
  }

  void _onPressSendComment() async {
    String comment = tdCommentControl.text;
    if (comment != null && comment.length > 0){
      comment = comment.trim();
      // Need change here
      setState(() {
        comments.add(
            Comment(
                content: comment,
                user: ShortUser(
                    id: _userViewModel.user.id,
                    name: _userViewModel.user.name,
                    avatar: _userViewModel.user.link_avatar
                ),
                date: DateTime.now()
            )
        );
        post.numOfComment += 1;
        index += 1;
        tdCommentControl.clear();
        canComment = false;
      });
      // Send comment to server
      var response = await FakeBookService().set_comment(_userViewModel.user.token, post.idPost, comment, index, DEFAULT_COUNT_COMMENT);
      if (response != null){
        if (int.parse(response['code']) == 1000){
          //List<Comment> comments = (response['data'] as List).map((comment) => Comment.fromJson(comment)).toList();
          // setState(() {
          //   this.comments.addAll(comments);
          // });
          // Keo xuong binh luan moi nhat
          // scrollController.animateTo(
          //     scrollController.position.maxScrollExtent,
          //     duration: Duration(milliseconds: 500),
          //     curve: Curves.fastOutSlowIn
          // );
        } else { // Loi
          setState(() {
            post.numOfComment -= 1;
            index -= 1;
            comments.removeLast();
          });
          // Can them o day xu ly cac truong hop khac
          switch(int.parse(response['code'])){
            case ConstantCodeMessage.TOKEN_INVALID:
              ErrorHelper.instance.errorTokenInValid(context);
              return;
            case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
              ErrorHelper.instance.errorActionHasBeenDone(context, post);
              return;
            case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
              ErrorHelper.instance.errorUserIsNotValidate(context);
              return;
            case ConstantCodeMessage.POST_IS_NOT_EXISTED:
              ErrorHelper.instance.errorPostIsNotExist(context, post);
              return;
            case ConstantCodeMessage.NOT_ACCESS:
              ErrorHelper.instance.errorNotAccess(context, post);
              return;
            default:
              break;
          }
        }
      } else {
        setState(() {
          post.numOfComment -= 1;
          index -= 1;
          comments.removeLast();
          DialogHelper.showDialogNoInternet(context);
        });
      }
    }
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
        hintText: 'Viết bình luận',
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
            borderRadius: BorderRadius.circular(20)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        fillColor: HexColor(ConstColor.grey_fake_transparent),
        filled: true
    );
  }

  void _onTapInsertEmoji() {
    setState(() {
      if (isShowEmojiPicker){
        myFocusNode.requestFocus();
        isShowEmojiPicker = false;
      } else {
        myFocusNode.unfocus();
        isShowEmojiPicker = true;
      }
    });
  }
}

