
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'admin_all_posts.dart';
import 'admin_all_products.dart';
import 'admin_home_screen.dart';
import 'admin_profile_screen.dart';





class AdminBottomNevigationBar extends StatefulWidget {
  @override
  _AdminBottomNevigationBarState createState() => _AdminBottomNevigationBarState();
}

class _AdminBottomNevigationBarState extends State<AdminBottomNevigationBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    AdminHomeScreen(),
    AdminAllPosts(),
    AdminAllProducts(),
    AdminProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        backgroundColor: Colors.black,
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
              title: Text("Dashbord"),
              selectedColor: Colors.teal,
              unselectedColor: Colors.white
          ),
          SalomonBottomBarItem(
              icon: Icon(Icons.post_add_outlined),
              title: Text("Posts"),
              selectedColor: Colors.teal,
              unselectedColor: Colors.white
          ),
          SalomonBottomBarItem(
              icon: Icon(Icons.add_shopping_cart),
              title: Text("Products"),
              selectedColor: Colors.teal,
              unselectedColor: Colors.white
          ),

          SalomonBottomBarItem(
              icon: Icon(Icons.person),
              title: Text("Profile"),
              selectedColor: Colors.teal,
              unselectedColor: Colors.white
          ),

        ],
      ),
    );
  }
}





