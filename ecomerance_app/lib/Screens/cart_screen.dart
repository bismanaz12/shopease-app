import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import '../AppColors/appcolors.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userId;
  double subtotal = 0.0;
  double shippingFee = 80.0;
  double total = 0.0;
  bool isLoading = true;
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        setState(() {
          userId = user.uid;
        });
        await _calculateSubtotal(); // Ensure this completes before proceeding
      } else {
        print('User is not logged in');
      }
    } catch (error) {
      print('Error getting user data: $error');
    }
  }

  Future<void> _calculateSubtotal() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('addtocart')
          .where('userId', isEqualTo: userId)
          .get();

      double tempSubtotal = 0.0;
      List<CartItem> tempCartItems = [];

      for (var doc in querySnapshot.docs) {
        double price = double.tryParse(
                doc['productPrice'].replaceAll(RegExp(r'[^\d.]'), '')) ??
            0.0;
        int quantity = doc['quantity'];
        tempSubtotal += price * quantity;

        tempCartItems.add(CartItem(
          productName: doc['productName'],
          productImage: doc['productImage'],
          productPrice: price,
          productDescription: doc['productDescription'],
          quantity: quantity,
          docId: doc.id,
        ));
      }

      setState(() {
        subtotal = tempSubtotal;
        total = subtotal + shippingFee;
        cartItems = tempCartItems;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error calculating subtotal: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Cart Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var product = cartItems[index];
                        return _buildCartItem(product);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTotalSection(),
                  const SizedBox(height: 30),
                  CustomButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            cartItems: cartItems,
                            subtotal: subtotal,
                            shippingFee: shippingFee,
                            total: total,
                            userId: userId,
                          ),
                        ),
                      );
                    },
                    label: 'Go to checkout',
                    bgColor: AppColors.primary,
                    labelColor: Colors.white,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCartItem(CartItem product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 116,
            width: 120,
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: Image.network(product.productImage,
                    width: 80, fit: BoxFit.fill)),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppText(
                    text: product.productName,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primary,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: IconButton(
                      onPressed: () => _removeCartItem(product.docId),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              AppText(
                text: product.productDescription,
                fontSize: 14,
                textColor: Colors.grey,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: '\$${product.productPrice.toStringAsFixed(2)}',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.primary,
                  ),
                  SizedBox(width: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _updateQuantity(product, -1),
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.primary,
                      ),
                      AppText(
                        text: '${product.quantity}',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: AppColors.primary,
                      ),
                      IconButton(
                        onPressed: () => _updateQuantity(product, 1),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _removeCartItem(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('addtocart')
          .doc(docId)
          .delete();
      await _calculateSubtotal(); // Recalculate after removal
    } catch (error) {
      print('Error removing cart item: $error');
    }
  }

  Future<void> _updateQuantity(CartItem product, int change) async {
    int newQuantity = product.quantity + change;
    if (newQuantity > 0) {
      try {
        await FirebaseFirestore.instance
            .collection('addtocart')
            .doc(product.docId)
            .update({'quantity': newQuantity});
        await _calculateSubtotal(); // Recalculate after quantity change
      } catch (error) {
        print('Error updating quantity: $error');
      }
    }
  }

  Widget _buildTotalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildTotalRow('Sub-total', subtotal),
        _buildTotalRow(
            'Vat(%)', 0.0), // VAT should be dynamically calculated if needed
        _buildTotalRow('Shipping fee', shippingFee),
        Divider(color: Colors.grey.shade200, height: 1),
        _buildTotalRow('Total', total),
      ],
    );
  }

  Widget _buildTotalRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: title,
            fontSize: 16,
            textColor: Colors.grey,
          ),
          AppText(
            text: '\$${value.toStringAsFixed(2)}',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            textColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

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
