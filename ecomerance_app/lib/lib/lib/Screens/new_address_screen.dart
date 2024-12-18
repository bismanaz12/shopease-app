import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';

class NewAddressScreen extends StatefulWidget {
  const NewAddressScreen({Key? key}) : super(key: key);

  @override
  State<NewAddressScreen> createState() => _NewAddressScreenState();
}

class _NewAddressScreenState extends State<NewAddressScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool checkValue = false;
  int _selectedItem = 0;
  TextEditingController _addressController = TextEditingController();
  TextEditingController _nickNameController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
          'New Address',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [

            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(left: 5),
                height: 412,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 7,
                            width: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: 'Address',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(
                                Icons.close,
                                size: 25,
                              ),
                            )
                          ],
                        ),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 2,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const AppText(
                          text: 'Nickname',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,

                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          bgColor: Colors.white,
                          controller: _nickNameController,
                          hintText: 'Enter Nickname',
                          borderColor: Colors.grey.shade300,

                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const AppText(
                          text: 'Full Address',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        CustomTextFormField(
                          bgColor: Colors.white,
                          controller: _addressController,
                          hintText: 'Enter your Full Address',
                          borderColor: Colors.grey.shade300,

                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              activeColor: AppColors.primary,
                              value: checkValue,
                              onChanged: (value) {
                                setState(() {
                                  checkValue = value!;
                                });
                              },
                            ),
                            const AppText(
                              text: 'Make this as a default address',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,

                            ),
                          ],
                        ),
                        const Spacer(),
                        CustomButton(
                          onTap: () {
                            _saveAddress(); // Save address method
                          },
                          label: 'Add',
                          bgColor: AppColors.primary,
                          labelColor: Colors.white,
                          fontSize: 18,
                        ),
                        SizedBox(height: 10,)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAddress() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // Create a map with the fields to save
        Map<String, dynamic> dataToSave = {
          'uid': user.uid,
          'address': _addressController.text.trim(),
          'city': _nickNameController.text.trim(),
        };

        // Save the new address data to Firestore
        await _firestore.collection('addressdetails').add(dataToSave);

        // Show success dialog
        _showSuccessDialog(context);
      } else {
        print('User is not logged in');
        // Handle case where user is not logged in
      }
    } catch (e) {
      print('Error saving address: $e');
      // Handle error saving address
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SvgPicture.asset('assets/icons/done.svg'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: 'Congratulations!',
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
              const SizedBox(height: 10),
              AppText(
                text: 'Your new Address has been added',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                textColor: Colors.grey,
              ),
            ],
          ),
          actions: [
            CustomButton(
              onTap: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the NewAddressScreen
              },
              label: 'Thanks',
              labelColor: Colors.white,
              bgColor: AppColors.primary,
            ),
          ],
        );
      },
    );
  }
}
