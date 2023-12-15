

import 'package:fake_app/screens/custom_screen/login_again_screen.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:flutter/cupertino.dart';

class ResponseHelper {
  ResponseHelper._privateConstructor();
  static final ResponseHelper _instance = ResponseHelper._privateConstructor();
  static ResponseHelper get instance => _instance;

  checkResponseError(BuildContext context, int code){
   switch(code){
     case ConstantCodeMessage.TOKEN_INVALID:
        DialogHelper.showDialogErrorAction(context, ConstString.error_token_title, ConstString.error_token_content);
        Navigator.of(context).popAndPushNamed(LoginAgain.route);
        break;
     default:
       break;
   }
  }
}