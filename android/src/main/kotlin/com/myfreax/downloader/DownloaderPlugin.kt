package com.myfreax.downloader

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import com.tonyodev.fetch2.*
import com.tonyodev.fetch2.exception.FetchException
import com.tonyodev.fetch2.util.DEFAULT_AUTO_RETRY_ATTEMPTS
import com.tonyodev.fetch2.util.DEFAULT_GROUP_ID
import com.tonyodev.fetch2.util.defaultNetworkType
import com.tonyodev.fetch2.util.defaultPriority
import com.tonyodev.fetch2core.DownloadBlock
import com.tonyodev.fetch2core.Func
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DownloaderPlugin */
class DownloaderPlugin : FlutterPlugin, MethodCallHandler {

  companion object {
    const val TAG = "DownloaderPlugin"
  }

  private lateinit var appContext: Context

  private val fetch by lazy {
    Fetch.Impl.getInstance(
      FetchConfiguration.Builder(appContext)
        .setDownloadConcurrentLimit(3)
        .build()
    )
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel
  private lateinit var fetchListenerEventChannel: EventChannel
  private var downloaderEventSink: EventChannel.EventSink? = null


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "downloader")
    channel.setMethodCallHandler(this)


    fetchListenerEventChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "esp_touch_sending")
    fetchListenerEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onCancel(arguments: Any?) {
        downloaderEventSink = null
      }

      override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        downloaderEventSink = events
      }
    })

    appContext = flutterPluginBinding.applicationContext

    fetch.addListener(fetchListener)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val args = call.arguments as HashMap<*, *>
    when (call.method) {
      "download" -> {
        download(args["url"] as String, args["file"] as String, result)
      }
      "pause" -> {
        pause(args["id"] as Int, result)
      }
      "remove" -> {
        remove(args["ids"] as List<Int>, result)
      }
      "delete" -> {
        delete(args["ids"] as List<Int>, result)
      }
      "resume" -> {
        resume(args["id"] as Int, result)
      }
      "getDownloads" -> {
        getDownloads(result)
      }
      "getDownloadsWithStatus" -> {
        getDownloadsWithStatus(args["status"] as Status, result)
      }
      "getDownloadsInGroup" -> {
        getDownloadsInGroup(args["groupId"] as Int, result)
      }

      "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    fetch.removeListener(fetchListener)
  }

  private fun download(
    url: String,
    file: String,
    result: Result,
    groupId: Int = DEFAULT_GROUP_ID,
    priority: Priority = defaultPriority,
    networkType: NetworkType = defaultNetworkType,
    headers: MutableMap<String, String> = mutableMapOf(),
    tag: String? = null,
    autoRetryMaxAttempts: Int = DEFAULT_AUTO_RETRY_ATTEMPTS
  ): Int {
    val request = Request(url, file)
    request.networkType = networkType
    request.autoRetryMaxAttempts = autoRetryMaxAttempts
    request.groupId = groupId
    request.priority = priority
    request.tag = tag
    request.headers = headers
    fetch.enqueue(request, { result.success(it.id) }) {
      result.error(
        it.value.toString(),
        it.name,
        it
      )
    }
    return request.id
  }

  private fun pause(id: Int, result: Result): Int {
    try {
      fetch.pause(id)
      result.success(id)
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
    return id
  }

  private fun remove(ids: List<Int>, result: Result): List<Int> {
    try {
      fetch.remove(ids)
      result.success(ids)
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
    return ids
  }

  private fun delete(ids: List<Int>, result: Result): List<Int> {
    try {
      fetch.delete(ids)
      result.success(ids)
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
    return ids
  }

  private fun resume(id: Int, result: Result): Int {
    try {
      fetch.resume(id)
      result.success(id)
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
    return id
  }

  private fun getDownloads(result: Result) {
    try {
      fetch.getDownloads(object : Func<List<Download>> {
        override fun call(downloads: List<Download>) {
          result.success(downloads)
        }
      })
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }

  }

  private fun getDownloadsWithStatus(status: Status, result: Result) {
    try {
      fetch.getDownloadsWithStatus(status) {
        result.success(it)
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private fun getDownloadsInGroup(groupId: Int, result: Result) {
    try {
      fetch.getDownloadsInGroup(groupId) {
        result.success(it)
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private fun groupDownload(urls: List<String>, result: Result) {
    //处理每个url，并创建文件夹
  }

  private fun groupDownloadFile(file: String, urls: List<String>, result: Result) {
    urls.map {
      Request(it, file)
    }
  }

  private fun startDownload() {
    val url = "http://speedtest.ftp.otenet.gr/files/test100k.db"
    val file = "/downloads/test.txt"
    val request = Request(url, file)
    request.priority = Priority.HIGH
    request.networkType = NetworkType.ALL
    request.addHeader("clientKey", "SD78DF93_3947&MVNGHE1WONG");
    fetch.enqueue(request);
  }

  private val fetchListener: FetchListener = object : AbstractFetchListener() {
    override fun onCompleted(download: Download) {
      Log.d(TAG,"onCompleted")
      downloaderEventSink?.success(download)
    }

    override fun onError(download: Download, error: Error, throwable: Throwable?) {
      Log.d(TAG, "onError")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["error"] = error
      hash["message"] = throwable?.message ?: ""
      downloaderEventSink?.success(hash)
    }

    override fun onProgress(
      download: Download,
      etaInMilliSeconds: Long,
      downloadedBytesPerSecond: Long
    ) {
      Log.d(TAG, "onProgress")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["etaInMilliSeconds"] = etaInMilliSeconds
      hash["downloadedBytesPerSecond"] = downloadedBytesPerSecond
      downloaderEventSink?.success(hash)

    }

    override fun onAdded(download: Download) {
      Log.d(TAG, download.progress.toString())
      downloaderEventSink?.success(download)
    }

    override fun onCancelled(download: Download) {
      Log.d(TAG, "onCancelled")
      downloaderEventSink?.success(download)
    }

    override fun onDeleted(download: Download) {
      Log.d(TAG, "onDeleted")
      downloaderEventSink?.success(download)
    }

    override fun onDownloadBlockUpdated(
      download: Download,
      downloadBlock: DownloadBlock,
      totalBlocks: Int
    ) {
      Log.d(TAG, "onDownloadBlockUpdated")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["DownloadBlock"] = downloadBlock
      hash["totalBlocks"] = totalBlocks
      downloaderEventSink?.success(hash)

    }

    override fun onPaused(download: Download) {
      Log.d(TAG, "onPaused")
      downloaderEventSink?.success(download)
    }


    override fun onQueued(download: Download, waitingOnNetwork: Boolean) {
      Log.d(TAG, "onQueued")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["waitingOnNetwork"] = waitingOnNetwork
      downloaderEventSink?.success(hash)
    }

    override fun onRemoved(download: Download) {
      Log.d(TAG, "onRemoved")
      downloaderEventSink?.success(download)
    }

    override fun onResumed(download: Download) {
      Log.d(TAG, "onResumed")
      downloaderEventSink?.success(download)
    }

    override fun onStarted(
      download: Download,
      downloadBlocks: List<DownloadBlock>,
      totalBlocks: Int
    ) {
      Log.d(TAG, "onStarted")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["downloadBlocks"] = downloadBlocks
      hash["totalBlocks"] = totalBlocks
      downloaderEventSink?.success(hash)

    }

    override fun onWaitingNetwork(download: Download) {
      Log.d(TAG, "onWaitingNetwork")
    }
  }
}
