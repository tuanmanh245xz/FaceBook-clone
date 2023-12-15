
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class AcceptViewModel extends ChangeNotifier {
  static const DEFAULT_COUNT_ACCEPT = 10;
  final List<Friend> listAccept = List();
  int index = 0;

  void reset(){
    listAccept.clear();
    index = 0;
  }

  Future<void> fetchListAccept(BuildContext context, String token, int index, {count = DEFAULT_COUNT_ACCEPT}) async {
    var response = await FakeBookService().get_requested_friends(token, index, count);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          List<Friend> listAccept = (response['data']["request"] as List).map((accept) => Friend.fromJson(accept)).toList();
          this.replaceAllWith(listAccept);
          SharedPreferencesHelper.instance.setListAccept(this.listAccept);
          notifyListeners();
          break;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          break;
        case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
          ErrorHelper.instance.errorUserIsNotValidate(context);
          break;
        default:
          return null;
      }
    }
    return null;
  }

  // void addPostTail(Post post){
  //   listAccept.add(post);
  //   notifyListeners();
  // }

  // void addListPostTail(List<Post> posts){
  //   listAccept.addAll(posts);
  //   notifyListeners();
  // }


  //
  // void addListPostHead(List<Post> posts){
  //   listAccept.insertAll(0, posts);
  //   notifyListeners();
  // }
  //
  // void addPostHead(Post post){
  //   listAccept.insert(0, post);
  //   notifyListeners();
  // }
  //
  void replaceAllWith(List<Friend> accept){
    listAccept.clear();
    listAccept.addAll(accept);
    notifyListeners();
  }
//
// void removePost(Post post){
//   listAccept.removeWhere((_post){
//     return _post.idPost == post.idPost;
//   });
//   notifyListeners();
// }
}