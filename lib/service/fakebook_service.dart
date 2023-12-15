import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fake_app/utils/constants/config.dart';
import 'package:fake_app/utils/helper/check_helper.dart';
import 'package:fake_app/models/comment.dart';
import 'package:fake_app/utils/constants/constants.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;

import '../models/post.dart';

class FakeBookService {
  //String baseUrl = "https://fakebook-api-team-15.herokuapp.com/";
  String baseUrl = AppConfig.API_URL;

  Future<Map<String, dynamic>> signUp(
      String phoneNumber, String password) async {
    if (CheckHelper.isValidParameterSignUp(phoneNumber, password)) {
      var response = await http.post(baseUrl + "signup",
          body: {
            "phonenumber": phoneNumber,
            "password": password,
          },
          encoding: Encoding.getByName("UTF-8"));
      if (response.statusCode == 200) {
        return json.decode(response.body).cast < Map<String, dynamic>();
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> login(
      String phoneNumber, String password, String uuid) async {
    var response = await http.post(
      baseUrl + "login",
      body: <String, String>{
        "phonenumber": phoneNumber,
        "password": password,
        "uuid": uuid
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>> check_token(String token) async {
    var response =
        await http.post(baseUrl + "check_token", body: {"token": token});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>> logout(String token) async {
    var response = await http.post(baseUrl + "logout",
        body: {"token": token}, encoding: Encoding.getByName("UTF-8"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>> getVerifyCode(String phoneNumber) async {
    var response = await http.post(baseUrl + "get_verify_code",
        body: {"phonenumber": phoneNumber},
        encoding: Encoding.getByName("UTF-8"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>> checkVerifyCode(
      String phoneNumber, String codeVerify) async {
    var response = await http.post(baseUrl + "check_verify_code",
        body: {"phonenumber": phoneNumber, "code_verify": codeVerify},
        encoding: Encoding.getByName("UTF-8"));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>> changeInfoAfterSignUp(
      String token, String userName, String avatar) async {
    var response = await http.post(baseUrl + "change_info_after_signup",
        body: {"token": token, "username": userName, "avatar": avatar});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>> customSignUp(
      String phoneNumber, String password, String uuid, String userName) async {
    uuid = "abc";
    phoneNumber = phoneNumber.trim();
    password = password.trim();
    uuid = uuid.trim();
    print('Phone Number $phoneNumber');
    print('Password $password');

    if (CheckHelper.isValidParameterSignUp(phoneNumber, password)) {
      var response = await http.post(baseUrl + "signup",
          body: {
            "phonenumber": phoneNumber.trim(),
            "password": password.trim(),
          },
          encoding: Encoding.getByName("UTF-8"));
      if (response.statusCode == 200) {
        var res = json.decode(response.body);
        print(res);
        if (int.parse(res['code']) == 1000) {
          var resLogin = await login(phoneNumber, password, uuid);
          if (resLogin != null && int.parse(resLogin['code']) == 1000) {
            var resChangeInfo = await changeInfoAfterSignUp(
                resLogin['data']['token'], userName, "");
            if (resChangeInfo != null &&
                int.parse(resChangeInfo['code']) == 1000) {
              return {
                "code": 1000,
                "id": resChangeInfo['data']['id'],
                "token": resLogin['data']['token']
              };
            } else {
              print('Cannot Change info');
            }
          } else {
            print('Cannot login');
          }
        } else {
          print('Cannot signup');
          return res;
        }
      } else {
        print('Error');
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> add_post(
      String token,
      List<String> images,
      List<File> videos,
      List<String> thumbs,
      String described,
      String status) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(baseUrl + "add_post"));
    request.fields['token'] = token;

    if (images != null && images.isNotEmpty) {
      request.fields['image'] = jsonEncode(images);
    }

    if (videos != null && videos.isNotEmpty) {
      for (int index = 0; index < videos.length; index++) {
        request.files.add(await http.MultipartFile.fromPath(
            'video', videos[index].path,
            contentType: MediaType("video", "mp4")));
      }
    }

    if (thumbs != null && thumbs.isNotEmpty) {
      request.fields['thumb'] = jsonEncode(thumbs);
    }

    request.fields['describe'] = described;
    request.fields['status'] = status;
    try {
      var response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> add_post2(
      String token,
      List<String> images,
      List<File> videos,
      List<String> thumbs,
      String described,
      String status) async {
    List<dio.MultipartFile> listVideos = List();

    for (int i = 0; i < videos.length; i++) {
      listVideos.add(await dio.MultipartFile.fromFile(videos[i].path,
          contentType: MediaType("video", "mp4")));
    }
    print('token $token');
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "described": described,
      "status": status,
      "image": jsonEncode(images),
      "thumb": jsonEncode(thumbs),
      "video": (listVideos.length > 0) ? listVideos.first : ""
    });

    try {
      var response = await dio.Dio().post(baseUrl + "add_post", data: formData);
      print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_post(String token, String id) async {
    var response = await http.post(baseUrl + "get_post",
        body: {'token': token, 'id': id},
        encoding: Encoding.getByName('UTF-8'));
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<Map<String, dynamic>> edit_post(
      String token,
      String id,
      String described,
      String status,
      List<String> images,
      List<String> imagesDel,
      List<int> imageSort,
      List<File> videos,
      List<String> thumbs,
      bool autoBlock,
      bool autoAccept) async {
    List<dio.MultipartFile> listVideos = List();
    for (int i = 0; i < videos.length; i++) {
      listVideos.add(await dio.MultipartFile.fromFile(videos[i].path,
          contentType: MediaType("video", "mp4")));
    }

    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "id": id,
      "described": described,
      "status": status,
      "image": jsonEncode(images),
      "image_del": jsonEncode(imagesDel),
      "image_sort": jsonEncode(imageSort),
      "thumb": jsonEncode(thumbs),
      "video": (listVideos.length > 0) ? listVideos.first : "",
      "auto_block": autoBlock ? "1" : "0",
      "auto_accept": autoAccept ? "1" : "0"
    });
    print('Token : $token');
    print('Id $id');
    print('Described $described');
    print('status $status');
    print('image ' + jsonEncode(images));
    print('image_del ' + jsonEncode(imagesDel));
    print('image_sort ' + jsonEncode(imageSort));
    print('thumb ' + jsonEncode(thumbs));
    print('video ' + videos.toString());
    print('autoblock $autoBlock');
    print('autoaccept $autoAccept');
    try {
      var response =
          await dio.Dio().post(baseUrl + "edit_post", data: formData);
      print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> delete_post(String token, String id) async {
    var response = await http.post(baseUrl + "delete_post",
        body: {"token": token, "id": id},
        encoding: Encoding.getByName('UTF-8'));
    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>> report_post(
      String token, String id, String subject, String details) async {
    var response = await http.post(baseUrl + "report_post",
        body: {
          "token": token,
          "id": id,
          "subject": subject,
          "details": details
        },
        encoding: Encoding.getByName("UTF-8"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<Map<String, dynamic>> like_post(String token, String id) async {
    try {
      var response = await http.post(baseUrl + "like_post",
          body: {"token": token, "id": id},
          encoding: Encoding.getByName("UTF-8"));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_comment(
      String token, String id, int index, int count) async {
    try {
      var response = await http.post(baseUrl + "get_comment", body: {
        "token": token,
        "id": id,
        "index": index.toString(),
        "count": count.toString()
      });
      print(response.body);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        return res;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_comment(
      String token, String id, String comment, int index, int count) async {
    try {
      var response = await http.post(baseUrl + "set_comment", body: {
        "token": token,
        "id": id,
        "comment": comment,
        "index": index.toString(),
        "count": count.toString()
      });

      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_list_posts(
      String token, String userId, int index, int count, String lastId) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "user_id": userId,
      "index": index,
      "count": count,
      "last_id": lastId
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response =
          await dio.Dio(options).post("get_list_posts", data: formData);
      print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_list_videos(
      String token, String userId, int count, String lastId) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "user_id": userId,
      "count": count,
      "last_id": lastId
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
    );
    try {
      var response =
      await dio.Dio(options).post("get_list_videos", data: formData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_request_friend(
      String token, String userId) async {
    try {
      var response = await http.post(baseUrl + "set_request_friend", body: {
        "token": token,
        "user_id": userId,
      });

      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> unfriend(
      String token, String userId) async {
    try {
      var response = await http.post(baseUrl + "unfriend", body: {
        "token": token,
        "user_id": userId,
      });

      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_accept_friend(
      String token, String userId, String is_accept) async {
    try {
      var response = await http.post(baseUrl + "set_accept_friend",
          body: {"token": token, "user_id": userId, "is_accept": is_accept});

      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_requested_friends(
      String token, int index, int count) async {
    dio.FormData formData =
        dio.FormData.fromMap({"token": token, "index": index, "count": count});
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response =
          await dio.Dio(options).post("get_requested_friends", data: formData);
      print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_list_suggested_friends(
      String token, int index, int count) async {
    dio.FormData formData =
        dio.FormData.fromMap({"token": token, "index": index, "count": count});
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response = await dio.Dio(options)
          .post("get_list_suggested_friends", data: formData);
      print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_user_friends(
      String token, String userId, int index, int count) async {
    dio.FormData formData = dio.FormData.fromMap(
        {"token": token, "user_id": userId, "index": index, "count": count});
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response =
          await dio.Dio(options).post("get_user_friends", data: formData);
      // print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> search(String token, String keyword,
      String user_id, int index, int count) async {
    print('Token $token');
    print('Keyword $keyword');
    print('UserId $user_id');
    print('index $index');
    print('Count $count');

    try {
      var response = await http.post(baseUrl + "search",
          body: {
            "token": token,
            "keyword": keyword.trim(),
            "user_id": user_id,
            "index": index.toString(),
            "count": count.toString()
          },
          encoding: Encoding.getByName("UTF-8"));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_save_search(
      String token, int index, int count) async {

    print('Token: $token');
    print('Index: $index');
    print('Count: $count');
    count = 5;

    try {
      var response = await http.post(baseUrl + "get_saved_search",
          body: {
            "token": token,
            "index": index.toString(),
            "count": count.toString()
          },
          encoding: Encoding.getByName('UTF-8'));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> del_saved_search(
      String token, String search_id, bool all) async {
    // all: 1 - xoa tat ca, 0: chi xoa search_id
    try {
      var response = await http.post(baseUrl + "del_saved_search",
          body: {
            'token': token,
            'search_id': search_id,
            'all': all ? "1" : "0"
          },
          encoding: Encoding.getByName('UTF-8'));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_user_info(
      String token, String userId) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "user_id": userId,
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response =
          await dio.Dio(options).post("get_user_info", data: formData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_user_info(
      String token, String username, String description, String address, String city,
      String country, String link, String avatar,String cover_image) async {
    try {
      var response = await http.post(
          baseUrl + "set_user_info",
          body : {
            "token" : token,
            "username": username,
            "description": description,
            "address": address,
            "city": city,
            "country": country,
            "link": link,
            "avatar": avatar,
            "cover_image": cover_image
          }
      );

      print(response.body);
      if (response.statusCode == 200){
        return jsonDecode(response.body);
      }
    } on Exception catch(e){
      print(e.toString());
    }
    return null;
  }


  Future<Map<String, dynamic>> get_conversation(String token, String partnerId, int index, int count) async {
    try {
      var response = await http.post(baseUrl + "get_conversation",
          body: {
            "token": token,
            "partner_id": partnerId,
            "index": index.toString(),
            "count": count.toString()
          },
          encoding: Encoding.getByName('UTF-8'));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_list_conversation(
      String token, int index, int count) async {
    try {
      var response = await http.post(baseUrl + "get_list_conversation",
          body: {
            "token": token.trim(),
            "index": index.toString(),
            "count": count.toString()
          },
          encoding: Encoding.getByName('UTF-8'));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> change_avatar(
      String token, String avatar) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "avatar": avatar,
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
        );
    try {
      var response =
          await dio.Dio(options).post("change_avatar", data: formData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> change_background(
      String token, String background) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "background": background,
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60 * 1000, // 60 seconds
        receiveTimeout: 60 * 1000 // 60 seconds
    );
    try {
      var response =
      await dio.Dio(options).post("change_background", data: formData);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_read_message(
      String token, String partnerId) async {
    try {
      var res = await http.post(baseUrl + "set_read_message",
          body: {
            "token": token,
            "partner_id": partnerId,
          },
          encoding: Encoding.getByName("UTF-8"));
      print(res.body);
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<Map<String, dynamic>> get_notification(String token, int index, int count) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "index": index,
      "count": count
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60*1000, // 60 seconds
        receiveTimeout: 60*1000 // 60 seconds
    );
    try {
      var response = await dio.Dio(options).post(
          "get_notification", data: formData);
      //print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch(e) {
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_read_notification(String token, String notification_id) async {
    try {
      var response = await http.post(
          baseUrl + "set_read_notification",
          body : {
            "token" : token,
            "notification_id": notification_id,
          }
      );

      print(response.body);
      if (response.statusCode == 200){
        return jsonDecode(response.body);
      }
    } on Exception catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> set_block(String token, String user_id, String type) async {
    try {
      var response = await http.post(
          baseUrl + "set_block",
          body : {
            "token" : token,
            "user_id": user_id,
            "type": type
          }
      );

      print(response.body);
      if (response.statusCode == 200){
        return jsonDecode(response.body);
      }
    } on Exception catch(e){
      print(e.toString());
    }
    return null;
  }

  Future<Map<String, dynamic>> get_list_blocks(String token, int index, int count) async {
    dio.FormData formData = dio.FormData.fromMap({
      "token": token,
      "index": index,
      "count": count
    });
    dio.BaseOptions options = new dio.BaseOptions(
        baseUrl: baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: 60*1000, // 60 seconds
        receiveTimeout: 60*1000 // 60 seconds
    );
    try {
      var response = await dio.Dio(options).post(
          "get_list_blocks", data: formData);
      //print(response.data);
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on Exception catch(e) {
      print(e.toString());
    }
    return null;
  }


  Future<Map<String,dynamic>> block(String token, String userid) async {
    var response = await http.post(
      baseUrl + "set_block",
      body : <String, String>{
        "token": token,
        "user_id" : userid,
        "type": "0"
      },
    );
    print(response.body);
    if (response.statusCode == 200){
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String,dynamic>> report(String token, Post post, String problem, String detail, int action) async {
    var response = await http.post(
      baseUrl + "report_post",
      body : <String, String>{
        "token": token,
        "id" : post.idPost,
        "subject": problem,
        "details" : detail!=null?detail:' '
      },
    );
    print(response.body);
    if (action==0) {
      await this.block(token, post.author.id);
    }
    if (response.statusCode == 200){
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }
 }