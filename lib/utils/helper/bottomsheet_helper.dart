import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_screen/comment_screen.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';

import 'package:fake_app/utils/constants/custom_enum.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants_strings.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';

class BottomSheetHelper {
  static showMoreActionPost(BuildContext context,
      Function _onTapReport, Function _onTapUnFollow) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapReport,
                  leading: Icon(
                    Icons.report_problem,
                    size: sizeIcon,
                  ),
                  title: Text(ConstString.report,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.normal, fontSize: sizeFont)),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
                ListTile(
                  onTap: _onTapUnFollow,
                  leading: Icon(
                    Icons.event_busy,
                    size: sizeIcon,
                  ),
                  title: Text(
                    ConstString.unfollow,
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.normal, fontSize: sizeFont),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          );
        });
  }

  static Future<dynamic> showMoreActionPostAuthor(BuildContext context) async {
    void onTapEditPost(){
      //Navigator.of(context).pop(BottomSheetCode.ON_EDIT_POST);
      Navigator.of(context).pop(1);
    }
    void onTapDeletePost(){
      //Navigator.of(context).pop(BottomSheetCode.ON_DELETE_POST);
      Navigator.of(context).pop(2);
    }
    return await showModalBottomSheet<int>(
      context: context,
      builder: (context){
        return Wrap(
          children: [
            getListTileImage(context, "images/icon_save_post.png", HexColor(ConstColor.color_white), ConstString.post_save, (){}),
            getListTileImage(context, "images/icon_edit.png", HexColor(ConstColor.color_white), ConstString.post_edit, onTapEditPost),
            getListTileImage(context, "images/icon_delete.png", HexColor(ConstColor.color_white), ConstString.post_delete, onTapDeletePost),
            getListTileImage(context, "images/icon_copy_link.png", HexColor(ConstColor.color_white), ConstString.post_copy_link, (){})
          ],
        );
      }
    );
  }

  static showCommentsPost(BuildContext context, Post post) async {
    return showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        builder: (BuildContext context) {
          return CommentScreen(
            post: post,
          );
        },
      );
  }

  static showActionPost(
      BuildContext context, Function onInsertImages, Function onInsertVideo, Function onInsertEmotion) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              Container(
                child: Center(child: Icon(Icons.keyboard_arrow_up)),
              ),
              Divider(
                height: 1,
              ),
              getListTile(
                  context,
                  Icons.video_call,
                  HexColor(ConstColor.color_video_call),
                  ConstString.video_call,
                  onInsertVideo),
              Divider(
                height: 1,
              ),
              getListTile(
                  context,
                  Icons.image,
                  HexColor(ConstColor.color_image),
                  ConstString.image_video,
                  onInsertImages),
              Divider(height: 1),
              getListTile(
                  context,
                  Icons.person_add,
                  HexColor(ConstColor.color_friend),
                  ConstString.tag_friend,
                  () {}),
              Divider(
                height: 1,
              ),
              getListTile(
                  context,
                  Icons.insert_emoticon,
                  HexColor(ConstColor.color_emotion),
                  ConstString.emotion,
                  onInsertEmotion)
            ],
          );
        });
  }

  static showPostWarningBack(BuildContext context) async {

    void onTapDelete(){
      Navigator.of(context).pop(Constant.code_throw_post);
    }

    void onTapContinueEdit(){
      Navigator.of(context).pop(Constant.code_continue_edit_post);
    }

    return await showModalBottomSheet(
      context: context,
      builder: (context){
        return Wrap(
          children: [
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        ConstString.warning_title_exit_post_screen,
                        style: Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 16.5,),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 3, left: 10, bottom: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        ConstString.warning_subtitle_exti_post_screen,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(ConstColor.text_color_grey)),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                    child: getListTile(context, Icons.restore_from_trash, HexColor(ConstColor.text_color_grey), ConstString.throw_post, onTapDelete)),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 0),
                    child: getListTile(context, Icons.check, HexColor(ConstColor.azure), ConstString.continue_edit, onTapContinueEdit))
              ],
            ),
          ],
        );
      }
    );
  }

  static showActionBoxChat(BuildContext context) async {
    void onTapDelete() {
      Navigator.of(context).pop(BottomSheetCode.ON_DELETE_BOXCHAT);
    }
    void onTapBlock() {
      Navigator.of(context).pop(BottomSheetCode.ON_BLOCK);
    }
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: <Widget>[
              getListTile(context, Icons.delete, HexColor(ConstColor.black),
                  ConstString.post_delete, onTapDelete),
              getListTile(context, Icons.block, HexColor(ConstColor.black),
                  ConstString.block, onTapBlock),
            ],
          );
        }
    );
  }

  static showActionAvatar(BuildContext context, Function _imgFromGalleryAvatar) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: HexColor(ConstColor.grey_fake_transparent),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.14,
                ),
              ),
              getListTileAvatar(context, Icons.filter_frames, Colors.black, ConstString.add_frames, (){}),
              getListTileAvatar(context, Icons.videocam, Colors.black, ConstString.new_avatar_video_recording, (){}),
              getListTileAvatar(context, Icons.ondemand_video_outlined, Colors.black, ConstString.select_avatar_video, (){}),
              getListTileAvatar(context, Icons.image_rounded, Colors.black, ConstString.select_avatar_photo, _imgFromGalleryAvatar),
              getListTileAvatar(context, Icons.person_pin_outlined, Colors.black, ConstString.see_avatar_photo, (){}),
              getListTileAvatar(context, Icons.account_box_outlined, Colors.black, ConstString.set_avatar_as_your_avatar, (){}),
            ],
          ) ;
        });
  }

  static showActionBackgroud(BuildContext context, Function _imgFromGalleryBackground) {
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Container(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    color: HexColor(ConstColor.grey_fake_transparent),
                  ),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  height: 6,
                  width: MediaQuery.of(context).size.width * 0.14,
                ),
              ),
              getListTileAvatar(context, Icons.filter_frames, Colors.black, ConstString.see_backgroud, (){}),
              getListTileAvatar(context, Icons.videocam, Colors.black, ConstString.upload_photo, _imgFromGalleryBackground),
              getListTileAvatar(context, Icons.ondemand_video_outlined, Colors.black, ConstString.select_photo_in_facebook, (){}),
              getListTileAvatar(context, Icons.image_rounded, Colors.black, ConstString.create_group_backgroud, (){}),
              getListTileAvatar(context, Icons.person_pin_outlined, Colors.black, ConstString.select_photo_art, (){}),
            ],
          ) ;
        });
  }

  static Widget getListTile(BuildContext context, IconData icon, Color color,
      String title, Function onTap) {
    final double sizeIcon = 26;
    final double sizeFont = 16.5;
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        size: sizeIcon,
        color: color,
      ),
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.normal, fontSize: sizeFont)),
    );
  }

  static Widget getListTileAvatar(BuildContext context, IconData icon, Color color,
      String title, Function onTap) {
    final double sizeIcon = 26;
    final double sizeFont = 20;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(10),
        child: CircleAvatar(
          radius: MediaQuery.of(context).size.width * 0.05,
          backgroundColor: HexColor(ConstColor.grey_fake_transparent),
          child: Icon(
            icon,
            size: sizeIcon,
            color: color,
          ),
        ),
      ),

      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.w700, fontSize: sizeFont)),
    );
  }

  static Widget getListTileImage(BuildContext context, String image, Color color,
      String title, Function onTap) {
    final double sizeIcon = 22;
    final double sizeFont = 16.5;
    return ListTile(
      onTap: onTap,
      leading: Image.asset(
        image,
        width: sizeIcon,
        height: sizeIcon,
      ),
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(fontWeight: FontWeight.normal, fontSize: sizeFont)),
    );
  }

  static showActionAccept(BuildContext context,
      Function _onTapAccept, Function _onTapReject) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapAccept,
                  leading: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: sizeIcon,
                  ),
                  title: Text("Chấp nhận",
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.normal, fontSize: sizeFont)),
                ),
                ListTile(
                  onTap: _onTapReject,
                  leading: Icon(
                    Icons.clear,
                    size: sizeIcon,
                  ),
                  title: Text(
                    "Từ chối",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.normal, fontSize: sizeFont),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static showActionRequest(BuildContext context,
      Function _onTapRequestFriend) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapRequestFriend,
                  leading: Icon(
                    Icons.clear,
                    size: sizeIcon,
                  ),
                  title: Text(
                    "Hủy yêu cầu kết bạn",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.normal, fontSize: sizeFont),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static showActionFriend(BuildContext context,
      Function _onTapDiscardFriend) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapDiscardFriend,
                  leading: Icon(
                    Icons.person_remove_alt_1_outlined,
                    size: sizeIcon,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Hủy kết bạn",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w500, fontSize: sizeFont, color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static showActionMore(BuildContext context,
      Function _onTapBlock) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapBlock,
                  leading: Icon(
                    Icons.block_outlined,
                    size: sizeIcon,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Chặn",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w500, fontSize: sizeFont, color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        });
  }

  static showActionMoreAccount(BuildContext context,
      Function _onTapGetListBlocks) {
    final double sizeIcon = 28;
    final double sizeFont = 17;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  onTap: _onTapGetListBlocks,
                  leading: Icon(
                    Icons.block,
                    size: sizeIcon,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Danh sách chặn",
                    style: Theme.of(context).textTheme.bodyText1.copyWith(
                        fontWeight: FontWeight.w500, fontSize: sizeFont),
                  ),
                ),
              ],
            ),
          );
        });
  }

}
