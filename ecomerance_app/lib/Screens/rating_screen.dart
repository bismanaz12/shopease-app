import 'package:ecomerance_app/Screens/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';


class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  String BtnValue = 'clear all';
  String? selectedValue;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height *.8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ), // Adjust background color as needed
          child:Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade500,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_ios_new_outlined)),
                    SizedBox(width: 20),
                    AppText(
                      text: 'Rating',
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(width: 10),
                    IconButton(
                        onPressed: () {
                          Get.to(()=>ProductScreen());
                        },
                        icon: Icon(Icons.close_outlined)),

                  ],
                ),
                SizedBox(height: 10,),
                Container(
                  padding: EdgeInsets.all(10),
                  height: 350,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),

                  ),
                  child:
                  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              RatingBar.builder(
                                initialRating: 5,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 20,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: AppColors.primary,
                                ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                },
                              ),
                              AppText(text: '  4+', fontSize: 16, fontWeight: FontWeight.w500,),
                              Spacer(),
                              Radio(
                                value: index.toString(), // Each radio button has a unique value based on index
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    // Update selectedValue only for the radio button that triggered the onChanged callback
                                    selectedValue = value as String?;
                                  });
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
                            child: Divider(
                              color: Colors.grey.shade200,
                              height: 1,
                            ),
                          )
                        ],
                      );
                    },
                  ),


                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CustomButton(
                      onTap: () {
                        setState(() {
                          BtnValue = 'clear all';
                        });
                      },
                      labelColor:
                      BtnValue == 'clear all' ? Colors.white : Colors.black,
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
                      labelColor:
                      BtnValue == 'show 1000' ? Colors.white : Colors.black,
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
                SizedBox(height: 10,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
