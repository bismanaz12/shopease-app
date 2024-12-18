import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecomerance_app/Screens/product_detail_screen.dart';
import 'package:ecomerance_app/lib/CustomWidgets/searchbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../AppColors/appcolors.dart';
import '../Auth/firestore.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';

import '../controllers/home_screen_controller.dart';
import '../routes/route_name.dart';
import 'HomeScreenTabs/AllItem.dart';
import 'HomeScreenTabs/bagItem.dart';
import 'HomeScreenTabs/clothesItem.dart';
import 'HomeScreenTabs/shoesItem.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  Map<String, dynamic>? userData;
  String username = '';
  List<Map<String, dynamic>> _allPopularCategories = [];
  List<Map<String, dynamic>> _allTrendingProducts = [];
  List<Map<String, dynamic>> _allDealsOfTheDay = [];

  List<Map<String, dynamic>> _filteredPopularCategories = [];
  List<Map<String, dynamic>> _filteredTrendingProducts = [];
  List<Map<String, dynamic>> _filteredDealsoftheDay = [];

  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollsController = ScrollController();
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();
  stt.SpeechToText _speech = stt.SpeechToText();
  final CarouselController _controller = CarouselController();
  final HomeScreenController controller = Get.put(HomeScreenController());
  bool _isListening = false;
  bool startValue = false;
  bool startsValue = false;
  List<int> favoriteIndices = [];
  List<int> favoritesIndices = [];

  List<String> productsType = ["All", "Bags", "Clothes", "Shoes"];
  // List<String> productIcons = [
  //   "assets/icons/bag.png",
  //   "assets/icons/laptop.png",
  //   "assets/icons/jewelry.png",
  //   "assets/icons/kitchen.png",
  //   "assets/icons/shirt.png",
  //   "assets/icons/shoes.png",
  //   "assets/icons/toys.png",
  //   "assets/icons/watch.png",
  // ];
  List<String> productnames = [
    'Bag',
    'Laptop',
    'Jewelry',
    'Kitchen',
    'shirt',
    'shoes',
    'toys',
    'watch',
  ];

  Future<void> fetchUserData() async {
    try {
      userData = await _firestoreService.getUserData();
      if (userData != null) {
        username = userData?['userName'] ?? 'Guest';
      }
      setState(() {});
    } catch (e) {
      print('Error fetching user data: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _filterData() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredPopularCategories = List.from(_allPopularCategories);
        _filteredTrendingProducts = List.from(_allTrendingProducts);
        _filteredDealsoftheDay = List.from(_allDealsOfTheDay);
      } else {
        _filteredPopularCategories =
            _filterByQuery(_allPopularCategories, 'productName');
        _filteredTrendingProducts =
            _filterByQuery(_allTrendingProducts, 'productName');
        _filteredDealsoftheDay = _filterByQuery(_allDealsOfTheDay, 'postName');
      }
    });
  }

  List<Map<String, dynamic>> _filterByQuery(
      List<Map<String, dynamic>> items, String fieldName) {
    List<String> queryWords =
        _searchQuery.trim().toLowerCase().split(RegExp(r'\s+'));

    return items.where((item) {
      String fieldValue = (item[fieldName] as String).toLowerCase();

      print('Field Value: $fieldValue');
      print('Query Words: $queryWords');

      bool match = queryWords.any((queryWord) {
        return fieldValue.contains(queryWord);
      });

      print('Match: $match');
      return match;
    }).toList();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _searchController.text = val.recognizedWords;
            _searchQuery = val.recognizedWords.trim().toLowerCase();
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> fetchData() async {
    // Fetch all data from Firestore collections
    QuerySnapshot popularCategoriesSnapshot =
        await FirebaseFirestore.instance.collection('popular_categories').get();
    QuerySnapshot trendingProductsSnapshot =
        await FirebaseFirestore.instance.collection('trending_products').get();
    QuerySnapshot dealsOfTheDaySnapshot =
        await FirebaseFirestore.instance.collection('deals_of_the_day').get();

    setState(() {
      _allPopularCategories = popularCategoriesSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _allTrendingProducts = trendingProductsSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _allDealsOfTheDay = dealsOfTheDaySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Initially set filtered lists to all data
      _filteredPopularCategories = List.from(_allPopularCategories);
      _filteredTrendingProducts = List.from(_allTrendingProducts);
      _filteredDealsoftheDay = List.from(_allDealsOfTheDay);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          title: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: (userData?["imageUrl"] != null &&
                          userData?["imageUrl"] != '')
                      ? CachedNetworkImage(
                          fit: BoxFit.cover,
                          progressIndicatorBuilder: (context, url, progress) =>
                              Center(
                            child: CircularProgressIndicator(
                              value: progress.progress,
                            ),
                          ),
                          imageUrl: userData?["imageUrl"],
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/images/profile.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Good Morning',
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    fontSize: 20,
                  ),
                  AppText(
                    text: username.toUpperCase(),
                    fontSize: 16,
                    textColor: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteName.notificationScreen);
                },
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? SafeArea(
              child: DefaultTabController(
                length: 4,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        ProductSearchBar(
                          searchController: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.trim().toLowerCase();
                              _filterData();
                            });
                          },
                          onMicTap: _listen,
                        ),
                        const SizedBox(height: 20),
                        CarouselSlider(
                          carouselController: _controller,
                          options: CarouselOptions(
                            height: 150,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                            autoPlayAnimationDuration:
                                Duration(milliseconds: 800),
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 1,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                          items: [
                            'assets/images/banner1.png',
                            'assets/images/banner2.png',
                            'assets/images/banner3.png',
                            'assets/images/banner4.png',
                            'assets/images/banner5.png',
                          ].map((item) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      item,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        SectionHeader(
                          title: 'Popular Categories',
                          onTapSeeAll: () {},
                        ),
                        const SizedBox(height: 20),
                        _buildPopularCategories(),
                        const SizedBox(height: 20),
                        SectionHeader(
                          title: 'Deals of the Day',
                          onTapSeeAll: () {
                            Get.toNamed(RouteName.productScreen);
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildDealsoftheDay(),
                        const SizedBox(height: 10),
                        SectionHeader(
                          title: 'Trending Products',
                          onTapSeeAll: () {},
                        ),
                        const SizedBox(height: 20),
                        _buildTrendingProducts(),
                        const SizedBox(height: 20),
                        SectionHeader(
                          title: 'Popular Items',
                          onTapSeeAll: () {},
                        ),
                        Obx(() => Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                child: TabBar(
                                  tabAlignment: TabAlignment.start,
                                  isScrollable: true,
                                  dividerColor: Colors.transparent,
                                  indicator: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.transparent,
                                  ),
                                  onTap: (index) {
                                    controller.changeTabIndex(index);
                                  },
                                  tabs: productsType.map<Widget>((type) {
                                    return Tab(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () {
                                            controller.changeTabIndex(
                                                productsType.indexOf(type));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(1),
                                            width: 90,
                                            decoration: BoxDecoration(
                                              color: controller.selectedIndex ==
                                                      productsType.indexOf(type)
                                                  ? AppColors.primary
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    controller.selectedIndex ==
                                                            productsType
                                                                .indexOf(type)
                                                        ? Colors.transparent
                                                        : AppColors.primary,
                                                width: 2,
                                              ),
                                            ),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Text(
                                                type,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .merge(
                                                      TextStyle(
                                                        color: controller
                                                                    .selectedIndex ==
                                                                productsType
                                                                    .indexOf(
                                                                        type)
                                                            ? Colors.white
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 500,
                          child: Obx(() {
                            switch (controller.selectedIndex) {
                              case 0:
                                return const AllItem();
                              case 1:
                                return const BagItem();
                              case 2:
                                return const ClothesItem();
                              case 3:
                                return const ShoesItem();
                              default:
                                return const SizedBox.shrink();
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ProductSearchBar(
                    searchController: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                        _filterData();
                      });
                    },
                    onMicTap: _listen,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (_filteredPopularCategories.isNotEmpty &&
                            _filteredTrendingProducts.isEmpty &&
                            _filteredDealsoftheDay.isEmpty)
                          _buildPopularCategories(filtered: true),
                        if (_filteredTrendingProducts.isNotEmpty &&
                            _filteredPopularCategories.isEmpty &&
                            _filteredDealsoftheDay.isEmpty)
                          _buildTrendingProducts(filtered: true),
                        if (_filteredDealsoftheDay.isNotEmpty &&
                            _filteredPopularCategories.isEmpty &&
                            _filteredTrendingProducts.isEmpty)
                          _buildDealsoftheDay(filtered: true),
                        if (_filteredPopularCategories.isEmpty &&
                            _filteredTrendingProducts.isEmpty &&
                            _filteredDealsoftheDay.isEmpty)
                          const Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('No results found.'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.chat),
        onPressed: () {
          print("Navigating to ChatScreen");
          Get.toNamed(RouteName.chatScreen);
        },
        label: Text('Chat!'),
        tooltip: 'Connect To Assistant',
      ),
    );
  }

  Widget _buildMostPopularr(
    String image,
    String name,
    String description,
    String price,
    String originalPrice,
    int index,
    bool isNetworkImage, // Added parameter
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
              isNetworkImage: isNetworkImage, // Pass the new parameter
            ));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            width: 150,
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
                    child: isNetworkImage
                        ? Image.network(
                            image,
                            fit: BoxFit.fill,
                          )
                        : Image.asset(
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
                const Spacer(),
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
                    const Spacer(),
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
                            const AppText(
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

  Widget _buildPopularCategories({bool filtered = false}) {
    return SizedBox(
      height: 255,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('popular_categories')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs.map((doc) {
            return {
              'productName': doc['productName'],
              'productDescription': doc['productDescription'],
              'productPrice': doc['productPrice'],
              'productImage': doc['productImage'],
              'originalPrice': doc['originalPrice'],
            };
          }).toList();

          final queryWords = _searchQuery.toLowerCase().split(' ');

          final filteredProducts = filtered
              ? products.where((product) {
                  final productName = product['productName'].toLowerCase();
                  return queryWords.every((word) => productName.contains(word));
                }).toList()
              : products;

          return ListView.builder(
            key: UniqueKey(),
            controller: _scrollsController,
            scrollDirection: Axis.horizontal,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductsContainer(
                product['productImage'],
                product['productName'],
                product['productPrice'],
                product['productDescription'],
                product['originalPrice'],
                index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTrendingProducts({bool filtered = false}) {
    return SizedBox(
      height: 255,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trending_products')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final products = snapshot.data!.docs.map((doc) {
            return {
              'productName': doc['productName'],
              'productDescription': doc['productDescription'],
              'productPrice': doc['productPrice'],
              'productImage': doc['productImage'],
              'originalPrice': doc['originalPrice'],
            };
          }).toList();

          final filteredProducts = filtered
              ? products.where((product) {
                  final productName = product['productName'].toLowerCase();
                  return productName.contains(_searchQuery);
                }).toList()
              : products;

          return ListView.builder(
            key: UniqueKey(),
            controller: _scrollsController,
            scrollDirection: Axis.horizontal,
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductsContainer(
                product['productImage'],
                product['productName'],
                product['productPrice'],
                product['productDescription'],
                product['originalPrice'],
                index,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDealsoftheDay({bool filtered = false}) {
    return SizedBox(
      height: 255,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('createPosts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/ground.png',
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No Data Found',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          if (filtered && _searchQuery.isNotEmpty) {
            documents = documents.where((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var postName = data['postName'] ?? '';
              return postName.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: documents.length,
            itemBuilder: (context, index) {
              var data = documents[index].data() as Map<String, dynamic>;
              var postName = data['postName'] ?? 'Unknown';
              var postDescription = data['postDescription'] ?? 'No description';
              var postImage = data['postImage'] ?? '';

              return Card(
                elevation: 1,
                child: Container(
                  width: 315,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (postImage.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                          child: Image.network(
                            postImage,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Placeholder(
                          fallbackHeight: 150,
                          color: Colors.grey,
                        ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: postName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                ),
                                AppText(
                                  text: postDescription.length > 20
                                      ? postDescription.substring(0, 20) + '...'
                                      : postDescription,
                                  fontSize: 16,
                                ),
                              ],
                            ),
                            CustomButton(
                              onTap: () {
                                // Handle the view more button tap
                              },
                              label: 'view more',
                              width: 60,
                              height: 25,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              bgColor: AppColors.primary,
                              labelColor: Colors.white,
                              borderRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductsContainer(
    String image,
    String name,
    String description,
    String price,
    String originalPrice,
    int index,
  ) {
    bool isFavorite = favoritesIndices.contains(index);
    return GestureDetector(
      onTap: () {
        Get.to(() => ProductDetailScreen(
              image: image,
              name: name,
              description: description,
              price: price,
              originalPrice: originalPrice,
              isNetworkImage: true, // Assuming network image; change as needed
            ));
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(10),
            width: 161,
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
                const Spacer(),
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
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          startsValue = !startsValue;
                        });
                      },
                      child: SizedBox(
                        width: 70,
                        height: 30,
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
                            const SizedBox(width: 5),
                            const AppText(
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
            right: 20,
            top: 15,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (isFavorite) {
                    favoritesIndices.remove(index);
                  } else {
                    favoritesIndices.add(index);
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

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onTapSeeAll;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.onTapSeeAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AppText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        GestureDetector(
          onTap: onTapSeeAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AppText(
              text: 'See All',
              fontWeight: FontWeight.bold,
              textColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
