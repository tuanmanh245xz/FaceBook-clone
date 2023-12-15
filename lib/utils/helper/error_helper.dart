import 'package:fake_app/models/post.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:provider/provider.dart';
import 'dialog_helper.dart';

class ErrorHelper {
  ErrorHelper._privateConstructor();
  static final ErrorHelper _instance = ErrorHelper._privateConstructor();
  static ErrorHelper get instance => _instance;

  void errorTokenInValid(BuildContext context) async {
        await DialogHelper.showDialogErrorAction(context, ConstString.token_invalid_title, ConstString.token_invalid_content);
        Constant.onLogOut(context);
  }

  void errorActionHasBeenDone(BuildContext context, Post post) async {
      // Bai viet bi khoa
      await DialogHelper.showDialogErrorAction(context, ConstString.post_is_not_existed, ConstString.post_is_not_existed_content);
      Provider.of<PostViewModel>(context, listen: false).removePost(post);
      Navigator.of(context).pop();
  }

  void errorUserIsNotValidate(BuildContext context) async {
      await DialogHelper.showDialogErrorAction(context, ConstString.account_is_block, ConstString.account_is_block_content);
      Constant.onLogOut(context);
  }

  void errorPostIsNotExist(BuildContext context, Post post) async {
      await DialogHelper.showDialogErrorAction(context, ConstString.post_is_not_existed, ConstString.post_is_not_existed_content);
      Provider.of<PostViewModel>(context, listen: false).removePost(post);
      Navigator.of(context).pop();
  }

  void errorNotAccess(BuildContext context, Post post) async {
    // Bi chan boi author
      Provider.of<PostViewModel>(context, listen: false).removePost(post);
      Navigator.of(context).pop();
  }

  void errorParamNotValid(BuildContext context) async {
    Navigator.of(context).pop();
  }
}