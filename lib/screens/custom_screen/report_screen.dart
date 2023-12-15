import 'dart:collection';

import 'package:fake_app/models/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../send_report.dart';

class ReportScreen extends StatefulWidget {
  String problem = null;
  String detail = null;
  Post post;
  int action = null;
  final List<String> problem_list = ['Ảnh khỏa thân', 'Bạo lực', 'Quấy rối', 'Tự tử/Tự gây thương tích', 'Tin giả', 'Spam', 'Bán hàng trái phép', 'Ngôn từ gây thù ghét', 'Khủng bố'];
  final Map<String, String> describe_list = {
    'Ảnh khỏa thân': "Hãy giúp chúng tôi hiểu vấn đề.",
    'Bạo lực': "Hãy giúp chúng tôi hiểu vấn đề.",
    'Quấy rối': "Ai đang bị quấy rối?",
    'Bán hàng trái phép': "Hãy giúp chúng tôi hiểu vấn đề.",
    'Ngôn từ gây thù ghét': "Hãy giúp chúng tôi hiểu vấn đề.",
  };
  final Map<String, List<String>> detail_list = {
    'Ảnh khỏa thân': ['Ảnh khỏa thân người lớn','Gợi dục','Hoạt động tình dục', 'Bóc lột tình dục', 'Dịch vụ tình dục', 'Liên quan đến trẻ em', 'Chia sẻ hình ảnh riêng tư'],
    'Bạo lực': ['Hình ảnh bạo lực', 'Tử vong hoặc bị thương nặng', 'Mối đe dọa bạo lực', 'Ngược đãi động vật', 'Vấn đề khác'],
    'Quấy rối': ['Tôi', 'Một người bạn'],
    'Bán hàng trái phép': ['Chất cấm, chất gây nghiện', 'Vũ khí', 'Động vật có nguy cơ bị tuyệt chủng', 'Động vật khác', 'Vấn đề khác'],
    'Ngôn từ gây thù ghét': ['Chủng tộc hoặc sắc tộc', 'Nguồn gốc quốc gia', 'Thành phần tôn giáo', 'Phân chia giai cấp xã hội', 'Thiên hướng tình dục', 'Giới tính hoặc bản dạng giới', 'Tình trạng khuyết tật hoặc bệnh tật', 'Hạng mục khác']
  };

  ReportScreen({this.post});
  @override
  State<StatefulWidget> createState() {
    return _ReportScreen();
  }
}

