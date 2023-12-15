import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/messenger.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/messenger/boxchat_screen.dart';
import 'package:fake_app/screens/messenger/search_mess_screen.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/constants/custom_enum.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/convert_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/mess_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessengerScreen extends StatefulWidget {
  static String route = "/messenger";
  @override
  _MessengerScreenState createState() => _MessengerScreenState();
}

class _MessengerScreenState extends State<MessengerScreen> {
  UserViewModel _userViewModel;
  MessengerViewModel _messViewModel;
  User _user;
  TextEditingController tdSearchControl;
  ScrollController _scrollControllerConversation;
  ScrollController _scrollControllerListFriend;
  bool _isChat = true;
  bool _isShowLoadingMoreConversation = false;
  bool _isShowLoadingMoreFriend = false;
  bool _isLoadingConversation = false;
  bool _isLoadingFriends = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    tdSearchControl = TextEditingController();
    _initScroll();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _user = _userViewModel.user;
    _messViewModel = Provider.of<MessengerViewModel>(context, listen: false);
    _initListConversation();
    _initListFriend();
    _initHistory();
    _initRoomForFriend();
  }

  void _initRoomForFriend(){
    _messViewModel.joinChatAll(_userViewModel.user.id);
  }

  void _initScroll() async  {
    _scrollControllerConversation = ScrollController();
    _scrollControllerListFriend = ScrollController();

    _scrollControllerConversation.addListener(() {
      var maxScroll = _scrollControllerConversation.position.maxScrollExtent;
      if(_scrollControllerConversation.position.pixels >= maxScroll && _scrollControllerConversation.position.pixels > MediaQuery.of(context).size.height){
        setState(() {
          _isShowLoadingMoreConversation = true;
        });
        _onLoadMoreConversation();
      }
    });

    _scrollControllerListFriend.addListener(() {
      var maxScroll = _scrollControllerListFriend.position.maxScrollExtent;
      if(_scrollControllerListFriend.position.pixels >= maxScroll && _scrollControllerListFriend.position.pixels > MediaQuery.of(context).size.height){
        setState(() {
          _isShowLoadingMoreFriend = true;
        });
        _onLoadMoreFriend();
      }
    });
  }

  void _initListConversation() async {
    // List<Conversation> list =
    //     await SharedPreferencesHelper.instance.getListBoxChat();
    // int numNewMess = await SharedPreferencesHelper.instance.getNumNewMess();
    // if (list.length > 0) {
    //   _messViewModel.setListConversation(list);
    //   if(numNewMess != null)
    //     _messViewModel.numNewMess = numNewMess;
    //   else
    //     _messViewModel.numNewMess = 0;
    // } else {
    //   _messViewModel.fetchConversations(
    //       context, _userViewModel.user.token, _messViewModel.indexConversation);
    // }
    setState(() {
      _isLoadingConversation = true;
    });
    await _messViewModel.fetchConversations(
          context, _userViewModel.user.token, 0);
    setState(() {
      _isLoadingConversation = false;
    });
  }

  void _initListFriend() async {
    // List<Friend> list = await SharedPreferencesHelper.instance.getListFriend();
    // if(list.length > 0){
    //   _messViewModel.setListFriend(list);
    // }else{
    //   _messViewModel.fetchFriends(context, _userViewModel.user.token, _userViewModel.user.id, 0);
    // }
    setState(() {
      _isLoadingFriends = true;
    });
    await _messViewModel.fetchFriends(context, _userViewModel.user.token, _userViewModel.user.id, 0);
    setState(() {
      _isLoadingFriends = false;
    });
  }

  void _initHistory() async {
    List<Friend> history = await SharedPreferencesHelper.instance.getHistorySearchMess();
    _messViewModel.setHistorySearchMess(history);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    tdSearchControl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: (_user.link_avatar != null && _user.link_avatar.length > 0)
            ? Consumer<MessengerViewModel>(
          builder: (context, messVm, child){
            return Container(
              padding: EdgeInsets.all(8),
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 2),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage:
                      CachedNetworkImageProvider(_user.link_avatar),
                    ),
                  ),
                  (messVm.numNewMess != null && messVm.numNewMess > 0) ? Positioned(
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: HexColor(ConstColor.color_white),
                            borderRadius: BorderRadius.circular(10)
                        ),
                        constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18
                        ),
                        child: Container(
                            padding: EdgeInsets.all(1),
                            decoration: BoxDecoration(
                                color: HexColor(ConstColor.color_red),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            constraints: BoxConstraints(
                                minWidth: 16,
                                minHeight: 16
                            ),
                            child: Center(
                              child: Text(
                                messVm.numNewMess.toString(),
                                style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 10, color: HexColor(ConstColor.color_white), fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            )
                        ),
                      )
                  ) : Container()
                ],
              ),
            );
          },
        )
            : Constant.defaultAvatar,
        title: Text(
          _isChat ? ConstString.chat : ConstString.phonebook,
          style: Theme.of(context)
              .textTheme
              .headline5
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: HexColor(ConstColor.grey_fake_transparent),
            radius: 18.5,
            child: IconButton(
              padding: EdgeInsets.all(0),
              onPressed: _onPressSearch,
              icon: Icon(
                _isChat
                    ? Icons.camera_alt_rounded
                    : Icons.perm_contact_cal_sharp,
                size: 25,
                color: HexColor(ConstColor.black),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7),
            child: CircleAvatar(
              backgroundColor: HexColor(ConstColor.grey_fake_transparent),
              radius: 18.5,
              child: IconButton(
                  onPressed: _onBack,
                  icon: Icon(
                    _isChat ? Icons.arrow_back_rounded : Icons.arrow_back_rounded,
                    size: 25,
                    color: HexColor(ConstColor.black),
                  )),
            ),
          )
        ],
      ),
      body: _getBody(),
      bottomSheet: _getBottomSheet(),
    );
  }

  Widget _getBody() {
    if (_isChat) {
      return RefreshIndicator(
        onRefresh: _onRefreshConversations,
        child: Consumer<MessengerViewModel>(
        builder: (context, messVm, child){
          if (_isLoadingConversation){
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 60),
              controller: _scrollControllerConversation,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index){
                if(index == 0){
                  return Container(
                      height: 40,
                      margin:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pushNamed(
                              SearchMessScreen.route,
                            );
                          },
                          child: _getTextFieldSearch())
                  );
                }
                return Center(
                    child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Constant.getDefaultCircularProgressIndicator(30))
                );
              },
            );
          }
          if (messVm.conversations.length != 0){
            return ListView.builder(
              padding: EdgeInsets.only(bottom: 60),
              controller: _scrollControllerConversation,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: messVm.conversations.length + 2,
              itemBuilder: (context, index){
                if(index == 0){
                  return Container(
                      height: 40,
                      margin:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: GestureDetector(
                          onTap: (){
                            Navigator.of(context).pushNamed(
                              SearchMessScreen.route,
                            );
                          },
                          child: _getTextFieldSearch())
                  );
                }
                if(index == messVm.conversations.length + 1){
                  return _isShowLoadingMoreConversation ? Center( // For loading More post
                      child: Container(
                          padding: EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 4),
                          child: Constant.getDefaultCircularProgressIndicator(20)
                      )
                  ) : Container();
                }
                index--;
                return ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => BoxChatScreen(
                          partner: messVm.conversations[index].partner,
                        )));
                  },
                  onLongPress: () async {
                    BottomSheetCode code =
                    await BottomSheetHelper.showActionBoxChat(context);
                    print(code);
                  },
                  leading: Constant.getAvatar(
                      urlImage: messVm.conversations[index].partner.avatar,
                      sizeAvatar: 28),
                  title: Text(
                      messVm.conversations[index].partner.name,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.2, fontWeight: messVm.conversations[index].lastMessage.unread ? FontWeight.bold : FontWeight.normal)
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth: 200
                          ),
                          child: Text(
                            messVm.conversations[index].lastMessage.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: messVm.conversations[index].lastMessage.unread ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          constraints: BoxConstraints(
                              minWidth: 40
                          ),
                          child: Text(
                            " ",
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: messVm.conversations[index].lastMessage.unread ? FontWeight.bold : FontWeight.normal),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(bottom: 60),
            controller: _scrollControllerConversation,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index){
              if(index == 0){
                return Container(
                    height: 40,
                    margin:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: GestureDetector(
                        onTap: (){
                          Navigator.of(context).pushNamed(
                            SearchMessScreen.route,
                          );
                        },
                        child: _getTextFieldSearch())
                );
              }
             return Container(
               margin: EdgeInsets.only(top: 50),
               child: Column(
                 children: <Widget>[
                   Text(
                     ConstString.chat_title,
                     style: Theme.of(context).textTheme.headline6.copyWith(color: HexColor(ConstColor.text_color_grey))
                   ),
                   Container(
                     margin: EdgeInsets.only(top: 10),
                     child: Text(
                       ConstString.chat_no_conversation,
                       style: Theme.of(context).textTheme.bodyText1.copyWith(color: HexColor(ConstColor.text_color_grey))
                     ),
                   )
                 ],
               )
             );
            },
          );
        },
    ),
      );
    } else { // For friends
      return RefreshIndicator(
        onRefresh: _onRefreshListFriend,
        child: Consumer<MessengerViewModel>(
          builder: (context, messVm, child){
            if(_isLoadingFriends){
              return Center(
                child: Container(
                  margin: EdgeInsets.all(30),
                  child: Constant.getDefaultCircularProgressIndicator(30)
                )
              );
            }
            print('Friend Length: ' + messVm.friends.length.toString());
            return ListView.builder(
              controller: _scrollControllerListFriend,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: messVm.friends.length + 1,
              itemBuilder: (context, index){
                if(index == messVm.friends.length){
                  return _isShowLoadingMoreFriend ? Center( // For loading More post
                      child: Container(
                          padding: EdgeInsets.only(left: 40, right: 40, top: 4, bottom: 4),
                          child: Constant.getDefaultCircularProgressIndicator(20)
                      )
                  ) : Container();
                }
                return ListTile(
                  contentPadding:
                    EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  onTap: () {
                    print("Id:" + messVm.friends[index].id);
                    String conversationId = messVm.getConversationId(messVm.friends[index].id);
                    print(conversationId);

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BoxChatScreen(partner: ShortUser(id: messVm.friends[index].id, name: messVm.friends[index].username,
                            avatar: messVm.friends[index].avatar))
                      )
                    );
                  },
                  leading: Constant.getAvatar(
                      urlImage: messVm.friends[index].avatar, sizeAvatar: 24),
                  title: Text(messVm.friends[index].username,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 17)),
                );
              },
            );
          },
        ),
      );
    }
  }

  Widget _getBottomSheet() {
    return Container(
      height: 55,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: InkWell(
                onTap: _onTapChat,
                child: _getIconBtnText(
                    Icons.chat,
                    26,
                    HexColor(_isChat ? ConstColor.black : ConstColor.color_grey),
                    ConstString.chat)),
          ),
          Expanded(
              flex: 1,
              child: InkWell(
                  onTap: _onTapPhoneBook,
                  child: _getIconBtnText(
                      Icons.group,
                      26,
                      HexColor(
                          _isChat ? ConstColor.color_grey : ConstColor.black),
                      ConstString.phonebook)))
        ],
      ),
    );
  }

  Widget _getIconBtnText(
      IconData icon, double sizeIcon, HexColor colorIcon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          size: sizeIcon,
          color: colorIcon,
        ),
        Text(
          text,
          style:
              Theme.of(context).textTheme.bodyText1.copyWith(color: colorIcon),
        )
      ],
    );
  }

  Widget _getTextFieldSearch() {
    return TextField(
      controller: tdSearchControl,
      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.5),
      enabled: false,
      decoration: InputDecoration(
          hintText: "Tìm kiếm",
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 0, color: Colors.transparent),
              borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(width: 0, color: Colors.transparent)),
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: HexColor(ConstColor.grey_fake_transparent)),
    );
  }

  void _onPressSearch() {}

  void _onBack() {
    Navigator.of(context).pop();
  }

  void _onTapChat() {
    setState(() {
      _isChat = true;
    });
  }

  void _onTapPhoneBook() {
    setState(() {
      _isChat = false;
    });
  }

  Future<void> _onRefreshConversations() async {
    return await _messViewModel.fetchConversations(
        context, _user.token, 0);
  }

  Future<void> _onRefreshListFriend() async {
    return await _messViewModel.fetchFriends(context, _user.token, _user.id, 0);
  }

  void _onLoadMoreConversation() async {
    await _messViewModel.fetchConversations(context, _userViewModel.user.token, _messViewModel.indexConversation);
    setState(() {
      _isShowLoadingMoreConversation = false;
    });
  }

  void _onLoadMoreFriend() async {
    await _messViewModel.fetchFriends(context, _userViewModel.user.token, _userViewModel.user.id, _messViewModel.indexFriends);
    setState(() {
      _isShowLoadingMoreFriend = false;
    });
  }
}
