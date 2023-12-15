import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import 'color_helper.dart';
import 'convert_helper.dart';

class PostWidgetHelper {

  static Widget loadImageWidget = Container(
    color: HexColor(ConstColor.color_grey),
    height: 350,
    child: Center(
        child: CircularProgressIndicator()),
  );

  static Widget getContentPost(BuildContext context, Post post, bool onBlack){
    if(post.described == null || post.described.length == 0)
      return Container();
    return Container(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: 10),
      color: onBlack ? Color.fromARGB(100, 0, 0, 0) : HexColor(ConstColor.color_white),
      child: Row(
        children: [
          Expanded(
              child: ReadMoreText(
                post.described,
                trimLines: 5,
                trimMode: TrimMode.Line,
                trimCollapsedText: "...Xem thêm",
                trimExpandedText: "...Thu gọn",
                colorClickableText: onBlack ? HexColor(ConstColor.color_white) : HexColor(ConstColor.black),
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16, color: onBlack ? HexColor(ConstColor.color_white) : HexColor(ConstColor.black)),
              )
          ),
        ],
      ),
    );
  }

  static Widget getPostHeader(BuildContext context, Post post, Function _onTapAvatar, Function _onTapUserName, _onPressMore){

    // We will get image for state in here
    int index = Constant.list_emotion_mean.indexWhere((element) => element == post.state);

    // return Ink(
    //   color: HexColor(ConstColor.color_white),
    //   child: ListTile(
    //     contentPadding: EdgeInsets.symmetric(horizontal: 10),
    //     leading: GestureDetector(
    //       onTap: _onTapAvatar,
    //       child: (post.author.avatar.length > 0) ? CircleAvatar(
    //         backgroundImage: CachedNetworkImageProvider(post.author.avatar) ,
    //         backgroundColor: HexColor(ConstColor.color_grey),
    //       ) : CircleAvatar(
    //         child: CircleAvatar(
    //           child: Icon(Icons.person),
    //           radius: 20,
    //           backgroundColor: HexColor(ConstColor.color_white),
    //         ),
    //         backgroundColor: HexColor(ConstColor.color_grey),
    //         radius: 22,
    //       ),

    return Ink(
      color: HexColor(ConstColor.color_white),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10),
        leading: GestureDetector(
          onTap: _onTapAvatar,
          child: (post.author.avatar.length > 0)
              ? CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(post.author.avatar) ,
            backgroundColor: HexColor(ConstColor.grey_fake_transparent),
          )
              : CircleAvatar(
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage("images/user_grey.png"),
              backgroundColor: HexColor(ConstColor.grey_fake_transparent),
            ),
            backgroundColor: HexColor(ConstColor.color_grey),
            radius: 22,
          ),

        ),
        title: GestureDetector(
          onTap: _onTapUserName,
          child: RichText(
            text: TextSpan(
                text: post.author.name,
                style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 16.5),
                children: [
                  (index > 0) ? WidgetSpan(
                      child: Container(
                        margin: EdgeInsets.only(left: 4),
                        child: Image.asset(
                          "images/" + Constant.list_emotion[index] + ".png",
                          width: 17,
                          height: 17,
                        ),
                      )
                  ) : TextSpan(),
                  TextSpan(
                      text: " " + post.state + " ",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 16.5)
                  ),
                ]
            ),
          ),
        ),
        subtitle: Text(
          ConvertHelper.covertDateTimeToStringShow(post.created),
          style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 14),
        ),
        trailing: IconButton(
          onPressed: _onPressMore,
          icon: Icon(Icons.more_horiz),
        ),
      ),
    );
  }

  static Widget getPostHeaderBlack(BuildContext context, Post post, Function _onTapName){
    return GestureDetector(
      onTap: _onTapName,
      child: Container(
        color: Color.fromARGB(100, 0, 0, 0),
        padding: EdgeInsets.only(top: 8, bottom: 4),
        child: Row(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 4),
                child: Text(
                  post.author.name,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: HexColor(ConstColor.color_white), fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget getImages(BuildContext context, Post post) {
    if(post.state == "đã cập nhật ảnh đại diện"){
      return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.width * 0.9,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.grey[400], spreadRadius: 1)
              ],
            ),
            child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.395,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(post.images.first.url),
                  backgroundColor: HexColor(ConstColor.grey_fake_transparent),
                  radius: MediaQuery.of(context).size.width * 0.38,
                )
            ),
          ),
        )
      );
    } else if (post.state == "đã cập nhật ảnh bìa"){
      return Container(
        height: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          color: HexColor(ConstColor.grey_fake_transparent),
          image: DecorationImage(
            image: NetworkImage(post.images.first.url),
              fit: BoxFit.cover
          )
        ),
      );
    } else {
      return Container();
    }
  }

  static Widget getAvatarImage(BuildContext context, Post post) {
    return Container(
      child: CachedNetworkImage(
        imageUrl: post.images.first.url,
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => loadImageWidget,
      ),
    );
  }

  static Widget getInfoPost(BuildContext context, Post post, Function _onPressComment, bool onBlack, {User user}) {
    final double sizeIcon = 16;
    final double sizeFont = 14;
    String likeString = "";
    if (post.isLiked && post.numOfLike == 1){
      likeString = user.name;
    } else if (post.isLiked && post.numOfLike > 1){
      likeString = user.name + " và " + (post.numOfLike - 1).toString() + " người khác";
    } else {
      likeString = post.numOfLike.toString() + " người khác";
    }
    return Container(
      height: 35,
      color: onBlack ? Color.fromARGB(100, 0, 0, 0) : HexColor(ConstColor.color_white),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        onTap: _onPressComment,
        leading: Column(
          children: [
            (post.numOfLike != 0) ? Wrap(
              children: <Widget>[
                Image.asset("images/icon_liked.png", width: sizeIcon, height: sizeIcon,),
                Container(width: 4,),
                Text(
                  likeString,
                  style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: sizeFont, color: onBlack ? HexColor(ConstColor.color_white) : HexColor(ConstColor.black)),
                )
              ],
            ) : Container(width: 10,),
          ],
        ),
        trailing: post.numOfComment > 0 ? Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Wrap(
              children: <Widget>[
                Text(
                  post.numOfComment.toString() + " bình luận",
                  style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: sizeFont, color: onBlack ? HexColor(ConstColor.color_white) : HexColor(ConstColor.black)),
                )
              ],
            ),
          ],
        ) : null,
      ),
    );
  }

  static Widget getActions(BuildContext context, Post post, Function _onPressLike, Function _onPressComment, _onPressShare, User user){
    return Container(
      height: 40,
      child: Row(
        children: <Widget>[
          Expanded(
              child: post.isLiked ?
              _getButtonAction(context, "Thích", "images/icon_liked2.png", _onPressLike) :
              _getButtonAction(context, "Thích", "images/icon_like.png", _onPressLike)
          ),
          Expanded(
              child: _getButtonAction(context, "Bình luận", "images/icon_comment.png", _onPressComment)
          ),
          (post.author.id != user.id) ? Expanded(
            child: _getButtonAction(context, "Chia sẻ", "images/icon_share.png", _onPressShare),
          ) : Container(width: 0,height: 0,),
        ],
      ),
    );
  }

  static Widget getActionsBlack(BuildContext context, Post post, Function _onPressLike, Function _onPressComment, _onPressShare){
    return Container(
      height: 50,
      color: HexColor(ConstColor.black),
      child: Row(
        children: <Widget>[
          Expanded(
              child: post.isLiked ?
              _getButtonActionBlack(context, "Thích", "images/icon_liked2.png", _onPressLike) :
              _getButtonActionBlack(context, "Thích", "images/icon_like_on_dark.png", _onPressLike)
          ),
          Expanded(
              child: _getButtonActionBlack(context, "Bình luận", "images/icon_comment_on_dark.png", _onPressComment)
          ),
          Expanded(
            child: _getButtonActionBlack(context, "Chia sẻ", "images/icon_share.png", _onPressShare),
          ),
        ],
      ),
    );
  }

  static Widget _getButtonAction(BuildContext context, String tooltip, String imageIcon, Function onPress){
    return RaisedButton(
      onPressed: onPress,
      color: HexColor(ConstColor.color_white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
      ),
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imageIcon, width: 20, height: 20,),
              Container(width: 8,),
              Flexible(
                child: Container(
                  child: Text(
                    tooltip,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13,),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  static Widget _getButtonActionBlack(BuildContext context, String tooltip, String imageIcon, Function onPress){
    return RaisedButton(
      onPressed: onPress,
      color: HexColor(ConstColor.black),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imageIcon, width: 20, height: 20,),
              Container(width: 8,),
              Text(
                tooltip,
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13, color: HexColor(ConstColor.color_white), fontWeight: FontWeight.bold),
              )
            ],
          ),
        ],
      ),
    );
  }
}