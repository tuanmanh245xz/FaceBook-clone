
import 'package:fake_app/models/post.dart';
import 'package:fake_app/service/fakebook_service.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:fake_app/utils/helper/error_helper.dart';
import 'package:fake_app/view_models/user_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SendReport extends StatefulWidget{
  Post post;
  String problem;
  String detail;
  int action;
  SendReport({this.post, this.problem, this.detail, this.action});

  @override
  State<StatefulWidget> createState() {
    return _SendReport();
  }
}

class _SendReport extends State<SendReport> {
  bool _get_result = false;
  String _result = null;
  UserViewModel _userViewModel;

  void _send_request() async {
    var response = await FakeBookService().report(_userViewModel.user.token, widget.post, widget.problem, widget.detail, widget.action);
    if (response!=null) {
      _get_result = true;
      switch(int.parse(response['code'])){
        case ConstantCodeMessage.OK:
          setState(() {
            _result = "Thành công!";
          });
          return;
        case ConstantCodeMessage.TOKEN_INVALID:
          ErrorHelper.instance.errorTokenInValid(context);
          return;
        case ConstantCodeMessage.POST_IS_NOT_EXISTED:
          setState(() {
            _result = "Bài viết không tồn tại.";
          });
          return;
        case ConstantCodeMessage.PARAM_NOT_ENOUGHT:
          setState(() {
            _result = "Lỗi thực thi.";
          });
          return;
        case ConstantCodeMessage.CANNOT_CONNECT_TO_DB:
          setState(() {
            _result = "Server không khả dụng.";
          });
          return;
        case ConstantCodeMessage.ACTION_HAS_BEEN_DONE:
          setState(() {
            _result = "Bài viết đã bị khóa.";
          });
          return;
        case ConstantCodeMessage.EXCEPTION_ERROR:
          setState(() {
            _result = "Lỗi thực thi.";
          });
          return;
        default:
          setState(() {
            _result = "Lỗi thực thi.";
          });
          return;
      }
    }
  }

  Widget _get_display_content() {
    if (_get_result==false) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Gửi yêu cầu ...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20,),
          Constant.getDefaultCircularProgressIndicator(20)
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(_result, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          SizedBox(height: 20,),
          InkWell(
            child: Text("Trở về", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black38)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  }

  @override
  void initState() {
    _userViewModel = Provider.of<UserViewModel>(context, listen: false);
    super.initState();
    _send_request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _get_display_content(),
        )
    );
  }
}