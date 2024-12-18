import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetails {
  final String productName;
  final double productPrice;
  final int productQuantity;
  final String productImage;

  ProductDetails({
    required this.productName,
    required this.productPrice,
    required this.productQuantity,
    required this.productImage,
  });

  factory ProductDetails.fromMap(Map<String, dynamic> map) {
    return ProductDetails(
      productName: map['productName'] ?? '',
      productPrice: map['productPrice']?.toDouble() ?? 0.0,
      productQuantity: map['productQuantity'] ?? 0,
      productImage: map['productImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPrice': productPrice,
      'productQuantity': productQuantity,
      'productImage': productImage,
    };
  }
}

class UserOrder {
  final String uid;
  final String orderNo;
  final String address;
  final String paymentMethod;
  final double totalAmount;
  final double shipping;
  final String promoCode;
  final String cardNo;
  final String firstName;
  final String phoneNumber;
  final List<ProductDetails> products;
  String status; // Changed to mutable
  final DateTime currentTime;

  UserOrder( {
    required this.uid,
    required this.orderNo,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.shipping,
    required this.promoCode,
    required this.cardNo,
    required this.firstName,
    required this.phoneNumber,
    required this.products,
    required this.status,
    required this.currentTime,
  });

  factory UserOrder.fromMap(Map<String, dynamic> map) {
    return UserOrder(
      uid: map['uid'] ?? '',
      orderNo: map['orderNo'] ?? '',
      address: map['address'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      shipping: map['shipping']?.toDouble() ?? 0.0,
      promoCode: map['promoCode'] ?? '',
      cardNo: map['cardNo'] ?? '',
      firstName: map['firstName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      products: (map['products'] as List<dynamic>?)
          ?.map((product) => ProductDetails.fromMap(product as Map<String, dynamic>))
          .toList() ?? [],
      status: map['status'] ?? '', // Assign status
      currentTime: (map['currentTime'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'orderNo': orderNo,
      'address': address,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'shipping': shipping,
      'promoCode': promoCode,
      'cardNo': cardNo,
      'firstName': firstName,
      'phoneNumber': phoneNumber,
      'products': products.map((product) => product.toMap()).toList(),
      'status': status,
      'currentTime': currentTime,
    };
  }

  // Setter method for status
  void setStatus(String newStatus) {
    status = newStatus;
  }
}
