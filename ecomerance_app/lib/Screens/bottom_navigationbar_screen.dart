import 'package:ecomerance_app/Screens/order_status_screen.dart';
import 'package:ecomerance_app/Screens/profile_screen.dart';
import 'package:ecomerance_app/Screens/search.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../AppColors/appcolors.dart';
import 'Categories_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';

class BottomNevigationBar extends StatefulWidget {
  @override
  _BottomNevigationBarState createState() => _BottomNevigationBarState();
}

class _BottomNevigationBarState extends State<BottomNevigationBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    // CategoriesScreen(),
    OrderStatusScreen(),
    SearchScreen(),
    CartScreen(),

    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.symmetric(vertical: 8),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: AppColors.primary,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.category),
            title: Text("Orders"),
            selectedColor: AppColors.primary,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.search),
            title: Text("Search"),
            selectedColor: AppColors.primary,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("Cart"),
            selectedColor: AppColors.primary,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
