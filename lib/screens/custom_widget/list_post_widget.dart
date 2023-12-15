import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_widget/list_video_widget.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/view_models/post_view_model.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ListPost extends StatefulWidget {
  ListPost(
      {this.isNewFeedpage = false,
        this.isVideoPage = false,
        this.isPersonPage = false});
  bool isNewFeedpage = false, isVideoPage = false, isPersonPage = false;
  @override
  _ListPostState createState() => _ListPostState();
}

class _ListPostState extends State<ListPost> {
  UserViewModel account;
  UserViewModel model;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    account = Provider.of<UserViewModel>(context, listen: false);
    return Consumer<PostViewModel>(builder: (context, postVm, child) {
      print('HasPost: ' + postVm.hasPosts.toString());
      if (widget.isNewFeedpage) {
          List<Widget> children = [];
          postVm.listPost.forEach((post) {
            children.add(PostWidget(
              post: post,
            ));
          });
          return Column(
            children: children,
          );

      } else if (widget.isVideoPage) {
        List<Widget> children = [];
        postVm.listPostVideo.forEach((post) {
          children.add(PostWidget(
            post: post,
          ));
        });
        return Column(
          children: children,
        );

      } else if (widget.isPersonPage) {
          model = ModalRoute.of(context).settings.arguments;
          List<Widget> children = [];
          postVm.listPostPersonal.forEach((post) {
            if (post.author.id == model.user.id)
              children.add(PostWidget(
                post: post,
              ));
          });
          return Column(
          children: children,
        );
      } else {
        return Container();
      }
    });
  }

  void _onPressFindFriend() {
    Provider.of<UserViewModel>(context, listen: false).tabController.animateTo(
        1,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
    );
  }

  Widget loadingPost(){
    return Column(
      children: [
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200],
            highlightColor:  Colors.grey[100],
            child: Container(
              height: MediaQuery.of(context).size.width * 0.6,
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
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
                subtitle:  Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200],
            highlightColor:  Colors.grey[100],
            child: Container(
              height: MediaQuery.of(context).size.width * 0.6,
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
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
                subtitle:  Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 6, color: Colors.grey[300], spreadRadius: 1)
            ],
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200],
            highlightColor:  Colors.grey[100],
            child: Container(
              height: MediaQuery.of(context).size.width * 0.6,
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
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
                subtitle:  Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 20,
                  width: MediaQuery.of(context).size.width * 0.5,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}