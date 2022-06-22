class FileURL {
  String file;
  String url;
  FileURL(this.file, this.url);
  Map<String, String> toJson() {
    return {"file": file, "url": url};
  }
}
