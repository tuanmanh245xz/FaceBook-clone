import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/messenger/boxchat_screen.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/mess_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchMessScreen extends StatefulWidget {
  static String route = '/search_mess';
  @override
  _SearchMessScreenState createState() => _SearchMessScreenState();
}

class _SearchMessScreenState extends State<SearchMessScreen> {
  TextEditingController _tfController;
  ScrollController _scrollController;
  MessengerViewModel _messVm;
  List<Friend> _listFriend = List();
  List<Friend> _listHistorySearchMess = List();
  bool isShowSuggest = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfController = TextEditingController();
    _scrollController = ScrollController();
    _messVm = Provider.of<MessengerViewModel>(context, listen: false);
    _listHistorySearchMess = _messVm.historySearchMess;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tfController.dispose();
    _scrollController.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
      backgroundColor: Colors.white,
    );
  }

  AppBar _getAppBar(){
    return AppBar(
      title: Container(
          height: 40,
          child: _getTextFieldSearch()),
    );
  }

  Widget _getTextFieldSearch(){
    return TextField(
      controller: _tfController,
      onChanged: (value) => _onPressChange(value),
      onSubmitted: (value) => _onPressSearch(value),
      decoration: _getInputDecoration(),
    );
  }


  InputDecoration _getInputDecoration() {
    return InputDecoration(
        hintText: 'Tìm kiếm',
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
            borderRadius: BorderRadius.circular(20)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        fillColor: HexColor(ConstColor.grey_fake_transparent),
        filled: true
    );
  }

  Widget _getBody() {
    if(isShowSuggest){
      _listFriend = _messVm.friends;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _listHistorySearchMess.length > 0 ? Container(
              padding: EdgeInsets.fromLTRB(13, 10, 5, 5),
              child: Text(
                ConstString.recently_search,
                style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16, color: HexColor(ConstColor.text_color_grey), fontWeight: FontWeight.normal),
              )
          ) : Container(),
          _listHistorySearchMess.length > 0 ? Container(
            height: _listHistorySearchMess.length > 4 ? 180 : 100,
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(10),
              crossAxisSpacing: 2,
              mainAxisSpacing: 10,
              crossAxisCount: 4,
              children: _listHistorySearchMess.map((e) => Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: (){
                      _onForwardToBoxChat(e);
                    },
                    child: Constant.getAvatar(urlImage: e.avatar, sizeAvatar: 26)
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Center(
                      child: Text(e.username.split(' ').first,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontSize: 15, fontWeight: FontWeight.normal)),
                    ),
                  )
                ],
              )).toList(),
            )
          ) : Container(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _listFriend.length + 1,
              itemBuilder: (context, index){
                if(index == 0){
                  return Container(
                    padding: EdgeInsets.fromLTRB(13, 10, 13, 5),
                    child: Text(
                      ConstString.suggest,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                  );
                }
                index--;
                return ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  onTap: () {
                    _onForwardToBoxChat(_listFriend[index]);
                  },
                  leading: Constant.getAvatar(
                      urlImage: _listFriend[index].avatar, sizeAvatar: 20),
                  title: Text(_listFriend[index].username,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
                );
              },
            ),
          )
        ],
      );
    }
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _listFriend.length,
      itemBuilder: (context, index){
        if(_listFriend.length == 0){
          return Center(
            child: Text(
              ConstString.no_result_search,
              style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 17)
            ),
          );
        }
        return ListTile(
          contentPadding:
          EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          onTap: () {
            _onForwardToBoxChat(_listFriend[index]);
          },
          leading: Constant.getAvatar(
              urlImage: _listFriend[index].avatar, sizeAvatar: 20),
          title: Text(_listFriend[index].username,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(fontSize: 16, fontWeight: FontWeight.normal)),
        );
      },
    );
  }

  _onPressChange(String value) {
    if(value != null && value.length > 0){
      setState(() {
        isShowSuggest = false;
        List<Friend> resultFindFriends = _messVm.friends.where((element) => element.username.toLowerCase().contains(value.toLowerCase())).toList();
        _listFriend = resultFindFriends;
      });
    }else{
      setState(() {
        isShowSuggest = true;
      });
    }
  }

  _onSaveHistorySearch(Friend friend) async {
    _listHistorySearchMess.removeWhere((element) => element.id == friend.id);
    _listHistorySearchMess.insert(0, friend);
    SharedPreferencesHelper.instance.setHistoryMess(_listHistorySearchMess.getRange(0, _listHistorySearchMess.length > 6 ? 6 : _listHistorySearchMess.length).toList());
  }

  _onForwardToBoxChat(Friend friend){
    // Save history search
    _onSaveHistorySearch(friend);
    //
    String conversationId = _messVm.getConversationId(friend.id);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => BoxChatScreen(partner: ShortUser(id: friend.id, name: friend.username,
                avatar: friend.avatar))
        )
    );
  }

  _onPressSearch(String value) {}
}
