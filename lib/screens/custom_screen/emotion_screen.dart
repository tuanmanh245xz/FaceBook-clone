import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';

import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';

class EmotionScreen extends StatefulWidget {
  static String route = "/emotion_screen";

  EmotionScreen({this.curEmotion});

  List<String> curEmotion;

  @override
  _EmotionScreenState createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen>
    with SingleTickerProviderStateMixin {

  TabController _tabController;
  TextEditingController _tdSearchControl;
  // For emotion
  static List<String> const_emotion = List.from(Constant.list_emotion);
  static List<String> const_emotion_mean = List.from(Constant.list_emotion_mean);
  List<String> emotion = List();
  List<String> emotionMean = List();
  List<String> curEmotion;
  // For action
  static List<String> const_action = List.from(Constant.list_action);
  static List<String> const_action_mean = List.from(Constant.list_action_mean);
  List<String> action = List();
  List<String> actionMean = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(
      vsync: this,
      length: 2,
    );
    _tdSearchControl = TextEditingController();
    const_emotion.forEach((element) { emotion.add(element); });
    const_emotion_mean.forEach((element) { emotionMean.add(element);});
    const_action.forEach((element) { action.add(element); });
    const_action_mean.forEach((element) { actionMean.add(element);});
    curEmotion = widget.curEmotion;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController.dispose();
    _tdSearchControl.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _onBack,
          ),
          title: Text(
            ConstString.how_do_you_feel,
            style: Theme.of(context).textTheme.headline6,
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: HexColor(ConstColor.text_color_blue),
            unselectedLabelColor: HexColor(ConstColor.text_color_grey),
            tabs: [
              Tab(
                icon: Text(
                  ConstString.emotion_,
                ),
              ),
              Tab(
                icon: Text(ConstString.activity),
              )
            ],
          ),
        ),
        body: _getBody()
    );
  }

  Widget _getBody() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[_getEmotionScreen(), _getActivityScreen()],
    );
  }

  Widget _getEmotionScreen() {
    return Column(
      children: [
        _getHeaderSearch(),
        Expanded(
          child: GridView.builder(
            itemCount: emotion.length,
            padding: EdgeInsets.all(0),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 10 / 4),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){
                  curEmotion = [emotion[index], emotionMean[index]];
                  _onBack();
                },
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor
                    ),
                  ),
                  padding: EdgeInsets.all(0),
                  margin: EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Image.asset(
                              "images/" + emotion[index] + ".png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          emotionMean[index],
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getActivityScreen() {
    return Column(
      children: <Widget>[
        _getHeaderSearch(),
        Expanded(
          child: GridView.builder(
            itemCount: action.length,
            padding: EdgeInsets.all(0),
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 10 / 4),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: (){
                },
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).dividerColor
                    ),
                  ),
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Image.asset(
                            "images/" + action[index] + ".png",
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: Text(
                          actionMean[index] + "...",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _getHeaderSearch() {
    return Container(
      child: (curEmotion == null) ? TextField(
        controller: _tdSearchControl,
        onChanged: (value) => _onChangeSearch(value),
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: HexColor(ConstColor.text_color_grey),
            ),
            hintText: ConstString.search,
            hintStyle: Theme.of(context)
                .textTheme
                .bodyText2
                .copyWith(color: HexColor(ConstColor.text_color_grey))),
        style: Theme.of(context).textTheme.bodyText2,
      ) : Container(
        padding: EdgeInsets.all(4),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Image.asset(
                "images/" + curEmotion[0] + ".png",
                width: 30,
                height: 30,
              ),
            ),
            Expanded(
              flex: 6,
              child: Text(
                'Đang cảm thấy ' + curEmotion[1],
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _onPressDeleteCurEmotion,
                icon: Icon(Icons.clear, size: 20, color: HexColor(ConstColor.text_color_grey),),
              ),
            )
          ],
        ),
      ),
    );
  }


  void _onChangeSearch(String textSearch) {
    emotion.clear();
    emotionMean.clear();

    if (textSearch.length == 0){
      setState(() {
        emotion = List.from(const_emotion);
        emotionMean = List.from(const_emotion_mean);
      });
    } else {
      textSearch = textSearch.toLowerCase();
      for (int index = 0; index < const_emotion_mean.length; index++){
        if (const_emotion_mean[index].toLowerCase().contains(textSearch)){
          setState(() {
            emotion.add(const_emotion[index]);
            emotionMean.add(const_emotion_mean[index]);
          });
        }
      }
    }
  }


  void _onPressDeleteCurEmotion() {
    setState(() {
      curEmotion = null;
    });
  }

  void _onBack(){
    Navigator.of(context).pop(curEmotion);
  }


}


