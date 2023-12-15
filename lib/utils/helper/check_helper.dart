

import 'package:flutter/cupertino.dart';

class CheckHelper {
  static bool isValidParameterSignUp(String phoneNumber, String password){
    if (phoneNumber.isNotEmpty && password.isNotEmpty){
      // Check phoneNumber
      if (phoneNumber == null || (phoneNumber.length != 10 && phoneNumber.length != 11) || !isInteger(phoneNumber)) return false;
      if (password == null || password.length == 0) return false;
      //
      return true;
    }
    return false;
  }

  static bool isValidPhoneNumber(String phoneNumber){
    if (phoneNumber == null || phoneNumber.length != 10 || phoneNumber[0] != '0' || !isInteger(phoneNumber)) return false;
    return true;
  }

  static bool isInteger(String s){
    if (s == null){
      return false;
    }
    return int.parse(s, onError: (source) => null) != null;
  }

  static bool isValidPassword(String password){
    if (password == null || password.length < 6 || password.length > 10) return false;
    return true;
  }
}