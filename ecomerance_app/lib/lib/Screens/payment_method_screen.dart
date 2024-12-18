import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import '../routes/route_name.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int? _selectedRadio;

  @override
  void initState() {
    super.initState();
    // Initialize the selected radio button value
    _selectedRadio = null; // Initialize as null
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Payment Method'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 230,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListTile(
                          title:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(text:'Visa',fontWeight: FontWeight.w600,fontSize: 20,),
                              SizedBox(width: 10,),
                              AppText(text:'**** **** **** 2512',fontWeight: FontWeight.w500,),
                            ],
                          ),

                          trailing: Radio(
                            value: index,
                            groupValue: _selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                _selectedRadio = value; // Update the selected radio button value
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              CustomButton(
                onTap: (){
                  Get.toNamed(RouteName.newCardScreen);
                },
                imagePath: 'assets/icons/Plus.svg',
                borderColor: Colors.grey.shade300,
                label: 'Add New Card',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const Spacer(),
              CustomButton(
                onTap: () {
                  // Get.toNamed(RouteName.checkoutScreen);
                },
                label: 'Apply',
                bgColor: AppColors.primary,
                labelColor: Colors.white,
                fontSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
