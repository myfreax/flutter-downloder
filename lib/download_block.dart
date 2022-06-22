class DownloadBlock {
  /* Download ID.*/
  int downloadId;

  // Position in the downloading block sequence.*/
  int blockPosition;

  // Block start position.*/
  int startByte;

  /* Block end position.*/
  int endByte;

  /* Downloaded bytes in block.*/
  int downloadedBytes;

  // Progress completion of block.*/
  int progress;
  DownloadBlock(this.blockPosition, this.downloadId, this.downloadedBytes,
      this.endByte, this.progress, this.startByte);

  DownloadBlock.fromJson(Map<String, dynamic> map)
      : downloadId = map["downloadId"],
        blockPosition = map["blockPosition"],
        startByte = map["startByte"],
        endByte = map["endByte"],
        progress = map["progress"],
        downloadedBytes = map["downloadedBytes"];
}
