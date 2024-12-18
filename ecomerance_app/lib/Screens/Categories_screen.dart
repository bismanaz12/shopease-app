import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../CustomWidgets/CustomTextformField.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          'Categories Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: CustomTextFormField(
                  bgColor: AppColors.grey,
                  contentPadding: EdgeInsets.all(10),
                  controller: _searchController,
                  hintText: 'Search',
                  prefixIcon: Icons.search,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        width: 200,
                        child: Stack(children: [
                          Container(
                            height: 100,
                            width: MediaQuery.of(context).size.width * .74,
                            decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: 'Chairs',
                                    textColor: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  AppText(
                                    text: 'Total 120 items available',
                                    textColor: Colors.black,
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: Image.asset(
                              'assets/images/chair1.png',
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ]),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
