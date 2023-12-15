
class Response {
  int code;
  String message;
  dynamic data;

  Response({this.code, this.message, this.data});

  factory Response.fromJson(Map<String, dynamic> json){
    return Response(
      code: json['code'] as int,
      message: json['message'] as String,
      data: json['data'] as String
    );
  }
}