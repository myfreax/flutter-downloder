
import 'dart:async';

import 'package:flutter/services.dart';

class Downloader {
  static const MethodChannel _channel = MethodChannel('downloader');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
