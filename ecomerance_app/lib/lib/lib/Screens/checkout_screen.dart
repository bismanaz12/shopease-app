import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/Screens/googleprovider.dart';

import 'package:ecomerance_app/Screens/stripescreen.dart';

import 'package:ecomerance_app/googlemap.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';
import '../Model/address_details_model.dart';
import '../Model/order_model.dart';
import '../controllers/checkout_screen_controller.dart';
import 'address_screen.dart';
import 'checkout_payment_tabs/card_payment.dart';
import 'checkout_payment_tabs/cash_payment.dart';
import 'checkout_payment_tabs/pay_payment.dart';
import 'order_status_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double subtotal;
  final double shippingFee;
  final double total;
  final String userId;
  final cartItems; // Ensure cartItems is a List<CartItem>

  CheckoutScreen({
    Key? key,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.userId,
    required this.cartItems,
  }) : super(key: key);

  String address = '';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CheckoutController controller = Get.put(CheckoutController());
  TextEditingController promoController = TextEditingController();
  List<String> paymentType = ["Card", "Cash", "Pay"];
  List<String> imagePathList = [
    "assets/icons/card.svg",
    "assets/icons/cash.svg",
    "assets/icons/apple.svg"
  ];
  Map<String, dynamic>? selectedAddress;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      selectedAddress = Get.arguments['addresses'][0];
    }
  }

  String generateOrderNumber() {
    // Generate a random 6-digit order number
    Random random = Random();
    int randomNumber = random.nextInt(900000) + 100000;
    return 'ORD-$randomNumber';
  }

  void placeOrder() async {
    try {
      // Fetch the user document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (!userDoc.exists) {
        print('User data not found');
        return;
      }

      String firstName = userDoc.get('userName') ?? 'Unknown';

      // Fetch the cart items for the current user
      QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('addtocart')
          .where('userId', isEqualTo: widget.userId)
          .get();

      if (cartSnapshot.docs.isNotEmpty) {
        List<ProductDetails> products = [];

        // Iterate over each document in the cart
        for (var doc in cartSnapshot.docs) {
          String productName = doc.get('productName');

          // Convert the productPrice from String to double
          double productPrice =
              double.tryParse(doc.get('productPrice').toString()) ?? 0.0;

          int productQuantity = doc.get('quantity') ?? 1;
          String productImage = doc.get('productImage');

          ProductDetails product = ProductDetails(
            productName: productName,
            productPrice: productPrice,
            productQuantity: productQuantity,
            productImage: productImage,
          );

          products.add(product);
        }

        // Create an order
        UserOrder order = UserOrder(
          uid: widget.userId,
          orderNo: generateOrderNumber(),
          address: selectedAddress != null
              ? '${selectedAddress!['address']} ${selectedAddress!['city']}'
              : 'Select Address',
          paymentMethod: paymentType[controller.selectedIndex],
          totalAmount: widget.total,
          shipping: widget.shippingFee,
          promoCode: promoController.text,
          cardNo:
              '**** **** **** 2512', // Replace with actual logic for card number
          firstName: firstName,
          products: products,
          status: 'Pending',
          currentTime:
              DateTime.now(), // Capture current time when placing the order
          phoneNumber: '',
        );

        // Save order to Firestore
        await FirebaseFirestore.instance
            .collection('orders')
            .add(order.toMap());

        // Clear cart data for the current user
        await FirebaseFirestore.instance
            .collection('addtocart')
            .where('userId', isEqualTo: widget.userId)
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });

        // Show success dialog and navigate to order status screen
        _showSuccessDialog(context);
      } else {
        print('No product found in the cart');
      }
    } catch (e) {
      print('Error placing order: $e');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: SvgPicture.asset('assets/icons/done.svg'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: 'Congratulations!',
                fontWeight: FontWeight.w500,
                fontSize: 20,
                textColor: Colors.white,
              ),
              AppText(
                text: 'Your order has been placed.',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                textColor: Colors.grey,
              ),
            ],
          ),
          actions: [
            CustomButton(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => OrderStatusScreen()));
              },
              label: 'Track Your Order',
              labelColor: Colors.white,
              bgColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total cost from cart items
    double totalCost = widget.cartItems.fold(
          0.0,
          (sum, item) => sum + (item.productPrice * item.quantity),
        ) +
        widget.shippingFee;
    int totalCostInInt = totalCost.toInt();

    var currentAddress = Provider.of<AddressProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Checkout Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: DefaultTabController(
          length: 3,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        text: 'Delivery Address',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Navigate to AddressScreen and wait for result
                          Map<String, dynamic>? result =
                              await Get.to(() => AddressScreen());

                          if (result != null) {
                            setState(() {
                              selectedAddress = result;
                            });
                          }
                        },
                        child: const AppText(
                          text: 'Change',
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => MapPage()));
                          },
                          child: Icon(Icons.location_on_outlined)),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Container(
                            child: AppText(
                              text: currentAddress.currentAddress.isNotEmpty
                                  ? '${currentAddress.currentAddress}'
                                  : 'Address',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          )),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MapPage()));
                            },
                            child: AppText(
                              text: selectedAddress != null
                                  ? '${selectedAddress!['address']} ${selectedAddress!['city']}'
                                  : 'Select Address',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              textColor: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    text: 'Payment Method',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  Obx(
                    () => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                          ),
                          onTap: (index) {
                            controller.changeTabIndex(index);
                          },
                          tabs:
                              paymentType.asMap().entries.map<Widget>((entry) {
                            final type = entry.value;
                            final imagePath = imagePathList[entry.key];
                            return Tab(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    controller.changeTabIndex(entry.key);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    height: 100,
                                    width: 90,
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedIndex == entry.key
                                              ? AppColors.primary
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: controller.selectedIndex ==
                                                entry.key
                                            ? Colors.transparent
                                            : Colors.grey.shade200,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          imagePath,
                                          width: 18,
                                          height: 18,
                                          color: controller.selectedIndex ==
                                                  entry.key
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          type,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge!
                                              .merge(
                                                TextStyle(
                                                  color: controller
                                                              .selectedIndex ==
                                                          entry.key
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 150,
                    child: Obx(() {
                      switch (controller.selectedIndex) {
                        case 0:
                          return CardPayment(amount: '$totalCostInInt');
                        case 1:
                          return const CashPayment();
                        case 2:
                          return const PayPayment();
                        default:
                          return const SizedBox.shrink();
                      }
                    }),
                  ),
                  const AppText(
                    text: 'Order Summary',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Sub-total',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                      ),
                      AppText(
                        text: '\$${widget.subtotal.toStringAsFixed(2)}',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Vat(%)',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                      ),
                      AppText(
                        text: '\$ 0.00',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        text: 'Shipping fee',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                      ),
                      AppText(
                        text: '\$ ${widget.shippingFee.toStringAsFixed(2)}',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        text: 'Total',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        textColor: Colors.grey,
                      ),
                      AppText(
                        text: '\$ ${widget.total.toStringAsFixed(2)}',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 52,
                        width: MediaQuery.of(context).size.width * .6,
                        child: CustomTextFormField(
                          controller: promoController,
                          keyboardType: TextInputType.number,
                          borderColor: Colors.white,
                          prefixIcon: Icons.card_giftcard_sharp,
                          hintText: 'Enter promo code',
                        ),
                      ),
                      CustomButton(
                        width: MediaQuery.of(context).size.width * .25,
                        height: 52,
                        onTap: () {
                          // Add promo code logic here
                        },
                        label: 'Add',
                        bgColor: AppColors.primary,
                        labelColor: Colors.white,
                        fontSize: 18,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  CustomButton(
                    onTap: () {
                      print('press');
                      placeOrder();
                    },
                    label: 'Place Order',
                    bgColor: AppColors.primary,
                    labelColor: Colors.white,
                    fontSize: 18,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