class _ReportScreen extends State<ReportScreen> {
  Widget _get_bottom_sheet_button() {
    var button_color = null;
    var str_color = null;
    if (widget.problem==null || (widget.describe_list.containsKey(widget.problem) && widget.detail==null)) {
      button_color = Colors.black12;
      str_color = Colors.black26;
    } else {
      button_color = Colors.lightBlue;
      str_color = Colors.white;
    }
    return SizedBox(
      height: 50,
      child: Container(
          padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black26))),
          child: FlatButton(
            child: Text("Tiếp", style: TextStyle(fontWeight: FontWeight.bold, color: str_color)),
            color: button_color,
            onPressed: () {
              if (widget.problem!=null && (widget.detail!=null || !widget.describe_list.containsKey(widget.problem))) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SendReport(post: widget.post, problem: widget.problem, detail: widget.detail,action: widget.action))
                );
              }
            },
          )
      ),
    );
  }

  List<Widget> _get_list_problem_view() {
    return widget.problem_list.map((e) => InkWell(
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: BoxDecoration(border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(12), color: widget.problem==e?Colors.lightBlue:Colors.black12,
        ),
        child: Text(e, style: TextStyle(fontSize: 13, color: widget.problem==e?Colors.white:Colors.black, fontWeight: FontWeight.bold)),
      ),
      onTap: () {
        this.setState(() {
          if (widget.problem==e) {
            widget.problem=null;
            widget.detail=null;
          } else {
            widget.problem=e;
          }
        });
      },
    )).toList();
  }

  Widget _get_list_detail_option_view() {
    return Wrap(
        spacing: 5,
        runSpacing: 8,
        children: widget.detail_list[widget.problem].map((e)=> InkWell(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(12), color: widget.detail==e?Colors.lightBlue:Colors.black12,
            ),
            child: Text(e, style: TextStyle(fontSize: 13, color: widget.detail==e?Colors.white:Colors.black, fontWeight: FontWeight.bold)),
          ),
          onTap: () {
            this.setState(() {
              if (widget.detail==e) {
                widget.detail=null;
              } else {
                widget.detail=e;
              }
            });
          },
        )).toList()
    );
  }

  Widget _get_detail_view() {
    if (widget.problem == null || !widget.describe_list.containsKey(widget.problem)) {
      return SizedBox(height: 0,);
    }
    return Container(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Text(widget.describe_list[widget.problem], style: TextStyle(color: Colors.black)),
          ),
          _get_list_detail_option_view(),
        ],
      ),
    );
  }

  Widget _get_action_button(int act) {
    var str_1 = ["Chặn ", "Bỏ theo dõi "];
    var str_2 = ["Các bạn sẽ không thể nhìn thấy hoặc liên hệ với nhau.", "Dừng xem bài viết từ người dùng này nhưng vẫn là bạn bè."];
    var icon = [Icons.person_remove_alt_1_outlined, Icons.unsubscribe_outlined];
    var bg_color = null;
    if (widget.action==act) {
      bg_color = Colors.black12;
    } else {
      bg_color = Colors.transparent;
    }
    return InkWell(
      child: ListTile(
        tileColor: bg_color,
        leading: Icon(icon[act], size: 30, color: Colors.black,),
        title: Text(str_1[act]+widget.post.author.name, style: TextStyle(fontSize: 16, color: Colors.black),),
        subtitle: Text(str_2[act], style: TextStyle(fontSize: 13, color: Colors.black45),),
      ),
      onTap: () {
        this.setState(() {
          if (widget.action==null || widget.action!=act) {
            widget.action = act;
          } else {
            widget.action = null;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(46),
        child: AppBar(
          backgroundColor: Colors.white,
          title: Text("Báo cáo", style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),),
          centerTitle: true,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: FlatButton(
                  child: Icon(Icons.close, size: 23, color: Colors.black54),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
            )
          ],
        ),
      ),

      body: ListView(
        children: <Widget> [
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.announcement_rounded, color: Colors.amber[600], size: 26,),
                  SizedBox(height: 4,),
                  Text("Vui lòng chọn vấn đề để tiếp tục", style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold)),
                  SizedBox(height: 2,),
                  Text("Bạn có thể báo cáo bài viết sau khi chọn vấn đề.", style: TextStyle(fontSize: 15, color: Colors.black)),
                  SizedBox(height: 13,),
                  Wrap(
                      spacing: 5,
                      runSpacing: 8,
                      children: _get_list_problem_view()
                  ),
                ]
            ),
          ),

          _get_detail_view(),

          Divider(color: Colors.black26, thickness: 1,),

          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                Text("Các bước khác mà bạn có thể thực hiện", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),),
                SizedBox(height: 20),
                _get_action_button(0),
                SizedBox(height: 8),
                _get_action_button(1),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 13, 5, 13),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(5)),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Icon(Icons.warning_outlined, size: 20, color: Colors.black38), flex: 2),
                      Expanded(child: Text("Nếu bạn nhận thấy ai đó đang gặp nguy hiểm, đừng chần chừ mà hãy báo ngay cho dịch vụ cấp cứu tại địa phương.",
                          style: TextStyle(color: Colors.black54)), flex: 10)
                    ],
                  ),
                )
              ],
            ),
          ),

          SizedBox(height: 60,)
        ],
      ),
      bottomSheet: _get_bottom_sheet_button(),
    );
  }
}