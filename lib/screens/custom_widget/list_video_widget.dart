import 'package:fake_app/models/post.dart';
import 'package:flutter/material.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final String url;
  final bool play;
  final String username;

  const VideoWidget({Key key, @required this.url, @required this.play, @required this.username})
      : super(key: key);
  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });

    if (widget.play) {
      _controller.play();
      _controller.setLooping(true);
    }
  }

  @override
  void didUpdateWidget(VideoWidget oldWidget) {
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        _controller.play();
        _controller.setLooping(true);
      } else {
        _controller.pause();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              ListTile(
                title: Text(widget.username),
              ),
              VideoPlayer(_controller)
            ]
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class VideoList extends StatelessWidget {
  final List<Post> posts;
  VideoList({this.posts});

  List<Widget> listVideos() {
    List<Widget> videos = List<Widget>();
    for (int i = 0; i < posts.length; i++) {
      videos.add(
        Wrap(
          // width: double.infinity,
          // height: 250.0,
          // alignment: Alignment.center,
          // margin: EdgeInsets.symmetric(vertical: 50.0),
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final InViewState inViewState = InViewNotifierList.of(context);
                inViewState.addContext(context: context, id: '$i');
                return AnimatedBuilder(
                  animation: inViewState,
                  builder: (BuildContext context, Widget child) {
                    return VideoWidget(
                      play: inViewState.inView('$i'),
                      url: posts[i].videos[0].urlVideo,
                      username: posts[i].author.name,
                    );
                  },
                );
              },
            ),
          ]
        ),
      );
    }
    return videos;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      // fit: StackFit.expand,
      children: <Widget>[
        InViewNotifierList(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          initialInViewIds: ['0'],
          isInViewPortCondition:
              (double deltaTop, double deltaBottom, double viewPortDimension) {
            return deltaTop < (0.5 * viewPortDimension) &&
                deltaBottom > (0.5 * viewPortDimension);
          },
          children: listVideos(),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 1.0,
            color: Colors.redAccent,
          ),
        )
      ],
    );
  }
}
//
// class ListPost extends StatefulWidget {
//   @override
//   _ListPostState createState() => _ListPostState();
// }
//
// class _ListPostState extends State<ListPost> {
//   UserViewModel account;
//   UserViewModel model;
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     account = Provider.of<UserViewModel>(context, listen: false);
//     model = ModalRoute.of(context).settings.arguments;
//     return Consumer<PostViewModel>(
//         builder: (context, postVm, child){
//             List<Widget> children = [];
//             postVm.listPostVideo.forEach((post) {
//               children.add(PostWidget(post: post,));
//             });
//             return Column(
//               children: children,
//             );
//         }
//     );
//   }
// }
