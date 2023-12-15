import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/user.dart';
import 'package:intl/intl.dart';

class Post {
  String idPost;
  String described;
  DateTime created;
  DateTime modified;
  int numOfLike;
  int numOfComment;
  bool isLiked;
  List<ImageUrl> images;
  List<VideoUrl> videos;
  ShortUser author;
  String state; // Trang thai cua nguoi viet ?
  bool isBlocked; // Kiem tra author co block userid khong
  bool canEdit;
  bool banned;
  bool canComment;

  Post({this.idPost,
    this.described,
    this.created,
    this.modified,
    this.numOfLike,
    this.numOfComment,
    this.isLiked,
    this.images,
    this.videos,
    this.author,
    this.state,
    this.isBlocked,
    this.canEdit,
    this.banned,
    this.canComment
  });
  
  
  factory Post.fromJson(Map<String, dynamic> data){
    DateTime created;
    DateTime modified;
    try {
      if (data.containsKey('created')){
        created = DateFormat('dd/MM/yyyy, HH:mm:ss').parse((data['created'] as String).trim(), false).toLocal();
      } else created = null;
    } on Exception catch(e){
      created = null;
      print(e.toString());
    }
    try {
      if (data.containsKey('modified')){
        modified = (data['modified'] as String).length > 1 ? DateFormat('dd/MM/yyyy, HH:mm::ss').parse((data['modified'] as String).trim(), false).toLocal() : null;
      } else modified = null;
    } on Exception catch(e){
      modified = null;
      print(e.toString());
    }
    return Post(
      author: ShortUser.fromJson(data['author']),
      banned: (data.containsKey('banned')) ? (data['banned'] as String).parseBool() : false,
      canComment: (data.containsKey('can_comment')) ? (data['can_comment'] as String).parseBool(): false,
      created: created,
      described: data['described'] as String,
      idPost: data['id'] as String,
      isBlocked: (data.containsKey('is_blocked')) ? (data['is_blocked'] as String).parseBool() : false,
      isLiked: (data['is_liked'] as String).parseBool(),
      modified: modified,
      state: (data.containsKey('state')) ? data['state'] as String : "",
      canEdit: (data.containsKey('can_edit')) ? (data['can_edit'] as String).parseBool() : false,
      numOfComment: int.parse(data['comment']),
      numOfLike: int.parse(data['like']),
      images: (data.containsKey('image') && data['image'].toString().length > 0) ? (data['image'] as List).map((image) => ImageUrl.fromJson(image)).toList() : null,
      videos: (data.containsKey('video') && data['video'].toString().length > 0) ? (data['video'] as List).map((video) => VideoUrl.fromJson(video)).toList() : null
    );
  }

  Map<String, dynamic> toJson() => {
    "author" : this.author.toJson(),
    "id" : this.idPost,
    "described" : this.described,
    "created" : created != null ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(created) : "",
    "modified" : modified != null ? DateFormat('dd/MM/yyyy, HH:mm:ss').format(modified) : "",
    "like" : this.numOfLike.toString(),
    "comment" : this.numOfComment.toString(),
    "is_liked" : this.isLiked ? "1" : "0",
    "image" : images != null ? images.map((image) => image.toJson()).toList() : "",
    "video" : videos != null ? videos.map((video) => video.toJson()).toList() : "",
    "state" : this.state,
    "is_blocked" : this.isBlocked ? "1" : "0",
    "can_edit" : this.canEdit ? "1" : "0",
    "banned" : this.banned ? "1" : "0",
    "can_comment" : this.canComment ? "1" : "0"
  };
  @override
  String toString() {
    return 'created: ${this.created}, modified: ${this.modified}';
  }
}

extension BoolParsing on String {
  bool parseBool(){
    if (int.parse(this) == 0) return false;
    else return true;
  }
}
