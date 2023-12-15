import 'dart:convert';
import 'package:intl/intl.dart';

import 'user.dart';

class LastMessage {
  String message;
  DateTime created;
  bool unread;

  LastMessage({this.message, this.created, this.unread});

  Map<String, dynamic> toJson() => {
    "message" : message,
    "created" : DateFormat('dd/MM/yyyy, HH:mm:ss').format(created),
    "unread" : unread ? "1" : "0"
  };

  factory LastMessage.fromJson(Map<String, dynamic> data){
    DateTime created = null;
    try {
      created = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((data['created'] as String).trim(), false).toLocal();
    } on Exception catch(e){
      created = null;
      print(e.toString());
    }
    return LastMessage(
      message: data['message'],
      created: created,
      unread: data['unread'] == 1 ? true : false
    );
  }
}

class Conversation {
  String id;
  ShortUser partner;
  LastMessage lastMessage;

  Conversation({this.id, this.partner, this.lastMessage});

  factory Conversation.fromJson(Map<String, dynamic> data){
    return Conversation(
      id: data['id'],
      partner: ShortUser(
        id: data['partner']['id'],
        name: data['partner']['username'],
        avatar: data['partner']['avatar']['link']
      ),
      lastMessage: LastMessage.fromJson(data['last_message'])
    );
  }

  Map<String, dynamic> toJson() => {
    "id" : id,
    "partner" : {
      "id" : partner.id,
      "username" : partner.name,
      "avatar" : {
        "link" : partner.avatar
      }
    },
    "last_message" : lastMessage.toJson()
  };
}

class BoxChat {
  int index = 0;
  List<Message> listMess = List();
  BoxChat({this.index, this.listMess});

  void addListMessage(List<Message> list){
    if(list != null){
      listMess.addAll(list);
      index = listMess.length;
    }
  }

  factory BoxChat.fromJson(Map<String, dynamic> data){
    return BoxChat(
      index: data['index'],
      listMess: (jsonDecode(data['listMess']) as List).map((mess) => Message.fromJson(mess)).toList()
    );
  }

  Map<String, dynamic> toJson() => {
    "index" : index,
    "listMess" : jsonEncode(listMess)
  };
}

class BoxMessage {
  bool isYour;
  String message;
  BoxMessage({this.isYour, this.message});
}

class Message {
  String messageId;
  String message;
  bool unread;
  DateTime created;
  ShortUser sender;

  Message({this.messageId, this.message, this.unread, this.created, this.sender});

  factory Message.fromJson(Map<String, dynamic> data){
    DateTime created = null;
    try {
      created = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((data['created'] as String).trim(), false).toLocal();
    } on Exception catch(e){
      created = null;
      print(e.toString());
    }
    return Message(
      messageId: data['message_id'],
      message: data['message'],
      unread: data['unread'] == "1" ? true : false,
      created: created,
      sender: ShortUser(
        id: data['sender']['id'],
        name: data['sender']['username'],
        avatar: data['sender']['avatar']['link']
      )
    );
  }

  Map<String, dynamic> toJson() => {
    "message_id" : messageId,
    "message" : message,
    "created" : created != null ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(created) : "",
    "unread" : unread ? 1 : 0,
    "sender" : {
      "id" : sender.id,
      "username" : sender.name,
      "avatar" : {
        "link" : sender.avatar
      }
    }
  };
}
