import 'package:ecomerance_app/Screens/product_screen.dart';
import 'package:ecomerance_app/Screens/rating_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  final TextEditingController _categoryController = TextEditingController();
  String BtnValue = 'clear all';
  late List<bool> checkValues = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * .8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ), // Adjust background color as needed
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10),
                  Container(
                    width: 60,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xffF6F6F8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios_new_outlined)),
                      SizedBox(width: 20),
                      AppText(
                        text: 'Brands',
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                      SizedBox(width: 10),
                      IconButton(
                          onPressed: () {
                            Get.to(() => ProductScreen());
                          },
                          icon: Icon(Icons.close_outlined)),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: CustomTextFormField(
                      bgColor: Color(0xffF6F6F8),
                      contentPadding: EdgeInsets.all(10),
                      controller: _categoryController,
                      hintText: 'Search',
                      prefixIcon: Icons.search,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      // margin: EdgeInsets.symmetric(vertical: 5),

                      height: MediaQuery.sizeOf(context).height * .5,
                      decoration: BoxDecoration(
                        color: Color(0xffF6F6F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: checkValues.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Image.asset('assets/images/profile.png'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              AppText(
                                text: 'EKWB',
                                fontWeight: FontWeight.w400,
                                fontSize: 17,
                              ),
                              Spacer(),
                              AppText(
                                text: '500',
                                textColor: Colors.grey,
                              ),
                              Checkbox(
                                activeColor: AppColors.primary,
                                value: checkValues[index],
                                onChanged: (value) {
                                  setState(() {
                                    checkValues[index] = !checkValues[index];
                                  });
                                },
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Divider(
                              height: 1,
                            ),
                          );
                        },
                      )),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        onTap: () {
                          setState(() {
                            BtnValue = 'clear all';
                          });
                        },
                        labelColor: BtnValue == 'clear all'
                            ? Colors.white
                            : Colors.black,
                        bgColor: BtnValue == 'clear all'
                            ? AppColors.primary
                            : Colors.white, // Fixing background color here
                        height: 50,
                        borderRadius: 10,
                        width: 140,
                        label: 'clear all',
                      ),
                      CustomButton(
                        onTap: () {
                          setState(() {
                            BtnValue = 'show 1000';
                          });
                        },
                        labelColor: BtnValue == 'show 1000'
                            ? Colors.white
                            : Colors.black,
                        bgColor: BtnValue == 'show 1000'
                            ? AppColors.primary
                            : Colors.white, // Fixing background color here
                        height: 50,
                        borderRadius: 10,
                        width: 140,
                        label: 'show 1000',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
