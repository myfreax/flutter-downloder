import 'dart:io';

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
                      "http://speedtest.ftp.otenet.gr/files/test1Mb.db",
                      "${directory.path}/test1Mb.db");
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
