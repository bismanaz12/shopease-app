class ColorModel {
  String? id;
  String? name;
  String? hexCode;

  ColorModel({this.id, this.name, this.hexCode});

  ColorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    hexCode = json['hexCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['hexCode'] = this.hexCode;
    return data;
  }
}
