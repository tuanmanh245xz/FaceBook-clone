import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:fake_app/models/comment.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';

import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {

  CommentScreen({this.post});
  final Post post;

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final double sizeFont = 14;
  final double sizeIcon = 16;
  final double sizeLIcon = 22;
  static int numberCommnet = 10;
  static int numberLike = 10;
  FocusNode myFocusNode;

  static String defaultImage =
      "https://i.pinimg.com/originals/ae/41/25/ae41256e92b9538e32b87c33cc7ae591.jpg";
  static String defaultContent = "Jennie Kim. Bách khoa toàn thư mở Wikipedia.";
  List<Map<String, String>> dataComment = [
    {"avatar": defaultImage, "content": defaultContent},
    {"avatar": defaultImage, "content": defaultContent},
    {
      "avatar": defaultImage,
      "content":
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s"
    },
  ];
  final ScrollController scrollController = ScrollController();
  final TextEditingController tdCommentControl = TextEditingController();
  static const int DEFAULT_COUNT_COMMENT = 5;
  bool canComment = false;
  bool isShowEmojiPicker = false;
  UserViewModel _userViewModel;
  int index = 0;
  List<Comment> comments = List();
  Future<List<Comment>> futureComments;

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
    _getComments();
  }

  void _getComments() async {
    if (widget.post.numOfComment > 0) {
      var response = await FakeBookService().get_comment(_userViewModel.user.token, widget.post.idPost, index, DEFAULT_COUNT_COMMENT);
      if (response != null){
        switch(int.parse(response['code'])){
          case ConstantCodeMessage.OK:
            List<Comment> lists = List();
            lists = (response['data'] as List).map((comment) => Comment.fromJson(comment)).toList().reversed.toList();
            this.index += lists.length;
            print('LENGTH OF COMMENT: '  + lists.length.toString());
            setState(() {
              futureComments = Future.value(lists.reversed.toList());
            });
            break;
          case ConstantCodeMessage.TOKEN_INVALID:
            await DialogHelper.showDialogErrorAction(context, ConstString.token_invalid_title, ConstString.token_invalid_content);
            Constant.onLogOut(context);
            return;
          case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
            // Bai viet bi khoa
            await DialogHelper.showDialogErrorAction(context, ConstString.post_is_not_existed, ConstString.post_is_not_existed_content);
            Provider.of<PostViewModel>(context, listen: false).removePost(widget.post);
            Navigator.of(context).pop();
            return;
          case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
            await DialogHelper.showDialogErrorAction(context, ConstString.account_is_block, ConstString.account_is_block_content);
            Constant.onLogOut(context);
            return;
          case ConstantCodeMessage.POST_IS_NOT_EXISTED:
            await DialogHelper.showDialogErrorAction(context, ConstString.post_is_not_existed, ConstString.post_is_not_existed_content);
            Provider.of<PostViewModel>(context, listen: false).removePost(widget.post);
            Navigator.of(context).pop();
            return;
          case ConstantCodeMessage.NOT_ACCESS:
            Provider.of<PostViewModel>(context, listen: false).removePost(widget.post);
            Navigator.of(context).pop();
            return;
          default:
            break;
        }
      } else {
        setState(() {
          print('Enter here');
          futureComments = Future.value(null);
          onRefreshLoadComment = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    myFocusNode.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          children: <Widget>[
            _getHeader(),
            _getListComment(),
            _getCommentWidget(),
            isShowEmojiPicker ? _getEmojiPicker() : Container()
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      contentPadding: EdgeInsets.fromLTRB(10, 5, 38, 5),
      hintText: 'Viết bình luận',
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

  Widget _getHeader() {
    String likeString = "";
    if (widget.post.isLiked && widget.post.numOfLike == 1){
      likeString = _userViewModel.user.name;
    } else if (widget.post.isLiked && widget.post.numOfLike > 1){
      likeString = _userViewModel.user.name + " và " + (widget.post.numOfLike - 1).toString() + " người khác";
    } else {
      likeString = widget.post.numOfLike.toString() + " người khác";
    }
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: HexColor(ConstColor.color_grey),
            width: 0.5
          )
        )
      ),
      child: ListTile(
          onTap: _onPressLike,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (widget.post.numOfLike > 0) ? Wrap(
                children: [
                  Image.asset("images/icon_liked.png",
                      width: sizeIcon, height: sizeIcon),
                  Container(
                    width: 8,
                  ),
                  Text(
                    likeString,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontSize: sizeFont),
                  )
                ],
              ) : Container(width: 10, height: 10),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (widget.post.isLiked)
              ? Image.asset(
                "images/icon_liked2.png",
                width: sizeIcon,
                height: sizeIcon,
               )
              : Image.asset(
                "images/icon_like.png",
                width: sizeIcon,
                height: sizeIcon,
              ),
            ],
          )),
    );
  }

  Widget _getListComment() {
    return Expanded(
      flex: 7,
      child: FutureBuilder(
          future: futureComments,
          builder: (context, snapshot) {
            if (snapshot.hasData || this.comments.length != 0){
              if (snapshot.data != null) {
                this.comments = snapshot.data;
                index = this.comments.length;
              }else{
                index = this.comments.length;
              }

              return ListView.builder(
                controller: scrollController,
                itemCount: comments.length + 1,
                itemBuilder: (context, index){
                  if (index == 0) return (widget.post.numOfComment > this.index) ? (!isLoadMoreTop ? InkWell(
                      onTap: _loadMoreComment,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, bottom: 8, top: 12),
                        child: Text(
                            ConstString.see_more_comment,
                            style: Theme.of(context).textTheme.bodyText1
                        ),
                      )
                  ) : Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Center(
                        child: Constant.getDefaultCircularProgressIndicator(10)
                    ),
                  )) : Container();
                  index--;
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
                },
              );
            }

            // No comment in this post
            if (widget.post.numOfComment == 0){
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    ConstString.no_comment,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 17, color: HexColor(ConstColor.text_color_grey)),
                  ),
                  Container(height: 8,),
                  Text(
                    ConstString.be_first_one_comment,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(ConstColor.text_color_grey)),
                  )
                ],
              );
            } else {
              if (snapshot.connectionState == ConnectionState.done){
                return !onRefreshLoadComment ? GestureDetector(
                  onTap: () async {
                    _getComments();
                    setState(() {
                      onRefreshLoadComment = true;
                    });
                  },
                  child: Constant.getNoInternetWidget(context),
                ) : Center(
                  child: Constant.getDefaultCircularProgressIndicator(20),
                );
              }
              return Center(
                child: Constant.getDefaultCircularProgressIndicator(20),
              );
            }
          }
        ),
    );
  }

  Widget _getCommentWidget() {
    return Container(
      constraints: BoxConstraints(
        minHeight: 55,
      ),
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
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
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
        widget.post.numOfComment += 1;
        index += 1;
        tdCommentControl.clear();
        canComment = false;
      });
        // Send comment to server
      var response = await FakeBookService().set_comment(_userViewModel.user.token, widget.post.idPost, comment, index, DEFAULT_COUNT_COMMENT);
      if (response != null){
        if (int.parse(response['code']) == 1000){
          // Dung de load nhung binh luan moi nhat, nhung bi loi o server tra ve
          // List<Comment> comments = (response['data'] as List).map((comment) => Comment.fromJson(comment)).toList();
          // setState(() {
          //   this.comments.addAll(comments);
          // });
          // // Keo xuong binh luan moi nhat
          // scrollController.animateTo(
          //   scrollController.position.maxScrollExtent,
          //   duration: Duration(milliseconds: 500),
          //   curve: Curves.fastOutSlowIn
          // );
        } else { // Loi
          setState(() {
            widget.post.numOfComment -= 1;
            index -= 1;
            comments.removeLast();
          });
          // Can them o day xu ly cac truong hop khac
          switch(int.parse(response['code'])){
            case ConstantCodeMessage.TOKEN_INVALID:
              ErrorHelper.instance.errorTokenInValid(context);
              return;
            case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
              ErrorHelper.instance.errorActionHasBeenDone(context, widget.post);
              return;
            case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
              ErrorHelper.instance.errorUserIsNotValidate(context);
              return;
            case ConstantCodeMessage.POST_IS_NOT_EXISTED:
              ErrorHelper.instance.errorPostIsNotExist(context, widget.post);
              return;
            case ConstantCodeMessage.NOT_ACCESS:
              ErrorHelper.instance.errorNotAccess(context, widget.post);
              return;
            default:
              break;
          }
        }
      } else {
        setState(() {
          widget.post.numOfComment -= 1;
          index -= 1;
          comments.removeLast();
          DialogHelper.showDialogNoInternet(context);
        });
      }
    }
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

  onChangeComment(String value) {
    setState(() {
      if (value != null && value.length > 0){
        canComment = true;
      } else {
        canComment = false;
      }
    });
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

  void _loadMoreComment() async {
    setState(() {
      isLoadMoreTop = true;
    });
    if (widget.post.numOfComment > 0) {
      var response = await FakeBookService().get_comment(_userViewModel.user.token, widget.post.idPost, index, DEFAULT_COUNT_COMMENT);
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
            ErrorHelper.instance.errorActionHasBeenDone(context, widget.post);
            return;
          case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
            ErrorHelper.instance.errorUserIsNotValidate(context);
            return;
          case ConstantCodeMessage.POST_IS_NOT_EXISTED:
            ErrorHelper.instance.errorPostIsNotExist(context, widget.post);
            return;
          case ConstantCodeMessage.NOT_ACCESS:
            ErrorHelper.instance.errorNotAccess(context, widget.post);
            return;
          default:
            break;
        }
      }
    }
  }
}
