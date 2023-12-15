import 'package:fake_app/models/search.dart';
import 'package:fake_app/screens/search/result_search.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/helper/response_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  static String route = "search";

  SearchScreen({this.isSearchPersonalUser});

  final bool isSearchPersonalUser;
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const DEFAULT_COUNT_HISTORY_ITEM = 20;
  TextEditingController _tfController;
  bool isSearching = false;
  Future<List<KeyWord>> futureListKeyWord;
  List<KeyWord> listKeyWord;
  UserViewModel _userViewModel;
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfController = TextEditingController();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _getHistorySearch();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tfController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefreshHistorySearch,
        child: _getBody()
      ),
    );
  }

  AppBar _getAppBar(){
    return AppBar(
      title: Container(
          height: 40,
          child: _getTextFieldSearch()),
    );
  }

  Widget _getBody(){
    if(!isSearching){
      return FutureBuilder(
        future: futureListKeyWord,
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData){
            listKeyWord = snapshot.data;
            if(listKeyWord.length == 0){
              return Container(
                child: Center(
                  child: Text(
                    ConstString.no_history_search,
                    style: Theme.of(context).textTheme.headline6.copyWith(fontWeight: FontWeight.normal),
                  )
                ),
              );
            }
            return ListView.builder(
              itemCount: listKeyWord.length + 1,
              itemBuilder: (context, index){
                if(index == 0){
                  return Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: HexColor(ConstColor.color_grey)
                        )
                      )
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          ConstString.recently_search,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.5,),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              ConstString.edit_cap,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(color: HexColor(ConstColor.text_color_grey), fontSize: 16.5, fontWeight: FontWeight.w400),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
                index--;
                return Container(
                  height: 50,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    onTap: (){
                      _onTapKeyWord(listKeyWord[index].keyword);
                    },
                    leading: Icon(
                      Icons.search,
                      size: 24,
                    ),
                    title: Text(
                      listKeyWord[index].keyword,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 16.5),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.clear, size: 22,),
                      onPressed: () async {
                        _onPressDelHistorySearch(listKeyWord[index].id);
                      },
                    )
                  ),
                );
              },
            );
          }
          if(snapshot.connectionState == ConnectionState.done){
            return Constant.getNoInternetWidget(context);
          }
          return Center(child: Constant.getDefaultCircularProgressIndicator(24));
        },
      );
    }else{
      return Container();
    }
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

  _getHistorySearch() async {
    List<KeyWord> listKeyWord = await SharedPreferencesHelper.instance.getListHistorySearch();
    if(listKeyWord.length != 0){
      futureListKeyWord = Future.value(listKeyWord);
      return;
    }
    var data = await FakeBookService().get_save_search(_userViewModel.user.token, index, DEFAULT_COUNT_HISTORY_ITEM);
    if(data != null){
      switch(int.parse(data['code'])){
        case ConstantCodeMessage.OK:
          var _data = data['data'] as List;
          if(_data.length > 0)
            listKeyWord = (_data).map((kWord) => KeyWord.fromJson(kWord)).toList();
          setState(() {
            futureListKeyWord = Future.value(listKeyWord);
          });
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
          ErrorHelper.instance.errorUserIsNotValidate(context);
          return;
        default:
          break;
      }
    }
    setState(() {
      futureListKeyWord = Future.value(null);
    });
  }

  _onPressChange(String value) {
    // Do nothing
  }

  _onPressSearch(String value){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultSearchScreen(keyWord: value.trim(), isSearchPersonalUser: widget.isSearchPersonalUser,)
      )
    );
  }

  void _onTapKeyWord(String keyword) {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => ResultSearchScreen(keyWord: keyword, isSearchPersonalUser: widget.isSearchPersonalUser,)
        )
    );
  }

  void _onPressDelHistorySearch(String id) async {
    setState(() {
      listKeyWord.removeWhere((kWord) => kWord.id == id);
    });
    SharedPreferencesHelper.instance.setListHistorySearch(listKeyWord);
    var response = await FakeBookService().del_saved_search(_userViewModel.user.token, id, false);
    if (response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          // Do nothing in here
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
          ErrorHelper.instance.errorUserIsNotValidate(context);
          return;
      }
    }
  }

  Future<void> _onRefreshHistorySearch() async {
    var data = await FakeBookService().get_save_search(_userViewModel.user.token, 0, DEFAULT_COUNT_HISTORY_ITEM);
    if(data != null){
      switch(int.parse(data['code'])){
        case ConstantCodeMessage.OK:
          var _data = data['data'] as List;
          if(_data.length > 0)
            listKeyWord = (_data).map((kWord) => KeyWord.fromJson(kWord)).toList();
          setState(() {
            futureListKeyWord = Future.value(listKeyWord);
          });
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
          ErrorHelper.instance.errorUserIsNotValidate(context);
          return;
        default:
          break;
      }
    }
    setState(() {
      futureListKeyWord = Future.value(null);
    });
  }
}
