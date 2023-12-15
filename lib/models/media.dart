

import 'dart:typed_data';

class Media {
  bool isImage;
  String id;
  Media(isImage, {this.id}){
    this.isImage = isImage;
  }
}

class MediaMemory extends Media {
  Uint8List dataByte;
  String filePathVideo;

  MediaMemory({id, isImage, this.dataByte, this.filePathVideo}) : super(isImage, id: id);
}

class MediaUrl extends Media{
  String urlImage;
  String urlVideo;
  MediaUrl({id, isImage, this.urlImage, this.urlVideo}) : super(isImage, id: id);
}

class ImageUrl {
  String id;
  String url;
  ImageUrl({this.id, this.url});

  factory ImageUrl.fromJson(Map<String, dynamic> data){
    return ImageUrl(
      id: data['id'],
      url: data['link']
    );
  }

  Map<String, dynamic> toJson() => {
    "id" : this.id,
    "link" : this.url
  };

  MediaUrl toMediaUrl(){
    return MediaUrl(
      id: this.id,
      isImage: true,
      urlImage: this.url,
      urlVideo: null
    );
  }
}

class VideoUrl {
  String id;
  String thumb;
  String urlVideo;
  VideoUrl({this.id, this.thumb, this.urlVideo});

  factory VideoUrl.fromJson(Map<String, dynamic> data){
    return VideoUrl(
      id: data['id'],
      thumb: data['thumb'],
      urlVideo: data['link']
    );
  }

  Map<String, dynamic> toJson() => {
    "id" : this.id,
    "thumb" : this.thumb,
    "link" : this.urlVideo
  };

  MediaUrl toMediaUrl(){
    return MediaUrl(
      id : this.id,
      isImage: false,
      urlImage: this.thumb,
      urlVideo: this.urlVideo
    );
  }
}

