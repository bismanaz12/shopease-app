class Product {
  final String? productId;
  final String productName;
  final String productDescription;
  final String productPrice;
  final String? productImage;
  final String originalPrice;
  final String category;

  Product({
    this.productId,
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    this.productImage,
    required this.originalPrice,
    required this.category,
  });
}
