class CartItem {
  final String productName;
  final String productImage;
  final double productPrice;
  final String productDescription;
  final int quantity;
  final String docId;

  CartItem({
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productDescription,
    required this.quantity,
    required this.docId,
  });
}
