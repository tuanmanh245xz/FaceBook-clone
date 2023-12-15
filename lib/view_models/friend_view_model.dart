
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class FriendViewModel extends ChangeNotifier {
  static const DEFAULT_COUNT_FRIEND = 10;
  final List<Friend> listFriend = List();
  int index = 0;

  void reset(){
    listFriend.clear();
    index = 0;
  }

  Future<void> fetchListFriend(BuildContext context, String token, String userId,  int index, {count = DEFAULT_COUNT_FRIEND}) async {
    var response = await FakeBookService().get_user_friends(token, userId, index, count);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          List<Friend> listFriend = (response['data']["friends"] as List).map((accept) => Friend.fromJson(accept)).toList();
          print(response['data']["friends"]);
          this.replaceAllWith(listFriend);
          SharedPreferencesHelper.instance.setListFriend(this.listFriend);
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
  //   listFriend.add(post);
  //   notifyListeners();
  // }

  // void addListPostTail(List<Post> posts){
  //   listFriend.addAll(posts);
  //   notifyListeners();
  // }


  //
  // void addListPostHead(List<Post> posts){
  //   listFriend.insertAll(0, posts);
  //   notifyListeners();
  // }
  //
  // void addPostHead(Post post){
  //   listFriend.insert(0, post);
  //   notifyListeners();
  // }
  //
  void replaceAllWith(List<Friend> friend){
    listFriend.clear();
    listFriend.addAll(friend);
    notifyListeners();
  }
//
// void removePost(Post post){
//   listFriend.removeWhere((_post){
//     return _post.idPost == post.idPost;
//   });
//   notifyListeners();
// }
}