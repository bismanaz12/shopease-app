import 'package:ecomerance_app/Screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../AppColors/appcolors.dart';
import '../../CustomWidgets/appText.dart';

class CupboardScreen extends StatefulWidget {
  const CupboardScreen({super.key});

  @override
  State<CupboardScreen> createState() => _CupboardScreenState();
}

class _CupboardScreenState extends State<CupboardScreen> {
  bool startValue = false;
  List<int> favoriteIndices = []; // Define selectedIndex here

  final List<Map<String, dynamic>> chairProducts = [
    {
      'image': 'assets/images/chair2.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },
    {
      'image': 'assets/images/chair3.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },
    {
      'image': 'assets/images/chair4.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },
    {
      'image': 'assets/images/chair5.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },

    {
      'image': 'assets/images/chair2.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },
    {
      'image': 'assets/images/chair3.PNG',
      'name': 'Another Chair',
      'description': 'Another Model',
      'price': '\$25',
      'originalPrice': '\$30',
    },
    // Add more chair products as needed
  ];
  double aspectRatio = 0.6;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: GridView.builder(
          itemCount: chairProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: aspectRatio,
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) {
            return _buildProductContainer(
              chairProducts[index]['image'],
              chairProducts[index]['name'],
              chairProducts[index]['description'],
              chairProducts[index]['price'],
              chairProducts[index]['originalPrice'],
              index,
            );
          },
        ),
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
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
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
                  text: description,
                  textColor: Colors.grey,
                ),
                Spacer(),
                Row(
                  children: [
                    AppText(
                      text: price,
                      textColor: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(width: 5),
                    AppText(
                      decoration: TextDecoration.lineThrough,
                      text: originalPrice,
                      textColor: Colors.grey,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          startValue = !startValue;
                        });
                      },
                      child: SizedBox(
                        width: 70,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            startValue
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
                            const SizedBox(width: 5),
                            AppText(
                              text: '4.5',
                              textColor: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 15,
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
                    ? Icon(Icons.favorite, color: Colors.red)
                    : Icon(
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
