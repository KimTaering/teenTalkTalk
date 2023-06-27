import 'dart:convert';

FigResponse responseLoginFromJson(String str) =>
    FigResponse.fromJson(json.decode(str));

String responseLoginToJson(FigResponse data) => json.encode(data.toJson());

class FigResponse {
  bool resp;
  String message;
  String figCount;

  FigResponse({
    required this.resp,
    required this.message,
    required this.figCount,
  });

  factory FigResponse.fromJson(Map<String, dynamic> json) => FigResponse(
        resp: json["resp"],
        message: json["message"],
        figCount: json["figCount"],
      );

  Map<String, dynamic> toJson() => {
        "resp": resp,
        "message": message,
        "figCount": figCount,
      };
}
