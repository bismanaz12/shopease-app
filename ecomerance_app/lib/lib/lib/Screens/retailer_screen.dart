import 'package:ecomerance_app/Screens/product_screen.dart';
import 'package:ecomerance_app/routes/route_name.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../CustomWidgets/appText.dart';


class RetailerScreen extends StatefulWidget {
  const RetailerScreen({super.key});

  @override
  State<RetailerScreen> createState() => _RetailerScreenState();
}

class _RetailerScreenState extends State<RetailerScreen> {
  int? groupValue;
  List<String>radioValues= ['Recomended','Lowest Price','Highest Price','Rating','Sale'];
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios_new_outlined)),
                    SizedBox(width: 20),
                    AppText(
                      text: 'Retailer',
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
            Expanded(
              // height: 390,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: radioValues.length,
                itemBuilder: (context,index){
                  return Column(
                    children: [
                      RadioListTile(
                        title: Text(radioValues[index]),
                        value: index, // Use index as the value for each RadioListTile
                        groupValue: groupValue,
                        onChanged: (value){
                          setState(() {
                            groupValue = value as int; // Cast value to integer
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Divider(color: Colors.grey.shade300, height: 1),
                      )
                    ],
                  );
                },
              ),
            ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
