import 'package:chewie/chewie.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';

import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class ChewieItem extends StatefulWidget {
  VideoPlayerController videoPlayerController;
  bool loop;

  ChewieItem({@required this.videoPlayerController, this.loop, Key key}) : super(key: key);

  @override
  _ChewieItemState createState() => _ChewieItemState();
}

class _ChewieItemState extends State<ChewieItem> {
  ChewieController _chewieController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: widget.videoPlayerController.value.aspectRatio,
        autoInitialize: true,
        looping: widget.loop,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          backgroundColor: Color.fromARGB(100, 0, 0, 0),
          playedColor: HexColor(ConstColor.black  ),
          bufferedColor: HexColor(ConstColor.color_white),
          handleColor: HexColor(ConstColor.color_white)
        ),
        cupertinoProgressColors: ChewieProgressColors(
          backgroundColor: Color.fromARGB(100, 0, 0, 0),
          playedColor: HexColor(ConstColor.black  ),
          bufferedColor: HexColor(ConstColor.color_white),
          handleColor: HexColor(ConstColor.color_white)
      ),
        errorBuilder: (context, errorMessage) {
      return Center(
        child: Text(
          errorMessage,
          style: TextStyle(color: Colors.white),
        ),
      );
    },);
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: _chewieController,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
