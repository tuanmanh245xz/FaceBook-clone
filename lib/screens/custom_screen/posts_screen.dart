import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/models/post.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_screen/edit_media_screen.dart';
import 'package:fake_app/screens/custom_screen/emotion_screen.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/service/fakebook_service.dart';

import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';
import 'package:fake_app/utils/helper/dialog_helper.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/utils/helper/media_helper.dart';

import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:thumbnails/thumbnails.dart';
import 'dart:core';

import 'package:video_player/video_player.dart';

class PostScreen extends StatefulWidget {
  static String route = "/post_screen";

  PostScreen({this.post});
  final Post post;
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final double sizeIcon = 26;
  final double heightOfLayout = 200;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool isDescribeNotEmpty = false;
  bool isShowEmotion = false;
  bool isHasMedia = false;
  bool isEdit = false;
  List<String> emotion = null;
  TextEditingController tdDescribedControl = TextEditingController();
  FocusNode myFocusNode;
  List<Media> listMedia = List();
  List<Media> preListMedia = List();
  VideoPlayerController _videoController;
  User _user;
  Post _post;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    _user = Provider.of<UserViewModel>(context, listen: false).user;
    _post = widget.post;
    if (_post != null){
      isEdit = true;
      tdDescribedControl.text = _post.described;
      if (_post.images != null){
        _post.images.forEach((element) {
          listMedia.add(element.toMediaUrl());
        });
      }
      if (_post.videos != null){
        _post.videos.forEach((element) {
          listMedia.add(element.toMediaUrl());
        });
      }
      preListMedia.addAll(listMedia);
    } else isEdit = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tdDescribedControl.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      bottomSheet: _getBottomSheetPost(),
      appBar: AppBar(
        leading: IconButton(
          onPressed: isEdit ? _onPressBackEdit : _onPressBack,
          icon: Icon(Icons.arrow_back, ),
        ),
        title: Text(
          isEdit ? ConstString.title_post_edit_screen : ConstString.title_post_screen,
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          !isEdit ? GestureDetector(
            onTap: (isHasMedia | isShowEmotion | isDescribeNotEmpty) ? _onTapPost : null,
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Center(
                child: Text(
                  ConstString.post,
                  style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18, color: HexColor((isHasMedia | isShowEmotion | isDescribeNotEmpty) ? ConstColor.azure : ConstColor.color_disable,), fontWeight: FontWeight.w300)
                ),
              ),
            )
          ) : GestureDetector(
              onTap: _onSave,
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: Center(
                  child: Text(
                      ConstString.save,
                      style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 18, color: HexColor((isHasMedia | isShowEmotion | isDescribeNotEmpty) ? ConstColor.azure : ConstColor.color_disable,), fontWeight: FontWeight.w300)
                  ),
                ),
              )
          ),
        ],
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return ListView(
      children: [
        _getHeader(),
        Container(
          margin: EdgeInsets.only(bottom: 10),
          child: _getTextField(),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 50),
          child: GestureDetector(
            onTap: _onTapToEdit ,
            child: _getLayoutMedia()
          )
        ),
      ],
    );
  }

  Widget _getLoadingWidget() {
    return Container(
        color: Colors.transparent,
        child: Center(
            child: Container(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                backgroundColor: HexColor(ConstColor.color_grey),
              ),
            )
        )
    );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.only(top: 10),
      height: 70,
      child: ListTile(
        leading: (_user.link_avatar != null && _user.link_avatar.length > 0)
          ?CircleAvatar(
          backgroundImage: NetworkImage(_user.link_avatar),
          radius: 30,
        )
          :CircleAvatar(
          backgroundImage: AssetImage("images/user_grey.png"),
          radius: 30,
        ),
        title: RichText(
          text: TextSpan(
            text: _user.name,
            style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 18),
            children: isShowEmotion ? [
              TextSpan(
                text:  " - Đang ",
                style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 17)
              ),
              WidgetSpan(
                child: Image.asset("images/" + emotion[0] + ".png", width: 20, height: 20)
              ),
              TextSpan(
                text: ' cảm thấy ',
                style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 17)
              ),
              TextSpan(
                text: emotion[1] + ".",
                  style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 17)
              )
            ]: []
          ),
        ),
        subtitle: Container(
          margin: EdgeInsets.only(top: 5),
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(3),
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: HexColor(ConstColor.grey_fake_transparent), width: 2)
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.group),
                    Container(width: 3,),
                    Text(
                      ConstString.public,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
                    )
                  ],
                ),
              ),
              Container(width: 10, height: 10,),
              Container(
                padding: EdgeInsets.all(3),
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: HexColor(ConstColor.grey_fake_transparent), width: 2)
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.add),
                    Text(
                      ConstString.ablum,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBottomSheetPost(){
   return GestureDetector(
     onTap: _onTapAddtoPost,
     child: Container(
       height: 40,
       decoration: BoxDecoration(
           border: Border(
               top: BorderSide(width: 2, color: HexColor(ConstColor.grey_fake_transparent))
           )
       ),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.start,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
           Container(
             margin: EdgeInsets.only(left: 10, right: 10),
             child: Text(
               ConstString.add_to_post,
               style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.normal, fontSize: 17),
             ),
           ),
           Spacer(),
           Icon(Icons.video_call, color: HexColor(ConstColor.color_video_call), size: sizeIcon,),
           Icon(Icons.image, color: HexColor(ConstColor.color_image), size: sizeIcon,),
           Icon(Icons.person_add, color: HexColor(ConstColor.color_friend), size: sizeIcon,),
           Icon(Icons.insert_emoticon, color: HexColor(ConstColor.color_emotion), size: sizeIcon,),
           Container(width: 10,)
         ],
       ),
     ),
   );
  }

  Widget _getTextField(){
    return TextField(
      controller: tdDescribedControl,
      onChanged: (text){
        setState(() {
          if (text.isNotEmpty) isDescribeNotEmpty = true;
          else isDescribeNotEmpty = false;
        });
      },
      decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, left: 10, right: 10),
          hintText: listMedia.isNotEmpty ? ConstString.what_do_you_thing_about_pictures : ConstString.what_do_you_thing,
          hintStyle: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: listMedia.isNotEmpty ? 16 : 23, fontWeight: FontWeight.normal, color: HexColor(ConstColor.color_text_hint)),
          border: InputBorder.none
      ),
      cursorColor: HexColor(ConstColor.azure),
      style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: listMedia.isNotEmpty ? 18 : 26, fontWeight: FontWeight.normal),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      focusNode: myFocusNode,
    );
  }

  Widget _getLayoutMedia(){
    if (listMedia.isNotEmpty){
      switch(listMedia.length){
        case 1:
          return MediaHelper.getLayoutOneMedia(context, listMedia);
        case 2:
          return MediaHelper.getLayoutTwoMedia(context, listMedia);
        case 3:
          return MediaHelper.getLayoutThreeMedia(context, listMedia);
        case 4:
          return MediaHelper.getLayoutFourMedia(context, listMedia);
        default:
          return Container(height: 350, );
      }
    }
    return Container(height: 350, color: Colors.white,);
  }

  void _onPressBack() async {
    if (isHasMedia | isShowEmotion | isDescribeNotEmpty) {
      var resultCode = await BottomSheetHelper.showPostWarningBack(context) as int;
      switch (resultCode){
        case Constant.code_continue_edit_post:
          break;
        case Constant.code_throw_post:
          _onBackAndThrowPost();
          break;
        default:
          break;
      }
    } else {
      _onBackAndThrowPost();
    }
  }
  
  void _onPressBackEdit() async {
    int result = await DialogHelper.showDialogConfirm(context, ConstString.post_edit_back_title, ConstString.post_edit_back_content, ConstString.post_edit_back_leave, ConstString.post_edit_back_negative_btn);
    if (result == 1){
      Navigator.of(context).pop();
    }
  }

  void _onBackAndThrowPost(){
    Navigator.of(context).pop();
  }

  void _onTapPost() {
    List<String> images = List();
    List<File> videos = List();
    List<String> thumbs = List();
    listMedia.forEach((element) {
      if (element.isImage){
        List<int> byteData = (element as MediaMemory).dataByte.toList();
        images.add(base64Encode(byteData));
      } else {
        videos.add(File((element as MediaMemory).filePathVideo));
        List<int> byteData = (element as MediaMemory).dataByte.toList();
        thumbs.add(base64Encode(byteData));
      }
    });
    String described = tdDescribedControl.text;

    Map<String, dynamic> content =  {
      "images" : images,
      "videos" : videos,
      "described" : described,
      "status" : emotion != null && emotion.length > 0 ? emotion[1] : "",
      "thumbs" : thumbs
    };
    Navigator.of(context).pop(content);
  }


  void _onTapAddtoPost() {
    BottomSheetHelper.showActionPost(context, _onTapInsertImages, _onTapInsertVideo, _onTapInsertEmotion);
  }

  void _onTapInsertImages() async {
    if (listMedia.length >= 4) {
      DialogHelper.showDialogMaxImagesPost(context, "Lỗi tải hình ảnh", "Số video va ảnh tải lên tối đa là 4");
      return;
    }

    List<Asset> resultImages;
    try {
      resultImages = await MultiImagePicker.pickImages(maxImages: 4 - listMedia.length);
    } on Exception catch (e){
      print(e.toString());
    }

    if (resultImages != null){
      for (int i = 0; i < resultImages.length; i++){
        resultImages[i].getByteData().then((value) => {
          _addImage(value)
        });
      }
    }
  }
  
  void _addImage(ByteData value){
    if (listMedia.length >= 4) {
      DialogHelper.showDialogMaxImagesPost(context, "Lỗi tải video", "Số video va ảnh tải lên tối đa là 4");
      return;
    }
    setState(() {
      listMedia.add(MediaMemory(isImage: true, dataByte: value.buffer.asUint8List(value.offsetInBytes, value.lengthInBytes)));
      isHasMedia = true;
    });
  }

  void _onTapInsertVideo() async {
    ip.PickedFile video;
    try {
      video = await ip.ImagePicker().getVideo(source: ip.ImageSource.gallery);
    } on Exception catch(e){
    }

    if (video != null){
      String thumbPath = await Thumbnails.getThumbnail(
        videoFile: video.path,
        imageType: ThumbFormat.PNG,
        quality: 70
      );
      File file = File(video.path);
      file = await file.rename("${file.path.substring(0, file.path.length - 4)}.mp4");
      Uint8List data = File(thumbPath).readAsBytesSync();
      setState(() {
        listMedia.add(MediaMemory(isImage: false, dataByte: data, filePathVideo: file.path));
        isHasMedia = true;
      });
    }
  }

  void _onTapInsertEmotion() async {
    var resultEmotion = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmotionScreen(curEmotion: emotion,))
    ) as List;

    setState(() {
      emotion = resultEmotion;
      if (emotion != null && emotion.isNotEmpty){
        isShowEmotion = true;
      } else {
        isShowEmotion = false;
      }
    });
  }

  void _onTapToEdit() async {
    if (listMedia.isEmpty || listMedia.length == 0){
      FocusScope.of(context).requestFocus(myFocusNode);
      return;
    }
    var listNewImages = await Navigator.pushNamed(context, ImagesScreen.route, arguments: listMedia);
    setState(() {
      if (listNewImages != null){
        listMedia = listNewImages;
        isHasMedia = true;
      } else {
        isHasMedia = false;
      }
    });
  }

  void _onSave() async {
    // Do save post
    List<String> images = List(); // base64
    List<String> imagesDel = List(); // id
    List<int> imagesSort = List();
    List<File> videos = List();
    List<String> thumbs = List();
    int numOfNewMedia = 0;
    for(int i = 0; i < listMedia.length; i++){
      if(listMedia[i] is MediaMemory){
        if (listMedia[i].isImage){
          List<int> data = (listMedia[i] as MediaMemory).dataByte.toList();
          images.add(base64Encode(data));
        }else{
          videos.add(File((listMedia as MediaMemory).filePathVideo));
          List<int> data = (listMedia[i] as MediaMemory).dataByte.toList();
          thumbs.add(base64Encode(data));
        }
        numOfNewMedia++;
      }
    }
    print(preListMedia.length);
    print(listMedia.length);
    for(int i = 0; i < preListMedia.length; i++){
      print('PreList: ' + preListMedia[i].id.toString());
    }
    for(int i = 0; i < listMedia.length; i++){
      print('ListMedia: ' + listMedia[i].id.toString());
    }
    for (int i = 0; i < preListMedia.length; i++){
      if (listMedia.indexWhere((element) => element.id == preListMedia[i].id) == -1){
        imagesDel.add(preListMedia[i].id);
      }
    }

    for (int i = listMedia.length - 1; i > listMedia.length - 1 - numOfNewMedia; i--){
      imagesSort.add(i);
    }

    DialogHelper.showLoading(context, _keyLoader);
    var response = await FakeBookService().edit_post(
        _user.token, _post.idPost,
        tdDescribedControl.text,
        (emotion != null && emotion.length > 0) ? emotion[1] : "",
        images,
        imagesDel,
        imagesSort,
        videos,
        thumbs,
        false,
        false,
    );
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();

    if (response != null){
        switch(int.parse(response['code'])){
          case ConstantCodeMessage.OK:
            // Change view when you finish to change post
            Navigator.of(context).pop(listMedia);
            widget.post.described = tdDescribedControl.text.trim();
            widget.post.state = (emotion != null && emotion.length > 0) ? emotion[1] : "";
            break;
          case ConstantCodeMessage.TOKEN_INVALID:
            ErrorHelper.instance.errorTokenInValid(context);
            break;
          case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
            ErrorHelper.instance.errorActionHasBeenDone(context, _post);
            break;
          case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
            ErrorHelper.instance.errorUserIsNotValidate(context);
            break;
          case ConstantCodeMessage.PARAM_VALUE_INVALID:
            ErrorHelper.instance.errorParamNotValid(context);
            break;
        }
    }else{
      await DialogHelper.showDialogErrorAction(context, ConstString.error_no_internet_title, ConstString.error_no_internet);
      Navigator.of(context).pop();
    }
  }


}
