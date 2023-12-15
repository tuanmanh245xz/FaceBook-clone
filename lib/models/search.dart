

import 'package:intl/intl.dart';

class KeyWord {
  String id;
  String keyword;
  DateTime created;

  KeyWord({this.id, this.keyword, this.created});

  factory KeyWord.fromJson(Map<String, dynamic> data){
    DateTime created = null;
    try {
      created = DateFormat('dd/MM/yyyy, HH:mm:ss').parse(data['created'] as String, false);
    } on Exception catch(e){
      print(e.toString());
      created = null;
    }
    return KeyWord(
      id: data['id'],
      keyword: data['keyword'],
      created: created
    );
  }

  Map<String, dynamic> toJson() => {
    "id" : id,
    "keyword" : keyword,
    "created" : DateFormat('dd/MM/yyyy, HH:mm:ss').format(created)
  };
}