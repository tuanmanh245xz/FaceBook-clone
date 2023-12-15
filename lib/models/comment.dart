import 'package:intl/intl.dart';

import 'user.dart';

class Comment {
  String idComment;
  String content;
  DateTime date;
  ShortUser user;

  Comment({this.idComment, this.user, this.content, this.date});

  factory Comment.fromJson(Map<String, dynamic> data){
    return Comment(
      idComment: data['id'],
      content: data['comment'],
      user: ShortUser(
        id: data['poster']['id'],
        name: data['poster']['name'],
        avatar: data['poster']['avatar']
      ),
      date: DateFormat("dd/MM/yyyy, HH:mm:ss").parse(data['created'], false)
    );
  }
}

