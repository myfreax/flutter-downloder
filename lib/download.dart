import 'package:downloader/extras.dart';
import 'package:downloader/request.dart';

class Download {
  // Used to identify a download. This id also matches the id of the request that started
  // the download
  int id;

  // The Fetch namespace this download belongs to.*/
  String namespace;

  // The url where the file will be downloaded from.*/
  String url;

  // The file eg(/files/download.txt) where the file will be
  // downloaded to and saved on disk.*/
  String file;

  // The group id this download belongs to.*/
  int group;

  // The download Priority of this download.
  // @see com.tonyodev.fetch2.Priority
  // */
  String priority;

  // The headers used by the downloader to send header information to
  // the server about a request.*/
  Map<String, dynamic> headers;

  // The amount of bytes downloaded thus far and saved to the file.*/
  int downloaded;

  // The file size of a download in bytes. This field could return -1 if the server
  // did not readily provide the Content-Length when the connection was established.*/
  int total;

  // The current status of a download.
  //  @see com.tonyodev.fetch2.Status
  //  */
  String status;

  // If the download encountered an error, the download status will be Status.Failed and
  //  this field will provide the specific error when possible.
  //  Otherwise the default non-error value is Error.NONE.
  //  @see com.tonyodev.fetch2.Error
  //  */
  String error;

  // The network type this download is allowed to download on.
  // @see com.tonyodev.fetch2.NetworkType
  // */
  String networkType;

  // The download progress thus far eg(95 indicating 95% completed). If the total field of
  // this object has a value of -1, this field will also return -1 indicating that the server
  // did not readily provide the Content-Length and that the progress is undetermined.*/
  int progress;

  // The timestamp when this download was created.*/
  int created;

  // The request information used to create this download.*/
  Request request;

  // Gets a copy of this instance. */
  //fun copy(): Download

  // Gets the tag associated with this download.*/
  String tag;

  // Action used by Fetch when enqueuing a request and a previous request with the
  // same file is already being managed. Default EnqueueAction.REPLACE_EXISTING
  // which will replaces the existing request.
  // */
  String enqueueAction;

  // Can be used to set your own unique identifier for the request.*/
  int identifier;

  // Action used by Fetch when enqueuing a request to determine if to place the new request in
  // the downloading queue immediately after enqueue to be processed with its turn arrives
  // The default value is true.
  // If true, the download will have a status of Status.QUEUED. If false, the download will have a status
  // of Status.ADDED.
  // */
  bool downloadOnEnqueue;

  // Stored custom data/ key value pairs with a request.
  // Use fetch.replaceExtras(id, extras)
  // */
  Extras extras;

  /* Returns the fileUri.*/
  Uri fileUri;

  // The estimated time in milliseconds until the download completes.
  //  This field will always be -1 if the download is not currently being downloaded.
  // */
  int etaInMilliSeconds;

  // Average downloaded bytes per second.
  // Can return -1 to indicate that the estimated time remaining is unknown. This field will
  // always return -1 when the download is not currently being downloaded.
  // */
  int downloadedBytesPerSecond;

  // The maximum number of times Fetch will auto retry a failed download.
  // The default is 0.
  // */
  int autoRetryMaxAttempts;

  // The number of times Fetch has tried to download this request after a failed attempt.
  // */
  int autoRetryAttempts;

  Download(
      this.id,
      this.autoRetryAttempts,
      this.created,
      this.autoRetryMaxAttempts,
      this.downloadOnEnqueue,
      this.downloaded,
      this.downloadedBytesPerSecond,
      this.enqueueAction,
      this.error,
      this.etaInMilliSeconds,
      this.extras,
      this.file,
      this.fileUri,
      this.group,
      this.headers,
      this.identifier,
      this.namespace,
      this.networkType,
      this.priority,
      this.progress,
      this.request,
      this.status,
      this.tag,
      this.total,
      this.url);

  Download.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        autoRetryAttempts = map["autoRetryAttempts"],
        created = map["created"],
        autoRetryMaxAttempts = map["autoRetryMaxAttempts"],
        downloadOnEnqueue = map["downloadOnEnqueue"],
        downloaded = map["downloaded"],
        downloadedBytesPerSecond = map["downloadedBytesPerSecond"],
        enqueueAction = map["enqueueAction"],
        error = map["error"],
        etaInMilliSeconds = map["etaInMilliSeconds"],
        extras = Extras.fromJson(map["extras"]),
        file = map["file"],
        fileUri = map["fileUri"],
        group = map["group"],
        headers = map["headers"],
        identifier = map["identifier"],
        namespace = map["namespace"],
        networkType = map["networkType"],
        priority = map["priority"],
        progress = map["progress"],
        request = map["request"],
        status = map["status"],
        tag = map["tag"],
        total = map["total"],
        url = map["url"];
}
