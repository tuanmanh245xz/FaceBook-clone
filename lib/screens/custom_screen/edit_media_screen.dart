import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_app/models/media.dart';
import 'package:fake_app/screens/custom_screen/video_screen.dart';

import 'package:fake_app/utils/helper/media_helper.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';

class ImagesScreen extends StatefulWidget {
  static String route = "/edit_media_screen";
  @override
  _ImagesScreenState createState() => _ImagesScreenState();
}

class _ImagesScreenState extends State<ImagesScreen> {
  List<Media> listMedia;

  @override
  Widget build(BuildContext context) {
    listMedia = ModalRoute.of(context).settings.arguments as List<Media>;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.of(context).pop(listMedia);
          },
        ),
        title: Text(
          ConstString.edit,
          style: Theme.of(context).textTheme.headline6,
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: (){
              Navigator.of(context).pop(listMedia);
            },
            child: Text(
              ConstString.complete_allcap,
              style: Theme.of(context).textTheme.headline6,
            ),
          )
        ],
      ),
      body: MediaHelper.listViewMediaFromMemoryWidget(context, listMedia, _onPressRemove)
    );
  }
  void _onPressRemove(int index){
    setState(() {
      listMedia.removeAt(index);
    });
  }
}


