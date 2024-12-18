class Categories {
  String? id;
  String? name;
  String? pictureUrl;
  int? itemCount;

  Categories({this.name, this.pictureUrl, this.itemCount});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      name: json['name'],
      pictureUrl: json['pictureUrl'],
      itemCount: json['itemCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pictureUrl': pictureUrl,
      'itemCount': itemCount,
    };
  }
}
