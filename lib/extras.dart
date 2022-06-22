class Extras {
  Map<String, dynamic> data;
  Extras(this.data);
  Extras.fromJson(Map<String, dynamic> map) : data = map["data"];
}
