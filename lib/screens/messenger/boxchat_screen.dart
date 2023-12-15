import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:fake_app/models/messenger.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/screens/messenger/messenger_screen.dart';
import 'package:fake_app/utils/constants/config.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/constants/custom_enum.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:fake_app/view_models/mess_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BoxChatScreen extends StatefulWidget {
  static String route = "/boxchat";

  BoxChatScreen({this.partner});

  final ShortUser partner;
  @override
  _BoxChatScreenState createState() => _BoxChatScreenState();
}

class _BoxChatScreenState extends State<BoxChatScreen> {
  MessengerViewModel _messViewModel;
  UserViewModel _userViewModel;
  TextEditingController _tfMessControl;
  ScrollController _scrollController;
  FocusNode _myFocusNode;
  bool _isShowEmojiPicker = false;
  bool _isShowOption = true;
  bool _isShowLoadingMoreMess = false;
  int index = 0;
  List<String> _listAction = ["View profile", "Video call", "Video chat"];
  List<Message> _listMessage = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfMessControl = TextEditingController();
    _scrollController = ScrollController();
    _myFocusNode = FocusNode();
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _messViewModel = Provider.of<MessengerViewModel>(context, listen: false);
    _initScroll();
    _initConversation();
  }

  void _initConversation() async {
    // Fetch a range of list message of conversation
    if(_messViewModel.socketIO == null){
      _messViewModel.initSocket();
    }
    _messViewModel.joinChat(_userViewModel.user.id, widget.partner.id);

    if(_messViewModel.boxChats.containsKey(widget.partner.id) && _messViewModel.boxChats[widget.partner.id].listMess.length > 0){
    }else{
      _messViewModel.boxChats[widget.partner.id].index = 0;
      _messViewModel.fetchConversation(context, _userViewModel.user.token, widget.partner.id);
    }

  }

  void _initScroll(){
    _scrollController.addListener(() {
      onLoadingMoreMess();
    });
  }

  void onLoadingMoreMess() async {
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && _isShowLoadingMoreMess == false) {
      setState(() {
        _isShowLoadingMoreMess = true;
      });
      if (_messViewModel != null) {
        await _messViewModel.fetchConversation(
            context, _userViewModel.user.token, widget.partner.id);

        setState(() {
          _isShowLoadingMoreMess = false;
        });
      }
    }
  }

  void _scrollViewToBottom(){
    _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tfMessControl.dispose();
    _myFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 35,
        leading: Container(
          margin: EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            }
          ),
        ),
        title: Row(
          children: [
            Constant.getAvatar(urlImage: widget.partner.avatar, sizeAvatar: 18),
            Container(
              margin: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.partner.name,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ConstString.online,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13.5, color: HexColor(ConstColor.text_color_grey)),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.phone, color: HexColor(ConstColor.azure),),
            onPressed: (){
            },
          ),
          IconButton(
            icon: Icon(Icons.video_call_outlined, color: HexColor(ConstColor.azure), size: 30,),
            onPressed: (){
            },
          ),
          IconButton(
            icon: Icon(Icons.info_rounded, color: HexColor(ConstColor.azure),),
            onPressed: (){
            },
          ),
        ],
      ),
      body: _getBody(),
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: false,
    );
  }

  Widget _getBody(){
    _messViewModel.setReadMessage(_userViewModel.user.token, widget.partner.id);
    return Column(
      children: <Widget>[
        Expanded(
            child: Consumer<MessengerViewModel>(
              builder: (context, messVm, child){
                if(widget.partner != null && messVm.boxChats.containsKey(widget.partner.id))
                 _listMessage = messVm.boxChats[widget.partner.id].listMess.toList();
                else _listMessage = List();
                // _listMessage = [Message(message: 'abc', sender: ShortUser(id: 'abcdcee', avatar: PostWidget.defaultImage)), Message(message: 'bd', sender: ShortUser(id: 'abcdcee', avatar: PostWidget.defaultImage))];
                return ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: _listMessage.length + 1,
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  reverse: true,
                  itemBuilder: (context, index){
                    if(index == _listMessage.length){
                      return _isShowLoadingMoreMess ? Center(
                        child: Constant.getDefaultCircularProgressIndicator(15)
                      ) : Container();
                    }
                    if(_listMessage.length == 0){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            ConstString.chat_title,
                            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 17, color: HexColor(ConstColor.text_color_grey)),
                          ),
                          Container(height: 8,),
                          Text(
                            ConstString.chat_content,
                            style: Theme.of(context).textTheme.bodyText2.copyWith(color: HexColor(ConstColor.text_color_grey)),
                          )
                        ],
                      );
                    }
                    if(_listMessage[index].sender.id != widget.partner.id){
                      return Row(
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                              child: SizedBox()
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 6, right: 8, top: 2, bottom: 2),
                                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: HexColor(ConstColor.color_icon_azure)
                                    ),
                                    child: Text(
                                      _listMessage[index].message,
                                      style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.color_white)),
                                    ),
                                  ),
                                ),
                              )
                          )
                        ],
                      );
                    }
                    bool isShowAvatar = true;
                    if(index - 1 >= 0){
                      if(_listMessage[index-1].sender.id != _listMessage[index].sender.id){
                        isShowAvatar = true;
                      }else{
                        isShowAvatar = false;
                      }
                    }

                    return Row(
                      children: <Widget>[
                        Expanded(
                            flex: 4,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: isShowAvatar ? Container(
                                      margin: EdgeInsets.only(top: 2, bottom: 2, right: 6, left: 6),
                                      child: Constant.getAvatar(urlImage: widget.partner.avatar, sizeAvatar: 16)
                                  ) : Container()
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 8, right: 6, top: 2, bottom: 2),
                                        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: HexColor(ConstColor.color_icon_azure)
                                        ),
                                        child: Text(
                                          _listMessage[index].message,
                                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 16, color: HexColor(ConstColor.color_white)),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                        ),
                        Expanded(
                            flex: 2,
                            child: SizedBox()
                        ),
                      ],
                    );
                  },
                );
              }
            )
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: _getBottomSheet()
        )
      ],
    );
  }

  Widget _getBottomSheet() {
    double iconSize = 26;

    return Container(
      height: 50,
      child: Container(
        margin: EdgeInsets.only(left: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _isShowOption ? IconButton(
              padding: EdgeInsets.all(0),
              iconSize: iconSize,
              icon: Icon(Icons.camera_alt_rounded),
              color: HexColor(ConstColor.color_icon_azure),
              onPressed: (){},
              constraints: BoxConstraints(
                minWidth: 40
              ),
            ): Container(),
            _isShowOption ? IconButton(
              padding: EdgeInsets.all(0),
              iconSize: iconSize,
              icon: Icon(Icons.image),
              color: HexColor(ConstColor.color_icon_azure),
              onPressed: (){},
              constraints: BoxConstraints(
                  minWidth: 40
              ),
            ) : Container(),
            _isShowOption ? IconButton(
              padding: EdgeInsets.all(0),
              iconSize: iconSize,
              icon: Icon(Icons.mic_rounded),
              color: HexColor(ConstColor.color_icon_azure),
              onPressed: (){},
              constraints: BoxConstraints(
                  minWidth: 40
              ),
            ) : Container(),
            _isShowOption ? Container() :
            IconButton(
              padding: EdgeInsets.all(0),
              iconSize: iconSize,
              icon: Icon(Icons.arrow_forward_ios_rounded),
              color: HexColor(ConstColor.color_icon_azure),
              onPressed: (){
                setState(() {
                  _isShowOption = true;
                });
              },
              constraints: BoxConstraints(
                  minWidth: 40
              ),
            ),
            Expanded(
              child: Container(
                height: 35,
                child: Stack(
                  children: [
                    TextField(
                        controller: _tfMessControl,
                        focusNode: _myFocusNode,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        onChanged: (value) => onChangeComment(value),
                        onSubmitted: (value) => _onPressSendMess(),
                        decoration: _getInputDecoration(),
                        onTap : (){
                          setState(() {
                            _isShowOption = false;
                          });
                        }
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: _onTapInsertEmoji,
                        child: Container(
                          margin: EdgeInsets.only(right: 3),
                          child: Icon(Icons.insert_emoticon, color: HexColor(ConstColor.color_icon_azure), size: 28)
                        ),
                      )
                    )
                  ],
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.all(0),
              iconSize: iconSize,
              icon: Icon(Icons.send),
              color: HexColor(ConstColor.color_icon_azure),
              onPressed: _onSendMessage,
              constraints: BoxConstraints(
                  minWidth: 40
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
        hintText: 'Aa',
        contentPadding: EdgeInsets.only(left: 10, right: 40),
        border: OutlineInputBorder(
            borderSide: BorderSide(
                width: 0,
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(22)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        fillColor: HexColor(ConstColor.grey_fake_transparent),
        filled: true
    );
  }

  onChangeComment(String value) {}

  _onPressSendMess() {}

  void _onTapInsertEmoji() {
  }

  void _onSendMessage() async {
    if(_tfMessControl.text != null && _tfMessControl.text.length > 0){
      // Hien thi message tren boxchat
      setState(() {
        String message = _tfMessControl.text.trim();

        _messViewModel.addSendMessageToConversation(widget.partner.id, Message(message: message, unread: false,
            sender: ShortUser(id: _userViewModel.user.id, name: _userViewModel.user.name, avatar: _userViewModel.user.link_avatar)));
        var result = _messViewModel.sendMessage(message, _userViewModel.user.id, widget.partner.id);
        _messViewModel.setReadMessage(_userViewModel.user.token, widget.partner.id);
        _messViewModel.cachedConversation(widget.partner.id);
        _scrollViewToBottom();
        _tfMessControl.text = "";
        _isShowOption = true;
      });
    }
  }
}
