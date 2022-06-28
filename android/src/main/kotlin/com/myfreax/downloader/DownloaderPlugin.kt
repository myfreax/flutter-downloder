package com.myfreax.downloader

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.tonyodev.fetch2.*
import com.tonyodev.fetch2.exception.FetchException
import com.tonyodev.fetch2.util.DEFAULT_AUTO_RETRY_ATTEMPTS
import com.tonyodev.fetch2.util.DEFAULT_GROUP_ID
import com.tonyodev.fetch2.util.defaultNetworkType
import com.tonyodev.fetch2.util.defaultPriority
import com.tonyodev.fetch2core.DownloadBlock
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


data class FileURL(val file: String, val url: String)

/** DownloaderPlugin */
class DownloaderPlugin : FlutterPlugin, MethodCallHandler {

  companion object {
    const val TAG = "DownloaderPlugin"
  }

  private lateinit var appContext: Context
  private val json by lazy {
    Gson()
  }
  private val fetch by lazy {
    Fetch.getInstance(
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
      EventChannel(flutterPluginBinding.binaryMessenger, "downloaderEventChannel")
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
        val ids = (args["ids"] as ArrayList<*>).toList().map {
          it as Int
        }
        remove(ids, result)
      }
      "delete" -> {
        val ids = (args["ids"] as ArrayList<*>).toList().map {
          it as Int
        }
        delete(ids, result)
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
      "groupingDownload" -> {
        val groupId = args["groupId"] as Int
        val listType = object : TypeToken<ArrayList<FileURL?>?>() {}.type
        val fileURLs: List<FileURL> = Gson().fromJson(args["fileURLs"] as String, listType)
        val requests = fileURLs.map {
          val request = Request(it.url, it.file)
          request.groupId = groupId
          request
        }
        groupingDownload(requests, result)
      }
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
    try {
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
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
    return -1
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
      fetch.getDownloads { downloads ->
        val results = downloads.map {
          val hash = hashMapOf<String, Any>()
          hash["progress"] = it.progress
          hash["download"] = it
          hash
        }
        result.success(json.toJson(results))
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private fun getDownloadsWithStatus(status: Status, result: Result) {
    try {
      fetch.getDownloadsWithStatus(status) { downloads ->
        val results = downloads.map {
          val hash = hashMapOf<String, Any>()
          hash["progress"] = it.progress
          hash["download"] = it
          hash
        }
        result.success(json.toJson(results))
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private fun getDownloadsInGroup(groupId: Int, result: Result) {
    try {
      fetch.getDownloadsInGroup(groupId) { downloads ->
        val results = downloads.map {
          val hash = hashMapOf<String, Any>()
          hash["progress"] = it.progress
          hash["download"] = it
          hash
        }
        result.success(json.toJson(results))
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private fun groupingDownload(requests: List<Request>, result: Result) {
    try {
      fetch.enqueue(requests) {
        result.success(json.toJson(it))
      }
    } catch (e: FetchException) {
      result.error(e.hashCode().toString(), e.message, e.stackTrace)
    }
  }

  private val fetchListener: FetchListener = object : AbstractFetchListener() {
    private val uiThreadHandler by lazy {
      Handler(Looper.getMainLooper())
    }

    private fun success(eventName: String, download: Download, data: HashMap<String, Any>) {
      data["eventName"] = eventName
      data["download"] = download
      data["progress"] = download.progress
      uiThreadHandler.post {
        downloaderEventSink?.success(json.toJson(data))
      }
    }

    override fun onCompleted(download: Download) {
      Log.d(TAG, "onCompleted")
      val hash = hashMapOf<String, Any>()
      success("onCompleted", download, hash)
    }

    override fun onError(download: Download, error: Error, throwable: Throwable?) {
      Log.d(TAG, "onError:${error.name}:${throwable?.message}")
      val hash = hashMapOf<String, Any>()
      hash["error"] = error.name
      hash["message"] = throwable?.message ?: ""
      success("onError", download, hash)
    }

    override fun onProgress(
      download: Download,
      etaInMilliSeconds: Long,
      downloadedBytesPerSecond: Long
    ) {
      //Log.d(TAG, "onProgress")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["etaInMilliSeconds"] = etaInMilliSeconds
      hash["downloadedBytesPerSecond"] = downloadedBytesPerSecond
      success("onProgress", download, hash)
    }

    override fun onAdded(download: Download) {
      Log.d(TAG, "onAdded")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onAdded", download, hash)
    }

    override fun onCancelled(download: Download) {
      Log.d(TAG, "onCancelled")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onCancelled", download, hash)
    }

    override fun onDeleted(download: Download) {
      Log.d(TAG, "onDeleted")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onDeleted", download, hash)
    }

    override fun onDownloadBlockUpdated(
      download: Download,
      downloadBlock: DownloadBlock,
      totalBlocks: Int
    ) {
      //Log.d(TAG, "onDownloadBlockUpdated")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["downloadBlock"] = downloadBlock
      hash["totalBlocks"] = totalBlocks
      success("onDownloadBlockUpdated", download, hash)
    }

    override fun onPaused(download: Download) {
      Log.d(TAG, "onPaused")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onPaused", download, hash)
    }


    override fun onQueued(download: Download, waitingOnNetwork: Boolean) {
      Log.d(TAG, "onQueued")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      hash["waitingOnNetwork"] = waitingOnNetwork
      success("onQueued", download, hash)
    }

    override fun onRemoved(download: Download) {
      Log.d(TAG, "onRemoved")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onRemoved", download, hash)
    }

    override fun onResumed(download: Download) {
      Log.d(TAG, "onResumed")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onResumed", download, hash)
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
      success("onStarted", download, hash)
    }

    override fun onWaitingNetwork(download: Download) {
      Log.d(TAG, "onWaitingNetwork")
      val hash = hashMapOf<String, Any>()
      hash["download"] = download
      success("onWaitingNetwork", download, hash)
    }
  }
}
