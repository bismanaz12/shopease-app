class Product {
  String productName;
  String productDescription;
  String productPrice;
  String? productImage;
  String? originalPrice;

  Product({
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productImage,
    this.originalPrice,
  });

  @override
  String toString() {
    return 'Product{name: $productName, description: $productDescription, price: $productPrice, image: $productImage,originalPrice:$originalPrice}';
  }
}
