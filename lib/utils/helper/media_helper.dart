import 'package:cached_network_image/cached_network_image.dart';
import 'package:fake_app/models/media.dart';
import 'package:fake_app/screens/custom_screen/video_screen.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:flutter/material.dart';
import 'color_helper.dart';

class MediaHelper {
  // Main Widget Helper
  static Widget getMediaWidget(BuildContext context, List<Media> listMedia){
    if (listMedia.isNotEmpty){
      switch(listMedia.length){
        case 1:
          return getLayoutOneMedia(context, listMedia);
        case 2:
          return getLayoutTwoMedia(context, listMedia);
        case 3:
          return getLayoutThreeMedia(context, listMedia);
        case 4:
          return getLayoutFourMedia(context, listMedia);
        default:
          return Container();
      }
    }
    // return Container(height: 350, color: Colors.white,);
    return Container();
  }

  // Show list media (image and video) as Column
  static Widget listViewMediaFromMemoryWidget(BuildContext context, List<Media> listMedia, onPressRemove){
    double wScreen = MediaQuery.of(context).size.width;
    return ListView.builder(
      itemCount: listMedia.length,
      itemBuilder: (BuildContext context, int index){
        return Container(
          margin: EdgeInsets.only(bottom: 30),
          child: Stack(
            children: [
              (listMedia[index] is MediaMemory) ? Image.memory(
                (listMedia[index] as MediaMemory).dataByte,
                fit: BoxFit.fitWidth,
                width: wScreen,
              ) : CachedNetworkImage(
                imageUrl: (listMedia[index] as MediaUrl).urlImage,
                fit: BoxFit.fitWidth,
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: (){
                      onPressRemove(index);
                    },
                    icon: Icon(Icons.clear),
                    iconSize: 20,
                  ),
                ),
              ),
              listMedia[index].isImage ? Container() :
              Positioned.fill(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(
                          context,
                          VideoScreen.route,
                          arguments: listMedia[index]
                      );
                    },
                    child: Center(
                      child: Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: HexColor(ConstColor.color_white)
                      ),
                    ),
                  )
              )
            ],
          ),
        );
      },
    );
  }

  static Widget columnMediaFromUrlWidget(BuildContext context, List<MediaUrl> listMedia){
    double wScreen = MediaQuery.of(context).size.width;
    List<Widget> children = [];
    for (int index = 0; index < listMedia.length; index++){
      children.add(
          Container(
            color: Theme.of(context).dividerColor,
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.network(
                      listMedia[index].urlImage,
                      fit: BoxFit.fitWidth,
                      width: wScreen,
                    ),
                    listMedia[index].isImage ? Container() :
                    Positioned.fill(
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(
                                context,
                                VideoScreen.route,
                                arguments: listMedia[index]
                            );
                          },
                          child: Center(
                            child: Icon(
                                Icons.play_circle_outline,
                                size: 50,
                                color: HexColor(ConstColor.color_white)
                            ),
                          ),
                        )
                    ),
                  ],
                ),
                Container(
                    height: 20,
                    color: Theme.of(context).dividerColor
                )
              ],
            ),
          )
      );
    }
    return Column(
      children: children,
    );
  }


  // Child Widget Helper
  static Widget getLayoutFourMedia(BuildContext context, List<Media> listMedia){
    if (listMedia == null || listMedia.length == 0) return Container();
    final double wScreen = MediaQuery.of(context).size.width;
    final double hLayout = 350;
    final double spacer = 5;
    final double wImage = (wScreen - spacer) / 2;
    final double hImage = (hLayout - spacer) / 2;
    bool isUrl = false;
    if (listMedia.first is MediaMemory) isUrl = false;
    else isUrl = true;

    return Container(
        height: hLayout,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      width: wImage,
                      height: hImage,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: !isUrl ?
                            Image.memory(
                                (listMedia[0] as MediaMemory).dataByte,
                                fit: BoxFit.cover
                            ) :
                            Image.network(
                                (listMedia[0] as MediaUrl).urlImage,
                                fit: BoxFit.cover
                            ),
                          ),
                          listMedia[0].isImage ? Container() :
                          _getWidgetPlayVideo(25)
                        ],
                      ),
                    )
                ),
                Container(width: spacer,),
                Expanded(
                    flex: 1,
                    child: Container(
                      width: wImage,
                      height: hImage,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: !isUrl ?
                            Image.memory(
                                (listMedia[1] as MediaMemory).dataByte,
                                fit: BoxFit.cover
                            ) :
                            Image.network(
                                (listMedia[1] as MediaUrl).urlImage,
                                fit: BoxFit.cover
                            ),
                          ),
                          listMedia[1].isImage ? Container() :
                          _getWidgetPlayVideo(25)
                        ],
                      ),
                    )
                )
              ],
            ),
            Container(height: spacer,),
            Row(
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Container(
                      width: wImage,
                      height: hImage,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: !isUrl ?
                            Image.memory(
                                (listMedia[2] as MediaMemory).dataByte,
                                fit: BoxFit.cover
                            ) :
                            Image.network(
                                (listMedia[2] as MediaUrl).urlImage,
                                fit: BoxFit.cover
                            ),
                          ),
                          listMedia[2].isImage ? Container() :
                          _getWidgetPlayVideo(25)
                        ],
                      ),
                    )
                ),
                Container(width: spacer,),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: wImage,
                    height: hImage,
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: !isUrl ?
                          Image.memory(
                              (listMedia[3] as MediaMemory).dataByte,
                              fit: BoxFit.cover
                          ) :
                          Image.network(
                              (listMedia[3] as MediaUrl).urlImage,
                              fit: BoxFit.cover
                          ),
                        ),
                        listMedia[3].isImage ? Container() :
                        _getWidgetPlayVideo(25)
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        )
    );
  }

  static Widget getLayoutThreeMedia(BuildContext context, List<Media> listMedia){
    if (listMedia == null || listMedia.length == 0) return Container();
    final double hImage = 350;
    final double wScreen = MediaQuery.of(context).size.width;
    final double wRightImage = (wScreen - 5) / 2;
    bool isUrl = false;
    if (listMedia.first is MediaUrl) isUrl = true;
    else isUrl = false;

    return Container(
        height: hImage,
        child: Row(
          children: <Widget>[
            Expanded(
                flex: 2,
                child: Container(
                    height: hImage,
                    color: Colors.white,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: !isUrl ?
                          Image.memory(
                            (listMedia[0] as MediaMemory).dataByte,
                            fit: BoxFit.cover,
                          ):
                          CachedNetworkImage(
                            imageUrl: (listMedia[0] as MediaUrl).urlImage,
                            progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
                            fit: BoxFit.cover,
                          ),
                        ),
                        listMedia[0].isImage ? Container() :
                        _getWidgetPlayVideo(40)
                      ],
                    )
                )
            ),
            Container(width: 5,),
            Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: wRightImage,
                        height: hImage/2,
                        color: Colors.white,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: !isUrl ?
                              Image.memory(
                                (listMedia[1] as MediaMemory).dataByte,
                                fit: BoxFit.cover,
                              ):
                              CachedNetworkImage(
                                imageUrl: (listMedia[1] as MediaUrl).urlImage,
                                progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
                                fit: BoxFit.cover,
                              ),
                            ),
                            listMedia[1].isImage ? Container() :
                            _getWidgetPlayVideo(35)
                          ],
                        ),
                      ),
                    ),
                    Container(height: 5,),
                    Expanded(
                      flex: 1,
                      child: Container(
                          width: wRightImage,
                          height: hImage/2,
                          color: Colors.white,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: !isUrl ?
                                Image.memory(
                                  (listMedia[2] as MediaMemory).dataByte,
                                  fit: BoxFit.cover,
                                ) :
                                CachedNetworkImage(
                                  imageUrl: (listMedia[2] as MediaUrl).urlImage,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              listMedia[2].isImage ? Container() :
                              _getWidgetPlayVideo(35)
                            ],
                          )
                      ),
                    )
                  ],
                )
            )
          ],
        )
    );
  }

  static Widget getLayoutTwoMedia(BuildContext context, List<Media> listMedia){
    if (listMedia == null || listMedia.length == 0) return Container();
    bool firstIsUrl = false;
    bool secondIsUrl = false;
    final double hImage = 350;
    if (listMedia[0] is MediaUrl) firstIsUrl = true;
    if (listMedia[1] is MediaUrl) secondIsUrl = true;

    return Container(
        height: hImage,
        child: Row(
          children: <Widget>[
            Expanded(
                child: Stack(
                  children: [
                    !firstIsUrl ?
                    Image.memory(
                        (listMedia[0] as MediaMemory).dataByte,
                        height: hImage,
                        fit: BoxFit.fitHeight
                    ):
                    CachedNetworkImage(
                      imageUrl: (listMedia[0] as MediaUrl).urlImage,
                      progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
                      height: hImage,
                      fit: BoxFit.fitHeight,
                    ),
                    listMedia[0].isImage ? Container() :
                    _getWidgetPlayVideo(40)
                  ],
                )
            ),
            Container(width: 5,),
            Expanded(
                child: Container(
                  child: Stack(
                    children: [
                      !secondIsUrl ?
                      Image.memory(
                        (listMedia[1] as MediaMemory).dataByte,
                        height: hImage,
                        fit: BoxFit.fitHeight,
                      ) :
                      CachedNetworkImage(
                        imageUrl: (listMedia[1] as MediaUrl).urlImage,
                        progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
                        height: hImage,
                        fit: BoxFit.fitHeight,
                      ),
                      listMedia[1].isImage ? Container() :
                      _getWidgetPlayVideo(40)
                    ],
                  ),
                )
            )
          ],
        )
    );
  }

  static Widget getLayoutOneMedia(BuildContext context, List<Media> listMedia){
    if (listMedia == null || listMedia.length == 0) return Container();
    bool isUrl = false;
    if (listMedia.first is MediaUrl) isUrl = true;
    else isUrl = false;

    int wScreen = MediaQuery.of(context).size.width.toInt();
    return Container(
      height: MediaQuery.of(context).size.width * 1.0,
        child: Stack(
          children: [
            !isUrl ?
            Image.memory(
              (listMedia[0] as MediaMemory).dataByte,
              width: wScreen.toDouble(),
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.width * 1.0,
              // fit: BoxFit.fitWidth,
            ) :
            CachedNetworkImage(
              height: MediaQuery.of(context).size.width * 1.0,
              imageUrl: (listMedia[0] as MediaUrl).urlImage,
              progressIndicatorBuilder: (context, url, downloadProgress) => onLoadingImageWidget,
              width: wScreen.toDouble(),
              fit: BoxFit.cover,
              // fit: BoxFit.fitWidth,
            ),
            listMedia[0].isImage ? Container() :
            _getWidgetPlayVideo(50)
          ],
        )
    );
  }

  static final Widget onLoadingImageWidget = Container(
    height: 200,
    color: HexColor(ConstColor.color_grey),
    child: Center(child: Constant.getDefaultCircularProgressIndicator(32, color: ConstColor.color_white))
  );

  static Widget _getWidgetPlayVideo(double sizeIcon){
    return Positioned.fill(
      child: Center(
          child: Icon(
            Icons.play_circle_outline,
            // color: HexColor(ConstColor.color_white),
            color: Colors.white,
            size: sizeIcon,)
      ),
    );
  }

}


