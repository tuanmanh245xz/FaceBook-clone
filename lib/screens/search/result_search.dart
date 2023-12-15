import 'package:fake_app/models/post.dart';
import 'package:fake_app/screens/custom_widget/post_widget.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/constants/constants_colors.dart';
import 'package:fake_app/utils/constants/constants_strings.dart';
import 'package:fake_app/utils/helper/color_helper.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ResultSearchScreen extends StatefulWidget {
  static String route = "result_search";
  ResultSearchScreen({this.keyWord, this.isSearchPersonalUser});
  final String keyWord;
  final bool isSearchPersonalUser;
  @override
  _ResultSearchScreenState createState() => _ResultSearchScreenState();
}

class _ResultSearchScreenState extends State<ResultSearchScreen> with TickerProviderStateMixin {
  static const DEFAULT_COUNT_ITEM = 10;
  UserViewModel _userViewModel;
  TextEditingController _tfController;
  TabController _tabController;
  int _index;
  String lastId;
  Future<List<Post>> futureListPost;
  List<String> titleSearch = ["Tất cả", "Bài viết", "Mọi người", "Sự kiện", "Nhóm", "Ảnh", "Video"];
  ScrollController _scrollController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _index = 0;
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    _getResultSearch(widget.keyWord);
    _tfController = TextEditingController();
    _tabController = TabController(length: titleSearch.length, vsync: this);
    _tabController.index = 1;
    _tfController.text = widget.keyWord;
    _initScroll();
  }

  void _initScroll(){
    _scrollController = ScrollController();
    _scrollController.addListener(() {

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tfController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: RefreshIndicator(
        onRefresh: _onRefreshSearch,
        child: _getBody()
      ),
      backgroundColor: HexColor(ConstColor.color_grey),
    );
  }

  AppBar _getAppBar(){
    return AppBar(
      title: Container(
        height: 40,
        child: _getTextFieldSearch()
      ),
      actions: [
        IconButton(icon: Icon(Icons.filter_alt_outlined), onPressed: null)
      ],
    );
  }


  Widget _getBody(){
    return Column(
      children: <Widget>[
        Container(
          color: HexColor(ConstColor.color_white),
          child: TabBar(
            onTap: (index) => _onTapTabBar(index),
            tabs: titleSearch.map((title) => Tab(
              child: Text(
                title,
              ),
            )).toList(),
            unselectedLabelColor: HexColor(ConstColor.text_color_grey),
            labelColor: HexColor(ConstColor.text_color_blue),
            controller: _tabController,
            isScrollable: true,
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: FutureBuilder(
              future: futureListPost,
              builder: (context, snapshot){
                if(snapshot.connectionState != ConnectionState.done){
                  return Center(
                    child: Constant.getDefaultCircularProgressIndicator(40, color: ConstColor.color_white),
                  );
                }
                if(snapshot.connectionState == ConnectionState.done && snapshot.hasData){
                  List<Post> posts = snapshot.data;
                  if(posts.length == 0){
                    return LayoutBuilder(
                      builder: (context, constraints){
                        return ListView(
                          children: <Widget>[
                            Container(
                              height: constraints.maxHeight,
                              child: Center(
                                child: Text(
                                  ConstString.no_result_search,
                                  style: Theme.of(context).textTheme.headline6.copyWith(color: HexColor(ConstColor.text_color_grey)),
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    );
                  }else{
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: posts.length,
                      itemBuilder: (context, index){
                        return Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: PostWidget(
                            post: posts[index],
                          ),
                        );
                      },
                    );
                  }
                }
                if (snapshot.connectionState == ConnectionState.done){
                  return Center(
                    child: Constant.getNoInternetWidget(context),
                  );
                }
                return Center(
                  child: Constant.getDefaultCircularProgressIndicator(20),
                );
              },
            ),
          )
        )
      ],
    );
  }

  Widget _getTextFieldSearch(){
    return TextField(
      controller: _tfController,
      onChanged: (value) => _onPressChange(value),
      onSubmitted: (value) => _onPressSearch(value),
      onTap: (){
        Navigator.of(context).pop();
      },
      decoration: _getInputDecoration(),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
        hintText: 'Tìm kiếm',
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        border: OutlineInputBorder(
            borderSide: BorderSide(width: 0, color: Colors.transparent),
            borderRadius: BorderRadius.circular(20)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, color: Colors.transparent)
        ),
        fillColor: HexColor(ConstColor.grey_fake_transparent),
        filled: true
    );
  }

  void _getResultSearch(String keyWord) async {
    var response = await FakeBookService().search(_userViewModel.user.token, keyWord, widget.isSearchPersonalUser ? _userViewModel.user.id : "", _index, DEFAULT_COUNT_ITEM);
    if(response != null){
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          var data = response['data'];
          List<Post> listPost = List();
          if(data != null && data.length > 0){
            listPost = (data['posts'] as List).map((post) => Post.fromJson(post)).toList();
            lastId = data['last_id'];
          }
          _index += listPost.length;
          setState(() {
            futureListPost = Future.value(listPost);
          });
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        case ConstantCodeMessage.USER_IS_NOT_VALIDATED:
          ErrorHelper.instance.errorUserIsNotValidate(context);
          return;
        case ConstantCodeMessage.PARAM_VALUE_INVALID:
          setState(() {
            futureListPost = Future.value(List());
          });
          return;
        default:
          break;
      }
    }
    setState(() {
      futureListPost = Future.value(null);
    });
  }

  _onPressChange(String value) {}

  _onPressSearch(String value) {}

  Future<void> _onRefreshSearch() async {
    print(widget.keyWord);
    _index = 0;
    _getResultSearch(widget.keyWord);
  }

  _onTapTabBar(int index) {

  }
}
