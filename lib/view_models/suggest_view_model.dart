
import 'package:fake_app/models/suggest.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class SuggestViewModel extends ChangeNotifier {
  static const DEFAULT_COUNT_SUGGEST = 20;
  final List<Suggest> listSuggest = List();
  int index = 0;

  void reset(){
    listSuggest.clear();
    index = 0;
  }

  Future<void> fetchListSuggest(BuildContext context, String token, int index, {count = DEFAULT_COUNT_SUGGEST}) async {
    var response = await FakeBookService().get_list_suggested_friends(token, index, count);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          List<Suggest> listSuggest = (response['data']["list_users"] as List).map((suggest) => Suggest.fromJson(suggest)).toList();
          this.replaceAllWith(listSuggest);
          SharedPreferencesHelper.instance.setListSuggest(this.listSuggest);
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
  //   listSuggest.add(post);
  //   notifyListeners();
  // }

  // void addListPostTail(List<Post> posts){
  //   listSuggest.addAll(posts);
  //   notifyListeners();
  // }


  //
  // void addListPostHead(List<Post> posts){
  //   listSuggest.insertAll(0, posts);
  //   notifyListeners();
  // }
  //
  // void addPostHead(Post post){
  //   listSuggest.insert(0, post);
  //   notifyListeners();
  // }
  //
  void replaceAllWith(List<Suggest> suggest){
    listSuggest.clear();
    listSuggest.addAll(suggest);
    notifyListeners();
  }
//
// void removePost(Post post){
//   listSuggest.removeWhere((_post){
//     return _post.idPost == post.idPost;
//   });
//   notifyListeners();
// }
}