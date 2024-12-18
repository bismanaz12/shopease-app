import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:ecomerance_app/Screens/categoryscreen.dart';
import 'package:ecomerance_app/Screens/rating_screen.dart';
import 'package:ecomerance_app/Screens/retailer_screen.dart';
import 'package:ecomerance_app/Screens/sale_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../AppColors/appcolors.dart';
import '../routes/route_name.dart';
import 'brandscreen.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String BtnValue = 'show 1000';
  RangeValues _values = const RangeValues(20, 80);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 5),
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppText(
                  text: 'Filter',
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(
                  width: 90,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close_outlined)),
              ],
            ),
            // SizedBox(height: 5),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 22),
                title: AppText(
                  text: 'Category',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isDismissible: true,
                    useRootNavigator: true,
                    expand: true,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.8, // 80% of the screen height
                          child: CategoryScreen(),
                        ),
                      ); //e YourBottomSheetWidget with your actual bottom sheet widget
                    },
                  );
                  // Close the bottom sheet
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 22),
                title: AppText(
                  text: 'Brand',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isDismissible: true,
                    useRootNavigator: true,
                    expand: true,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.8, // 80% of the screen height
                          child: BrandScreen(),
                        ),
                      ); //e YourBottomSheetWidget with your actual bottom sheet widget
                    },
                  );
                  // Close the bottom sheet
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 22),
                title: AppText(
                  text: 'Sale',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isDismissible: true,
                    useRootNavigator: true,
                    expand: true,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.8, // 80% of the screen height
                          child: SaleScreen(),
                        ),
                      ); //e YourBottomSheetWidget with your actual bottom sheet widget
                    },
                  );
                  // Close the bottom sheet
                },
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xffF6F6F8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: 'Price',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    RangeSlider(
                      min: 0,
                      max: 100,
                      values: _values,
                      divisions: 100,
                      activeColor: AppColors.primary,
                      inactiveColor: Colors.grey,
                      onChanged: (newValues) {
                        setState(() {
                          _values = newValues;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Text(
                              '\$ ${_values.start.round()}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(
                            child: Text(
                              '\$ ${_values.end.round()}',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 22),
                title: AppText(
                  text: 'Rating',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isDismissible: true,
                    useRootNavigator: true,
                    expand: true,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.8, // 80% of the screen height
                          child: RatingScreen(),
                        ),
                      ); //e YourBottomSheetWidget with your actual bottom sheet widget
                    },
                  );
                  // Close the bottom sheet
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              height: 55,
              decoration: BoxDecoration(
                color: Color(0xffF6F6F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                trailing: Icon(Icons.arrow_forward_ios_outlined, size: 22),
                title: AppText(
                  text: 'Retailer',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                onTap: () {
                  showMaterialModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    isDismissible: true,
                    useRootNavigator: true,
                    expand: true,
                    builder: (BuildContext context) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.8, // 80% of the screen height
                          child: RetailerScreen(),
                        ),
                      ); //e YourBottomSheetWidget with your actual bottom sheet widget
                    },
                  );
                  // Close the bottom sheet
                },
              ),
            ),

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
            SizedBox(height: 20), // Additional space at the bottom
          ],
        ),
      ),
    );
  }
}
