import 'package:downloader/extras.dart';

class Request {
  String url;
  String file;
  int id;
  int autoRetryMaxAttempts;
  bool downloadOnEnqueue;
  String enqueueAction;
  Extras extras;
  int groupId;
  Map<String, dynamic> headers;
  int identifier;
  String networkType;
  String priority;
  Request(
      this.url,
      this.file,
      this.id,
      this.autoRetryMaxAttempts,
      this.downloadOnEnqueue,
      this.enqueueAction,
      this.extras,
      this.groupId,
      this.headers,
      this.identifier,
      this.networkType,
      this.priority);
  Request.fromJson(Map<String, dynamic> map)
      : url = map["url"],
        file = map["file"],
        id = map["id"],
        autoRetryMaxAttempts = map["autoRetryMaxAttempts"],
        downloadOnEnqueue = map["downloadOnEnqueue"],
        enqueueAction = map["enqueueAction"],
        extras = Extras.fromJson(map["extras"]),
        groupId = map["groupId"],
        headers = map["headers"],
        identifier = map["identifier"],
        networkType = map["networkType"],
        priority = map["priority"];
}
