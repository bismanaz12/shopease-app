import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/Screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppColors/appcolors.dart';
import '../../CustomWidgets/appText.dart';

class AllItem extends StatefulWidget {
  const AllItem({super.key});

  @override
  State<AllItem> createState() => _AllItemState();
}

class _AllItemState extends State<AllItem> {
  bool startValue = false;
  List<int> favoriteIndices = []; // Define selectedIndex here
  bool startsValue = false;
  double aspectRatio = 0.6;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trending_products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // Extract product list once to avoid rebuilding excessively
          final products = snapshot.data!.docs.map((doc) {
            return {
              'productName': doc['productName'],
              'productDescription': doc['productDescription'],
              'productPrice': doc['productPrice'],
              'productImage': doc['productImage'],
              'originalPrice':doc['originalPrice'],
            };
          }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: aspectRatio,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),

              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductContainer(
                  product['productImage'],
                  product['productName'],
                  product['productPrice'],
                  product['productDescription'],
                  product['originalPrice'],
                  index,
                );
              },
            ),
          );
        },
      ),


    );
  }

  Widget _buildProductContainer(
      String image,
      String name,
      String description,
      String price,
      String originalPrice,
      int index,
      ) {
    bool isFavorite = favoriteIndices.contains(index);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(
          image: image,
          name: name,
          description: description,
          price: price,
          originalPrice: originalPrice,
        ));
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AppText(
                  text: name,
                  textColor: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                AppText(
                  text: price,
                  textColor: Colors.grey,
                ),
                Row(
                  children: [
                    AppText(
                      text: description,
                      textColor: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(width: 5),
                    AppText(
                      decoration: TextDecoration.lineThrough,
                      text: originalPrice,
                      textColor: Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          startsValue = !startsValue;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          startsValue
                              ? Image.asset(
                            'assets/icons/star.png',
                            width: 15,
                            height: 15,
                            color: AppColors.secondary,
                          )
                              : Image.asset(
                            'assets/icons/filled_star.png',
                            width: 15,
                            height: 15,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 2),
                          const AppText(
                            text: '4.5',
                            textColor: Colors.black,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 15,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isFavorite) {
                    favoriteIndices.remove(index);
                  } else {
                    favoriteIndices.add(index);
                  }
                });
              },
              child: SizedBox(
                width: 30,
                height: 30,
                child: isFavorite
                    ? const Icon(Icons.favorite, color: Colors.red)
                    : const Icon(
                  Icons.favorite_outline,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
