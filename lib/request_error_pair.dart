import 'package:downloader/request.dart';

class RequestErrorPair {
  Request first;
  String second;
  RequestErrorPair(this.first, this.second);
  RequestErrorPair.fromJson(Map<String, dynamic> map)
      : first = Request.fromJson(map["first"]),
        second = map["second"];
}
