import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'package:fake_app/models/friend.dart';
import 'package:fake_app/models/user.dart';
import 'package:fake_app/screens/custom_widget/circle_button.dart';
import 'package:fake_app/screens/home_pages/suggest_friend.dart';
import 'package:fake_app/screens/personal_page/personal_page.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_prefs.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fake_app/utils/constants/constants.dart' as Constants;
import 'package:fake_app/utils/constants/constants_colors.dart' as Constants_Color;
import 'package:fake_app/utils/constants/constants_strings.dart' ;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fake_app/screens/custom_screen/posts_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fake_app/utils/helper/bottomsheet_helper.dart';

import 'package:fake_app/service/fakebook_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:shimmer/shimmer.dart';

class ListBlockPage extends StatefulWidget {
  static String route = "/listblockpage";
  @override
  _ListBlockPageState createState() => _ListBlockPageState();
}

class _ListBlockPageState extends State<ListBlockPage>{
  List<SimpleUser> listBlock = List();
  UserViewModel model;
  bool block = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = Provider.of<UserViewModel>(context, listen: false);
    _getListBlocks();
  }

  void _getListBlocks() async {
    FakeBookService().get_list_blocks(model.user.token, 0 , 6).then((res) {
      setState(() {
        print(res);
        listBlock = (res["data"] as List).map((shortUser) => SimpleUser.fromJson(shortUser)).toList();
        if(listBlock.length==0){
          block = true;
        }
      });
      print(listBlock);
    });
  }

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Danh sách chặn"
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.search),
              onPressed: (){}
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          _getHeader(),
          _getListBlock()
        ],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _getHeader(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: <Widget>[
          (listBlock.length >0 && listBlock != null)
              ?Text(
            listBlock.length.toString()+" người",
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
          )
              : (block == true)
                  ?Text(
            listBlock.length.toString()+" người",
            style: Theme.of(context).textTheme.headline6.copyWith(fontSize: 20),
          )
                  :Shimmer.fromColors(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey,
                ),
                height: 30,
                width: 100,
              ),
              baseColor: Colors.grey[200],
              highlightColor:  Colors.grey[100]
          ),
          Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ConstString.sort,
                  style: TextStyle(
                      color: HexColor(ConstColor.text_color_blue)
                  ),
                )
            ),
          )
        ],
      ),
    );
  }

  Widget _getListBlock(){
    if (listBlock != null && listBlock.length > 0) {
      return Container(
        height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            itemCount: listBlock.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return ListTile(
                onTap: (){},
                contentPadding: EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                leading: (listBlock[index].avatar != "")
                    ?CircleAvatar(
                  backgroundImage: NetworkImage(listBlock[index].avatar),
                  radius: 25,
                )
                    :CircleAvatar(
                  radius: 25,
                  child: ClipRRect(
                    child: Image.asset("images/user_grey.png"),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child:  Text(
                        listBlock[index].name,
                        style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w700
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),

                  ],
                ),
                trailing: FlatButton(
                  child: Text(
                      "Bỏ chặn",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        color: Colors.red
                      ),
                  ),
                  onPressed: () => _onPressUnBlock(listBlock[index]),
                  color: HexColor(ConstColor.grey_fake_transparent),
                ),
              );
            }
        ),
      );
    } else if (block == true){
      return Container(
        margin: EdgeInsets.only(top: 100),
        padding: EdgeInsets.all(20),
        height: 400,
        child: Center(
            child: Column(
              children: [
                Text(
                  "Danh sách trống",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
                ),
              ],
            )
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height * 1.0,
        child: ListView.builder(
            itemCount: 8,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                  child: ListTile(
                    onTap: (){},
                    contentPadding: EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
                    leading:  CircleAvatar(
                      radius: 25,
                      child: ClipRRect(
                        child: Image.asset("images/user_grey.png"),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    title: Container(
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.grey,
                    ),
                  ),
                  baseColor: Colors.grey[200],
                  highlightColor:  Colors.grey[100]
              );
            }
        ),
      );
    };
  }

void  _onPressUnBlock(SimpleUser _block) {

    listBlock.remove(_block);
    setState(() {
      listBlock = listBlock;
      if(listBlock.length == 0) {
        block = true;
      }
    });
    FakeBookService().set_block(model.user.token, _block.id, "1");
}


}

