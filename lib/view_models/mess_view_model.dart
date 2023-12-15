import 'dart:collection';
import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/messenger.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/config.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/custom_enum.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessengerViewModel extends ChangeNotifier {

  final List<Conversation> conversations = List();
  final Map<String, BoxChat> boxChats = HashMap();
  final Map<String, String> mapFriendToRoom = HashMap();
  final List<Friend> friends = List();
  final List<Friend> historySearchMess = List();

  BuildContext context;
  SocketIOManager manager;
  SocketIO socketIO;

  int indexConversation = 0;
  int indexFriends = 0;
  int numNewMess = 0;

  MessengerViewModel(BuildContext context) {
    this.context = context;
    // Init socket to SocketServer Chat
    initSocket();
  }

  void initSocket() async {
    print('Init Socket');
    manager = SocketIOManager();
    socketIO = await manager.createInstance(SocketOptions(
        AppConfig.WEB_SOCKET_CHAT_URL,
        nameSpace: '/',
        enableLogging: false,
        transports: [Transports.POLLING, Transports.WEB_SOCKET]
    ));
    socketIO.onConnect((data) {
      print('Connected');
      print(data);
    });

    socketIO.onConnectError(_printData);
    socketIO.onConnectTimeout(_printData);
    socketIO.onError(_printData);
    socketIO.onDisconnect(_printData);
    socketIO.on('onmessage', (data) => _onMessage(data));
    socketIO.on('onJoinChat', (data) => _onJoinChat(data));
    socketIO.connect();
  }

  void joinChat(String accountId, String partnerId){
    try {
      socketIO.emit('joinchat', [{
        "account_id_1" : accountId,
        "account_id_2" : partnerId
      }]);
    } on Exception catch(e){
      print(e.toString());
    }
  }

  void joinChatAll(String accountId){
    friends.forEach((friend) {
      joinChat(accountId, friend.id);
    });
  }

  SendMessageCode sendMessage(String message, String accountId, String partnerId){
    try {
      socketIO.emit('send', [{
        "account_id_1" : accountId,
        "account_id_2" : partnerId,
        "message" : message
      }]);
      return SendMessageCode.ON_SUCCESSFULLY;
    } on Exception catch(e){
      print(e.toString());
    }
    return SendMessageCode.ON_FAIL;
  }

  void _onJoinChat(data){
    print('Enter in here');
    print(data);
    mapFriendToRoom[data['account_id_2']] = data['room'];
  }

  void _onMessage(data){
    String partnerId = data['data']['data']['account_id_1'];
    if(!boxChats.containsKey(partnerId)) boxChats[partnerId] = BoxChat(index: 0, listMess: List());
    print('Message: ' + data['data']['data']['message'].toString());
    print('PartnerId: $partnerId');
    boxChats[partnerId].listMess.insert(0,
        Message(message: data['data']['data']['message'],
            created: DateFormat('dd/MM/yyyy, HH:mm:ss').parse(data['data']['data']['created'], false),
            unread: false,
            sender: ShortUser(
                id: data['data']['data']['account_id_1'] ,
                name: data['data']['data']['account_id_1']
            )
        )
    );

    int index = conversations.indexWhere((element) => element.partner.id == partnerId);
    print(index);
    conversations[index].lastMessage = LastMessage(
        message: data['data']['data']['message'],
        created: DateFormat('dd/MM/yyyy, HH:mm:ss').parse(data['data']['data']['created'], false),
        unread: true
    );

    Conversation conv = conversations.removeAt(conversations.indexWhere((element) => element.partner.id == partnerId));
    conversations.insert(0, conv);
    notifyListeners();
  }


  void _printData(data){
    print(data);
  }

  Future<void> fetchConversations(BuildContext context, String token, int index) async {
    var response = await FakeBookService().get_list_conversation(token, index, AppConfig.DEFAULT_COUNT_CONVERSATION);
    if(response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          print(response['data']);
          List<Conversation> list = (response['data'] as List).map((boxchat) => Conversation.fromJson(boxchat)).toList().reversed.toList();
          if(list != null && list.length > 0){
            if(index != 0){
              addListConversation(list);
            }
            else{
              conversations.clear();
              addListConversation(list);
            }
            cachedListBoxChat();
          }
          numNewMess = response['num_new_message'];
          cachedNumNewMess();
          break;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          break;
        case ConstantCodeMessage.NO_DATA:
          conversations.clear();
          notifyListeners();
          break;
        default:
          break;
      }
    }
    return null;
  }

  Future<void> fetchConversation(BuildContext context, String token, String partnerId) async {
    int index = 0;
    if(partnerId != null && boxChats.containsKey(partnerId)){
      index = boxChats[partnerId].listMess.length;
    }else if(!boxChats.containsKey(partnerId)){
      boxChats[partnerId] = BoxChat(index: 0, listMess: List());
    }
    print('token: ' + token);
    print('Index: ' + index.toString());
    print('Partner id: ' + partnerId.toString());
    var response = await FakeBookService().get_conversation(token, partnerId, index, AppConfig.DEFAULT_LOADING_NUM_MESS);
    if(response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:

          List<Message> list = (response['data']['conversation'] as List).map((boxChat) => Message.fromJson(boxChat)).toList();
          if(list != null && list.length > 0){
            addMessagesToConversation(partnerId, list);
            cachedConversation(partnerId);
          }
          numNewMess = response['num_new_message'];
          cachedNumNewMess();
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return null;
        default:
          return null;
      }
    }
    return null;
  }

  bool isSetReadMess = false;
  Future<void> setReadMessage(String token, String partnerId) async {
    if(isSetReadMess == false){
      isSetReadMess = true;
      var res = await FakeBookService().set_read_message(token, partnerId);
      if(res != null){
        switch(int.parse(res['code'])){
          case ConstantCodeMessage.OK:
            conversations.forEach((element) {
              if(element.partner.id == partnerId){
                element.lastMessage.unread = false;
              }
            });
            if(this.numNewMess != null) this.numNewMess -=1;
            else this.numNewMess = 0;
            isSetReadMess = false;
            notifyListeners();
            return;
          case ConstantCodeMessage.TOKEN_INVALID:
            isSetReadMess = false;
            ErrorHelper.instance.errorTokenInValid(context);
            return;
          default:
            isSetReadMess = false;
            return;
        }
      }else{
        isSetReadMess = false;
      }
    }
    return null;
  }

  Future<void> fetchFriends(BuildContext context, String token, String userId, int index) async {
    var response = await FakeBookService().get_user_friends(token, userId, index, AppConfig.DEFAULT_COUNT_LIST_FRIENDS);
    if(response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          List<Friend> list = List();
          list = (response["data"]["friends"] as List).map((friend) => Friend.fromJson(friend)).toList();
          print('Length ' + list.length.toString());
          if(index == 0){
            friends.clear();
            addListFriend(list);
            notifyListeners();
          }else{
            addListFriend(list);
            notifyListeners();
          }
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        default:
          return;
      }
    } else
      return null;
  }

  String getConversationId(String partnerId){
    List<Conversation> list =  conversations.where((element) => element.partner.id == partnerId).toList();
    if(list != null && list.length > 0){
      return list.first.id;
    }
    return null;
  }

  String getConversationIdWhenJoin(String partnerId){
    if(mapFriendToRoom.containsKey(partnerId)) return mapFriendToRoom[partnerId];
    return null;
  }

  void cachedListBoxChat() async {
    SharedPreferencesHelper.instance.setListBoxChat(this.conversations);
  }

  void cachedConversation(String partnerId) async {
    SharedPreferencesHelper.instance.setConversation(boxChats[partnerId], partnerId);
  }

  void cachedNumNewMess() async {
    SharedPreferencesHelper.instance.setNumNewMess(numNewMess);
  }

  void addListFriend(List<Friend> list){
    friends.addAll(list);
    indexFriends = friends.length;
    notifyListeners();
  }

  void addMessagesToConversation(String partnerId, List<Message> list){
    if(list.length > 0){
      boxChats[partnerId].addListMessage(list);
      notifyListeners();
    }
  }

  void addSendMessageToConversation(String partnerId, Message message){
    if(message != null){
      if(!boxChats.containsKey(partnerId)){
        boxChats[partnerId] = BoxChat(index: 0, listMess: List());
      }

      boxChats[partnerId].listMess.insert(0, message);

      int index = conversations.indexWhere((element) => element.partner.id == partnerId);
      conversations[index].lastMessage = LastMessage(
          message: message.message,
          created: DateTime.now(),
          unread: false
      );

      Conversation conv = conversations.removeAt(index);
      conversations.insert(0, conv);

      notifyListeners();
    }
  }

  void addListConversation(List<Conversation> list){
    list.sort((a,b)=> b.lastMessage.created.compareTo(a.lastMessage.created));
    conversations.addAll(list);
    indexConversation = conversations.length;
    // Set for list conversation
    list.forEach((boxChat) {
      boxChats[boxChat.partner.id] = BoxChat(index: 0, listMess: List());
    });
    notifyListeners();
  }

  void setListConversation(List<Conversation> list){
    conversations.clear();
    conversations.addAll(list);
    indexConversation = conversations.length;
    // Set for list conversation
    list.forEach((boxChat) {
      boxChats[boxChat.partner.id] = BoxChat(index: 0, listMess: List());
    });
    notifyListeners();
  }

  void setBoxChat(BoxChat boxChat, String partnerId){
    boxChats[partnerId] = boxChat;
    notifyListeners();
  }

  void setListFriend(List<Friend> list){
    friends.clear();
    friends.addAll(list);
    indexFriends = friends.length;
    notifyListeners();
  }

  void setHistorySearchMess(List<Friend> friends){
    historySearchMess.clear();
    historySearchMess.addAll(friends);
    notifyListeners();
  }
}