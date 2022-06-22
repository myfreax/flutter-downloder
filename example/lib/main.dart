import 'dart:io';

import 'package:downloader/download.dart';
import 'package:downloader/file_url.dart';
import 'package:downloader/status.dart';
import 'package:flutter/material.dart';

import 'package:downloader/downloader.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Directory directory;
  Map<int, int> fileProgressMap = {};
  int travelId = 5624;
  double currentProgress = 0;
  String eventName = '';

  ///final directory = await getApplicationDocumentsDirectory();
  int downloadId;
  final downloader = Downloader();
  int completedFileCount = 0;

  void updateDownloadProgress() {
    int totalProgress = fileProgressMap.length * 100;
    fileProgressMap.forEach((key, progress) {
      if (progress == 100) {
        completedFileCount++;
      }
      currentProgress += progress;
    });
    setState(() {
      eventName = "onProgress";
      completedFileCount = completedFileCount;
      currentProgress = currentProgress / totalProgress;
    });
  }

  final List<dynamic> _list = [
    {
      "createTime": "2022-03-04T14:52:57",
      "remark": "",
      "id": 124,
      "name": "接受任务，唤醒沉睡的国王",
      "status": 0,
      "code": "PR00000124",
      "spec": "新版本测试，勿删",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-04T14:58:57",
          "remark": "",
          "id": 20,
          "processId": 124,
          "number": 1,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000230/323957534/01-情景故事.mp4",
          "audioUrl": "",
          "fileName": "01-情景故事.mp4",
          "coverImg": "",
          "whetherUnlock": false,
          "answerList": [
            {
              "id": 99,
              "type": 6,
              "content": "测试问答题目",
              "playTime": 5,
              "createTime": "2022-06-13 07:22:23",
              "errorHint":
                  "https://xtckc.oss-cn-beijing.aliyuncs.com/dev/answer/file/745742688/01-空气炮故事起源.mp4",
              "errorHintType": null,
              "answerSolutionList": [
                {
                  "id": 612,
                  "answerId": 99,
                  "content": "123",
                  "subjectOptions": "A",
                  "checked": true,
                  "createTime": "2022-06-13 07:34:19"
                },
                {
                  "id": 613,
                  "answerId": 99,
                  "content": "456",
                  "subjectOptions": "B",
                  "checked": false,
                  "createTime": "2022-06-13 07:34:19"
                }
              ],
            }
          ],
          "stimulateList": [
            {
              "id": 3,
              "stimulateName": "激励组件测试-2",
              "stimulateDesc": "激励组件测试",
              "contentType": 1,
              "playTime": 8,
              "stimulateContent":
                  "https://xtckc.oss-cn-beijing.aliyuncs.com/dev/mp3-json/incentiveComponent/-1681026631/ans_success.json",
              "stimulateStatus": 0,
              "createTime": "2022-05-19 11:33:07"
            }
          ],
        },
        {
          "createTime": "2022-03-04T14:59:19",
          "remark": "",
          "id": 29,
          "processId": 124,
          "number": 2,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000231/-22190843/01-材料使用规范-组装木琴.mp4",
          "audioUrl": "",
          "fileName": "02-材料使用规范&组装木琴.mp4",
          "coverImg": "",
          "whetherUnlock": false
        },
      ],
      "journeyList": null,
      "whetherUnlock": false
    },
    {
      "createTime": "2022-03-24T16:29:44",
      "remark": "",
      "id": 148,
      "name": "编程环节",
      "status": 0,
      "code": "PR00000138",
      "spec": "视频、工程文件、问答混合",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-24T16:30:18",
          "remark": "",
          "id": 152,
          "processId": 115,
          "number": 1,
          "fileType": "sb3",
          "fileAddress": "",
          "audioUrl": "http://watchcdn.okii.com/smartwatchmgmt/quest.mp3",
          "fileName": "01-编程环节.sb3",
          "coverImg": "",
          "whetherUnlock": false,
          "projectInfo": {
            "projectID": "",
            "projectLoadName": "",
            "projectSaveName": ""
          },
          "taskTips": [
            {
              "id": "aa",
              "title": "任务提示",
              "type": "video",
              "content": {
                "videoUrl":
                    "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000208/02-%E7%94%9C%E7%94%9C%E5%9C%88%E8%82%A5%E7%9A%82%E5%88%B6%E4%BD%9C.mp4",
              }
            },
            {
              "id": "bb",
              "title": "任务提示",
              "type": "graphic",
              "content": {
                "text": '想要让头盔的灯在暗的环境下一直亮着，需要使用【重复执行】语句哦',
                "imageUrl":
                    "http://watchcdn.okii.com/smartwatchmgmt/aa123fsfa2431rssaf.jpg",
                "audioUrl": "http://watchcdn.okii.com/smartwatchmgmt/quest.mp3"
              }
            },
            {
              "id": "cc",
              "title": "任务提示",
              "type": "video",
              "content": {
                "videoUrl":
                    "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000208/02-%E7%94%9C%E7%94%9C%E5%9C%88%E8%82%A5%E7%9A%82%E5%88%B6%E4%BD%9C.mp4",
              }
            }
          ]
        }
      ],
      "journeyList": null,
      "whetherUnlock": false
    },
    {
      "createTime": "2022-03-24T16:29:44",
      "remark": "",
      "id": 148,
      "name": "编程环节",
      "status": 0,
      "code": "PR00000138",
      "spec": "视频、工程文件、问答混合",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-24T16:30:18",
          "remark": "",
          "id": 152,
          "processId": 115,
          "number": 1,
          "fileType": "sb3",
          "fileAddress": "",
          "audioUrl": "http://watchcdn.okii.com/smartwatchmgmt/quest.mp3",
          "fileName": "01-编程环节.sb3",
          "coverImg": "",
          "whetherUnlock": false,
          "projectInfo": {
            "projectID": "",
            "projectLoadName": "http://127.0.0.1:8080/sdfss.sb3",
            "projectSaveName": ""
          },
          "taskTips": [
            {
              "id": "aa",
              "title": "任务提示",
              "type": "video",
              "content": {
                "videoUrl":
                    "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000208/02-%E7%94%9C%E7%94%9C%E5%9C%88%E8%82%A5%E7%9A%82%E5%88%B6%E4%BD%9C.mp4",
              }
            },
            {
              "id": "bb",
              "title": "任务提示",
              "type": "graphic",
              "content": {
                "text": '想要让头盔的灯在暗的环境下一直亮着，需要使用【重复执行】语句哦',
                "imageUrl":
                    "http://watchcdn.okii.com/smartwatchmgmt/aa123fsfa2431rssaf.jpg",
                "audioUrl": "http://watchcdn.okii.com/smartwatchmgmt/quest.mp3"
              }
            },
            {
              "id": "cc",
              "title": "任务提示",
              "type": "video",
              "content": {
                "videoUrl":
                    "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000208/02-%E7%94%9C%E7%94%9C%E5%9C%88%E8%82%A5%E7%9A%82%E5%88%B6%E4%BD%9C.mp4",
              }
            }
          ]
        }
      ],
      "journeyList": null,
      "whetherUnlock": false
    },
    {
      "createTime": "2022-03-04T14:54:25",
      "remark": "",
      "id": 125,
      "name": "敲打木琴，唤醒国王有效果",
      "status": 0,
      "code": "PR00000125",
      "spec": "新版本测试，勿删",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-30T08:56:23",
          "remark": "",
          "id": 145,
          "processId": 125,
          "number": 1,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000231/-933451773/02-原理讲解.mp4",
          "audioUrl": "",
          "fileName": "01-讲解.mp4",
          "coverImg": "",
          "whetherUnlock": false
        }
      ],
      "journeyList": null,
      "whetherUnlock": false
    },
    {
      "createTime": "2022-03-24T16:29:44",
      "remark": "",
      "id": 138,
      "name": "脑洞打开，升级改造木琴",
      "status": 0,
      "code": "PR00000138",
      "spec": "视频、工程文件、问答混合",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-24T16:30:18",
          "remark": "",
          "id": 106,
          "processId": 138,
          "number": 1,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000232/944761250/01-组装鼓槌.mp4",
          "audioUrl": "",
          "fileName": "01-组装鼓槌.mp4",
          "coverImg": "",
          "whetherUnlock": false
        },
        {
          "createTime": "2022-03-24T16:30:26",
          "remark": "",
          "id": 108,
          "processId": 138,
          "number": 2,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000232/-208002803/02-组装支架.mp4",
          "audioUrl": "",
          "fileName": "02-组装支架.mp4",
          "coverImg": "",
          "whetherUnlock": false
        },
        {
          "createTime": "2022-03-24T16:30:24",
          "remark": "",
          "id": 107,
          "processId": 138,
          "number": 3,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000232/1891726931/03-组装滚筒.mp4",
          "audioUrl": "",
          "fileName": "03-组装滚筒.mp4",
          "coverImg": "",
          "whetherUnlock": false
        },
        {
          "createTime": "2022-03-24T16:30:56",
          "remark": "",
          "id": 110,
          "processId": 138,
          "number": 5,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000232/-1449483047/04-组装齿轮.mp4",
          "audioUrl": "",
          "fileName": "04-组装齿轮.mp4",
          "coverImg": "",
          "whetherUnlock": false
        }
      ],
      "journeyList": null,
      "whetherUnlock": false
    },
    {
      "createTime": "2022-03-24T16:29:44",
      "remark": "",
      "id": 148,
      "name": "解决最后难题，任务完成",
      "status": 0,
      "code": "PR00000138",
      "spec": "视频、工程文件、问答混合",
      "swipingPolicy": 1,
      "areaId": null,
      "areaName": null,
      "contentList": [
        {
          "createTime": "2022-03-24T16:30:18",
          "remark": "",
          "id": 146,
          "processId": 138,
          "number": 1,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000233/842234677/01-组装梳子牙.mp4",
          "audioUrl": "",
          "fileName": "01-组装梳子牙.mp4",
          "coverImg": "",
          "whetherUnlock": false
        },
        {
          "createTime": "2022-03-24T16:30:26",
          "remark": "",
          "id": 149,
          "processId": 138,
          "number": 2,
          "fileType": "video/mp4",
          "fileAddress":
              "https://xtckc.oss-cn-beijing.aliyuncs.com/prod/process-file/PR00000233/-1639655975/02-知识总结回顾.mp4",
          "audioUrl": "",
          "fileName": "02-知识总结回顾.mp4",
          "coverImg": "",
          "whetherUnlock": false
        }
      ],
      "journeyList": null,
      "whetherUnlock": false
    }
  ];

  Future<List<dynamic>> getMockData(int travelId) async {
    return _list;
  }

  void searchUrlsFromMap(object, List<String> urls) {
    if (object is List) {
      for (dynamic item in object) {
        if (item is String && item.startsWith(RegExp(r'http|https'))) {
          urls.add(item);
        }
        searchUrlsFromMap(item, urls);
      }
    } else if (object is Map) {
      for (dynamic item in object.values) {
        if (item is String && item.startsWith(RegExp(r'http|https'))) {
          urls.add(item);
        }
        searchUrlsFromMap(item, urls);
      }
    }
  }

  Future<FileURL> createStorePath(String url, int travelId) async {
    Directory rootDirectory = await getExternalStorageDirectory();
    final uri = Uri.parse(url);
    String uriPath = uri.pathSegments
        .sublist(0, uri.pathSegments.length - 1)
        .join(separator);
    String filePath =
        "${rootDirectory.path}${separator}travel$separator$travelId${uri.path}";
    String path =
        "${rootDirectory.path}${separator}travel$separator$travelId$separator$uriPath";
    await Directory(path).create(recursive: true);
    return FileURL(filePath, url);
  }

  Future<List<FileURL>> createFileURLsFromMap(List<dynamic> data) async {
    final urls = <String>[];
    searchUrlsFromMap(data, urls);
    List<Future<FileURL>> fileUrlFutures = urls.map((e) {
      return createStorePath(e, travelId);
    }).toList();
    List<FileURL> fileUrls = await Future.wait(fileUrlFutures);
    return fileUrls;
  }

  Future<List<FileURL>> createFileURLs(List<String> urls) async {
    List<Future<FileURL>> fileUrlFutures = urls.map((e) {
      return createStorePath(e, travelId);
    }).toList();
    List<FileURL> fileUrls = await Future.wait(fileUrlFutures);
    return fileUrls;
  }

  @override
  void initState() {
    downloader.onCompleted =
        ((download) => fileProgressMap[download.id] = download.progress);
    downloader.onDownloadBlockUpdated = (download, downloadBlock, totalBlocks) {
      setState(() {
        eventName = "onDownloadBlockUpdated";
      });
    };
    downloader.onProgress =
        ((download, etaInMilliSeconds, downloadedBytesPerSecond) {
      fileProgressMap[download.id] = download.progress;
      updateDownloadProgress();
    });
    super.initState();
  }

  //@override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    ///super.didChangeAppLifecycleState(state);

    // These are the callbacks
    switch (state) {
      case AppLifecycleState.resumed:
        print("AppLifecycleState.resumed");
        List<Download> downloads =
            await downloader.getDownloadsInGroup(travelId);
        // widget is resumed
        break;
      case AppLifecycleState.inactive:
        print("AppLifecycleState.inactive");
        // widget is inactive
        break;
      case AppLifecycleState.paused:
        print("AppLifecycleState.paused");
        // widget is paused
        break;
      case AppLifecycleState.detached:
        print("AppLifecycleState.detached");
        // widget is detached
        break;
    }
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isDenied || status.isRestricted) {
      if (await Permission.storage.request().isGranted) {
        return true;
      } else {
        throw Exception("Permission Denied");
      }
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              LinearPercentIndicator(
                lineHeight: 14.0,
                percent: currentProgress,
                backgroundColor: Colors.white,
                progressColor: Colors.blue,
              ),
              Text("completedFileCount :$completedFileCount"),
              TextButton(
                onPressed: () async {
                  final directory = await getApplicationDocumentsDirectory();
                  downloadId = await downloader.download(
                      "https://speed.hetzner.de/10GB.bin",
                      "${directory.path}/10GB.bin");
                  print("start download");
                },
                child: const Text("start"),
              ),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      await downloader.pause(downloadId);
                      print("pause download");
                    }
                  },
                  child: const Text("pause")),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      await downloader.resume(downloadId);
                      print("resume download");
                    }
                  },
                  child: const Text("resume")),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      await downloader.remove([downloadId]);
                      print("removed");
                    }
                  },
                  child: const Text("remove")),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      var ids = [downloadId];
                      downloader.delete([downloadId]);
                      print("Delete");
                    }
                  },
                  child: const Text("Delete")),
              TextButton(
                  onPressed: () async {
                    // List<dynamic> value = await getMockData(travelId);
                    // List<FileURL> fileUrls = await createFileURLsFromMap(value);

                    //http://speedtest.ftp.otenet.gr/files/test100k.db
                    //http://speedtest.ftp.otenet.gr/files/test1Mb.db
                    //http://speedtest.ftp.otenet.gr/files/test100Mb.db
                    //http://speedtest.ftp.otenet.gr/files/test1Gb.db
                    final urls = [
                      "http://speedtest.ftp.otenet.gr/files/test100k.db",
                      "http://speedtest.ftp.otenet.gr/files/test1Mb.db",
                      "http://speedtest.ftp.otenet.gr/files/test100Mb.db",
                      "http://speedtest.ftp.otenet.gr/files/test1Gb.db"
                    ];
                    List<FileURL> fileUrls = await createFileURLs(urls);
                    var reqWithErr =
                        await downloader.groupingDownload(fileUrls, travelId);
                    print(reqWithErr);
                  },
                  child: const Text("groupingDownload")),
              TextButton(
                  onPressed: () async {
                    await requestStoragePermission();
                  },
                  child: const Text("request Storage permission")),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      var result = await downloader.getDownloads();
                      print(result);
                    }
                  },
                  child: const Text("getDownloads")),
              TextButton(
                  onPressed: () async {
                    var result = await downloader.getDownloadsInGroup(travelId);
                    print(result);
                  },
                  child: const Text("getDownloadsInGroup")),
              TextButton(
                  onPressed: () async {
                    if (!downloadId.isNaN) {
                      var result = await downloader
                          .getDownloadsWithStatus(Status.DOWNLOADING);
                      print(result);
                    }
                  },
                  child: const Text("getDownloadsWithStatus"))
            ],
          )),
    );
  }
}
