class ProductModel {
  String? id;
  String? name;
  String? description;
  double? price;
  List<String>? images;
  List<String>? categoryIds;
  List<String>? sizeIds;
  List<String>? colorIds;

  ProductModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.images,
    this.categoryIds,
    this.sizeIds,
    this.colorIds,
  });

  ProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    price = json['price'];
    images = json['images'].cast<String>();
    categoryIds = json['categoryIds'].cast<String>();
    sizeIds = json['sizeIds'].cast<String>();
    colorIds = json['colorIds'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['price'] = this.price;
    data['images'] = this.images;
    data['categoryIds'] = this.categoryIds;
    data['sizeIds'] = this.sizeIds;
    data['colorIds'] = this.colorIds;
    return data;
  }
}
