import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import '../AppColors/appcolors.dart';
import '../Auth/firestore.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import '../controllers/productdetail_controller.dart';
import 'cart_screen.dart';
class ProductDetailScreen extends StatefulWidget {
  final String image;
  final String name;
  final String description;
  final String price;
  final String originalPrice;
  final bool isNetworkImage;

  const ProductDetailScreen({
    Key? key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    this.isNetworkImage = true,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailScreenController controller =
  Get.put(ProductDetailScreenController());
  final FirestoreService _firestoreService = FirestoreService();
  late List<DocumentReference> cartItems = [];
  int quantity = 1; // Initial quantity

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: AppText(
          text: 'Product Details',
          textColor: Colors.white,
          fontSize: 20,
        ),
      ),
      body: Obx(() => Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              height: 320,
              child: PageView(
                controller: controller.pageController,
                onPageChanged: (index) {
                  setState(() {
                    controller.currentPage.value = index;
                  });
                },
                children: [
                  widget.isNetworkImage
                      ? Image.network(
                    widget.image,
                    fit: BoxFit.fill,
                  )
                      : Image.asset(
                    widget.image,
                    fit: BoxFit.fill,
                  ),
                  // Repeat for other images
                ],
              ),
            ),
            Positioned(
              top: 250,
              child: PageViewDotIndicator(
                currentItem: controller.currentPage.value,
                count: 3,
                unselectedColor: Colors.white,
                selectedColor: AppColors.primary,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(50),
                      topLeft: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 230,
                              child: AppText(
                                text: widget.name,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (quantity > 1) {
                                        setState(() {
                                          quantity--;
                                        });
                                      }
                                    },
                                    child: AppText(
                                      text: '-',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                    ),
                                  ),
                                  AppText(
                                    text: quantity.toString(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                    child: AppText(
                                      text: '+',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const AppText(
                          text: '(270 Reviews)',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        const SizedBox(height: 20),
                        const AppText(
                          text: 'Size',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            itemCount: controller.sizeList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      controller.selectedIndex.value =
                                          index;
                                    });
                                  },
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: controller.selectedIndex
                                            .value ==
                                            index
                                            ? Colors.transparent
                                            : AppColors.primary,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      color: controller.selectedIndex.value ==
                                          index
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                    child: Center(
                                      child: AppText(
                                        text: controller.sizeList[index],
                                        fontWeight: FontWeight.bold,
                                        textColor: controller.selectedIndex
                                            .value ==
                                            index
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        const AppText(
                          text: 'Description',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          text: widget.price,
                        ),
                        const Spacer(),
                        Container(
                          padding:
                          const EdgeInsets.fromLTRB(20, 10, 10, 10),
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.primary,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(
                                text: '\$${_calculateTotalPrice()}',
                                fontSize: 18,
                                textColor: Colors.white,
                              ),
                              CustomButton(
                                borderRadius: 10,
                                width: 140,
                                height: 70,
                                label: 'Add to cart',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                onTap: () async {
                                  try {
                                    DocumentReference docRef =
                                    await _firestoreService.addToCart(
                                      productName: widget.name,
                                      productImage: widget.image,
                                      productDescription: widget.description,
                                      productPrice: widget.price,
                                      quantity: quantity,
                                    );
                                    setState(() {
                                      cartItems.add(docRef);
                                    });
                                    Get.to(() => CartScreen());
                                  } catch (e) {
                                    print('Error adding to cart: $e');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  /// Function to calculate the total price based on the current quantity
  String _calculateTotalPrice() {
    // Convert the price from String to double
    double price = double.tryParse(widget.description.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    // Calculate the total price
    double totalPrice = price * quantity;

    // Format the total price to 2 decimal places
    return totalPrice.toStringAsFixed(2);
  }
}

