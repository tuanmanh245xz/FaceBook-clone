import 'package:fake_app/models/notification.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class NotifyViewModel extends ChangeNotifier {
  static const DEFAULT_COUNT_NOTIFY = 15;
  final List<Notifications> listNotify = List();
  final ScrollController scrollController = ScrollController();

  int index = 0;

  void reset(){
    listNotify.clear();
    index = 0;
  }


  void scrollToTop(){
    if(scrollController.hasClients){
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    }
  }

  Future<void> fetchListNotify(BuildContext context, String token, int index,
      {count = DEFAULT_COUNT_NOTIFY}) async {
    var response = await FakeBookService().get_notification(
        token, index, count);
    if (response != null) {
      switch (int.parse(response['code'])) {
        case ConstantCodeMessage.OK:
          List<Notifications> listNotify = (response['data'] as List).map((
              noti) => Notifications.fromJson(noti)).toList();
          print(listNotify);
          this.replaceAllWith(listNotify);
          // this.listNotify.addAll(listNotify);
          SharedPreferencesHelper.instance.setListNotify(this.listNotify);
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

  void replaceAllWith(List<Notifications> notify) {
    listNotify.clear();
    listNotify.addAll(notify);
    notifyListeners();
  }
}