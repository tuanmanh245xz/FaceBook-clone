
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class PostViewModel extends ChangeNotifier {
  static const DEFAULT_COUNT_POST = 10;
  final List<Post> listPost = List();
  final List<Post> listPostPersonal = List();
  final List<Post> listPostVideo = List();
  final ScrollController scrollListPost = ScrollController();
  final ScrollController scrollListVideos = ScrollController();

  String lastId = "";
  int index = 0;
  bool isLoadingMorePost = false;
  int indexP = 0;
  String lastIdP = "";
  String lastIdVideo = "";
  bool isFetchingListPost = false;
  bool hasPosts = true;

  void reset(){
     lastId = "";
     index = 0;
     isLoadingMorePost = false;
     indexP = 0;
     lastIdP = "";
     lastIdVideo = "";
     isFetchingListPost = false;
     hasPosts = true;
     listPost.clear();
     listPostPersonal.clear();
     listPostVideo.clear();
  }

  Future<void> fetchListPost(BuildContext context, String token, String userId, int index, String lastId, {count = DEFAULT_COUNT_POST}) async {
    if(!isFetchingListPost){
      isFetchingListPost = true;
      var response = await FakeBookService().get_list_posts(token, userId, index, count, lastId);
      if (response != null){
        switch(int.parse(response['code'])){
          case ConstantCodeMessage.OK:
            try {
              List<Post> listPost = List();
              if(response['data'].toString().length != 0)
                listPost = (response['data']['posts'] as List).map((post) => Post.fromJson(post)).toList();
              if (lastId != null && lastId.length == 0){
                replaceAllWith(listPost);
              } else {
                addListPostTail(listPost);
              }
              if(response['data'].toString().length != 0)
                this.lastId = response['data']['last_id'];
              else this.lastId = null;

              this.index += this.index;
              SharedPreferencesHelper.instance.setListPost(this.listPost);
              SharedPreferencesHelper.instance.setLastIdPost(this.lastId);
              if(listPost.length == 0) hasPosts = false;
              else hasPosts = true;
              notifyListeners();
            }on Exception catch(e){
              print(e.toString());
            }
            break;
          case ConstantCodeMessage.TOKEN_INVALID:
            ErrorHelper.instance.errorTokenInValid(context);
            break;
          case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
            ErrorHelper.instance.errorUserIsNotValidate(context);
            break;
          default:
            break;
        }
        isFetchingListPost = false;
      }
    }
    return null;
  }

  Future<void> fetchListPostVideo(BuildContext context, String token, String userId, String lastIdVideo, {count = DEFAULT_COUNT_POST}) async {
    var response = await FakeBookService().get_list_videos(token, userId, count, lastIdVideo);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          List<Post> listPostVideo = (response['data']['posts'] as List).map((post) => Post.fromJson(post)).toList();
          if (lastIdVideo.length == 0){
            replaceAllVideoWith(listPostVideo);
          } else {
            addListPostVideoTail(listPostVideo);
          }
          this.lastIdVideo = response['data']['last_id'];
          SharedPreferencesHelper.instance.setListPostVideo(this.listPostVideo);
          SharedPreferencesHelper.instance.setLastIdPostVideo(this.lastIdVideo);
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

  Future<void> fetchListPostPersonal(BuildContext context, String token, String userId, int indexP, String lastIdP, {count = DEFAULT_COUNT_POST}) async {

    var response = await FakeBookService().get_list_posts(token, userId, indexP, count, lastIdP);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          if(response['data'].toString().length > 0){
            List<Post> listPost = (response['data']['posts'] as List).map((post) => Post.fromJson(post)).toList();
            if (lastIdP.length == 0){
              replaceAllWithP(listPost);
            } else {
              addListPostTailP(listPost);
            }
            this.lastIdP = response['data']['last_id'];
            this.indexP += indexP;
            SharedPreferencesHelper.instance.setListPostP(this.listPostPersonal);
            SharedPreferencesHelper.instance.setLastIdPostP(this.lastIdP);
            notifyListeners();
          }
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

  void addPostTail(Post post){
    listPost.add(post);
    notifyListeners();
  }

  void addListPostTail(List<Post> posts){
    listPost.addAll(posts);
    notifyListeners();
  }

  void addListPostVideoTail(List<Post> posts) {
    listPostVideo.addAll(posts);
    notifyListeners();
  }

  void addListPostTailP(List<Post> posts){
    listPostPersonal.addAll(posts);
    notifyListeners();
  }

  void addListPostHead(List<Post> posts){
    listPost.insertAll(0, posts);
    notifyListeners();
  }

  void addPostHead(Post post){
    listPost.insert(0, post);
    listPostPersonal.insert(0, post);
    notifyListeners();
  }

  void replaceAllWith(List<Post> posts){
    listPost.clear();
    listPost.addAll(posts);
    notifyListeners();
  }

  void replaceAllVideoWith(List<Post> posts) {
    listPostVideo.clear();
    listPostVideo.addAll(posts);
    notifyListeners();
  }

  void replaceAllWithP(List<Post> posts){
    print("oooo");
    listPostPersonal.clear();
    listPostPersonal.addAll(posts);
    notifyListeners();
  }

  void removePost(Post post){
    listPost.removeWhere((_post){
      return _post.idPost == post.idPost;
    });
    listPostPersonal.removeWhere((_post){
      return _post.idPost == post.idPost;
    });
    notifyListeners();
  }

  void scrollToTopPost() {
    if (scrollListPost != null && scrollListPost.hasClients) {
      scrollListPost.animateTo(
          scrollListPost.position.minScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn
      );
    }
  }

  void scrollToTopVideo() {
    if (scrollListVideos != null && scrollListVideos.hasClients) {
      scrollListVideos.animateTo(
          scrollListVideos.position.minScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn
      );
    }
  }
}