import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:downloader/download.dart';
import 'package:downloader/file_url.dart';
import 'package:downloader/request_error_pair.dart';
import 'package:downloader/status.dart';
import 'package:flutter/services.dart';

import 'package:downloader/download_block.dart';

class Downloader {
  final MethodChannel _channel = const MethodChannel('downloader');

  final EventChannel _downloaderEventChannel =
      const EventChannel('downloaderEventChannel');

  Function(Download download) onCompleted = ((download) => Void);

  Function(Download download, String error, String throwable) onError =
      ((download, error, throwable) => Void);

  Function(Download download, int etaInMilliSeconds,
          int downloadedBytesPerSecond) onProgress =
      ((download, etaInMilliSeconds, downloadedBytesPerSecond) => Void);

  Function(Download download) onAdded = ((download) => Void);

  Function(Download download) onCancelled = ((download) => Void);

  Function(Download download) onDeleted = ((download) => Void);

  Function(Download download, DownloadBlock downloadBlock, int totalBlocks)
      onDownloadBlockUpdated = ((download, downloadBlock, totalBlocks) => Void);
  Function(Download download) onPaused = ((download) => Void);

  Function(Download download, bool waitingOnNetwork) onQueued =
      ((download, waitingOnNetwork) => Void);

  Function(Download download) onRemoved = ((download) => Void);

  Function(Download download) onResumed = ((download) => Void);

  Function(Download download, List<DownloadBlock> downloadBlocks,
          int totalBlocks) onStarted =
      ((download, downloadBlocks, totalBlocks) => Void);

  Function(Download download) onWaitingNetwork = ((download) => Void);

  Downloader() {
    _downloaderEventChannel.receiveBroadcastStream().map((event) {
      Map map = jsonDecode(event);
      map["download"]["progress"] = map["progress"];
      return map;
    }).listen((event) {
      String eventName = event["eventName"];
      Download download = Download.fromJson(event["download"]);
      switch (eventName) {
        case "onCompleted":
          onCompleted(download);
          break;
        case "onError":
          onError(download, event["error"], event["throwable"]);
          break;
        case "onProgress":
          onProgress(download, event["etaInMilliSeconds"],
              event["downloadedBytesPerSecond"]);
          break;
        case "onAdded":
          onAdded(download);
          break;
        case "onCancelled":
          onCancelled(download);
          break;
        case "onDeleted":
          onDeleted(download);
          break;
        case "onDownloadBlockUpdated":
          onDownloadBlockUpdated(
              download,
              DownloadBlock.fromJson(event["downloadBlock"]),
              event["totalBlocks"]);
          break;
        case "onPaused":
          onPaused(download);
          break;
        case "onResumed":
          onResumed(download);
          break;
        case "onRemoved":
          onRemoved(download);
          break;
        case "onStarted":
          List<DownloadBlock> downloadBlocks =
              (event["downloadBlocks"] as List<dynamic>)
                  .map((e) => DownloadBlock.fromJson(e))
                  .toList();
          onStarted(download, downloadBlocks, event["totalBlocks"]);
          break;
        case "onWaitingNetwork":
          onCompleted(download);
          break;
        case "onQueued":
          onQueued(download, event["waitingOnNetwork"]);
          break;
        default:
          throw Exception('Unkown Event Name $eventName');
      }
    });
  }

  Future<int> download(String url, String file) async {
    int requestId =
        await _channel.invokeMethod('download', {"url": url, "file": file});
    return requestId;
  }

  Future<int> pause(int id) async {
    int pauseId = await _channel.invokeMethod('pause', {"id": id});
    return pauseId;
  }

  Future<List<int>> remove(List<int> ids) async {
    List<dynamic> removeIds =
        await _channel.invokeMethod('remove', {"ids": ids});
    return removeIds.map((e) {
      return (e as int);
    }).toList();
  }

  Future<List<int>> delete(List<int> ids) async {
    List<dynamic> deleteIds =
        await _channel.invokeMethod('delete', {"ids": ids});
    return deleteIds.map((e) {
      return (e as int);
    }).toList();
  }

  Future<int> resume(int id) async {
    int resumeId = await _channel.invokeMethod('resume', {"id": id});
    return resumeId;
  }

  List<Download> parseDownlod(String result) {
    List<dynamic> list = jsonDecode(result);
    List<Download> downloads = list.map((e) {
      e["download"]["progress"] = e["progress"];
      return Download.fromJson(e["download"]);
    }).toList();
    return downloads;
  }

  Future<List<Download>> getDownloads() async {
    String result = await _channel.invokeMethod('getDownloads');
    return parseDownlod(result);
  }

  Future<List<Download>> getDownloadsWithStatus(Status status) async {
    String result = await _channel.invokeMethod('getDownloads');
    return parseDownlod(result);
  }

  Future<List<RequestErrorPair>> groupingDownload(
      List<FileURL> fileURLs, int grouoId) async {
    String result = await _channel.invokeMethod('groupingDownload',
        {"fileURLs": jsonEncode(fileURLs), "groupId": grouoId});
    List<dynamic> listMap = jsonDecode(result);
    List<RequestErrorPair> downloads = listMap.map((e) {
      RequestErrorPair requestErrorPair = RequestErrorPair.fromJson(e);
      return requestErrorPair;
    }).toList();
    return downloads;
  }

  Future<List<Download>> getDownloadsInGroup(int groupId) async {
    String result = await _channel
        .invokeMethod('getDownloadsInGroup', {"groupId": groupId});
    return parseDownlod(result);
  }
}
