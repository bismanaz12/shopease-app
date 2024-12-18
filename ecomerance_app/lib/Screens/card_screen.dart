import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import 'new_card.dart'; // Import Get package for navigation


class CardScreen extends StatefulWidget {
  const CardScreen({Key? key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  int? _selectedRadio =0;
  late String userId; // Variable to store current user ID
  List<Map<String, dynamic>> paymentMethods = []; // List to store payment methods

  @override
  void initState() {
    super.initState();
    // Initialize the selected radio button value

    // Fetch current user ID
    userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch initial payment methods
    _fetchPaymentMethods();
  }

  void _fetchPaymentMethods() {
    // Fetching payment methods
    CollectionReference cardDetails =
    FirebaseFirestore.instance.collection('carddetails');
    cardDetails.where('userId', isEqualTo: userId).get().then((querySnapshot) {
      setState(() {
        paymentMethods.clear();
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Ensure each payment method has an 'id' field
          paymentMethods.add(data);
        });
      });
    }).catchError((error) {
      print("Failed to fetch payment methods: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        title: const Text(
          'Cards Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                onPressed: () async {
                  Get.to(() => NewCard())!.then((value) => setState(() {
                    _fetchPaymentMethods();
                  }), // Refresh the screen after adding a new address
                  );
                },
                icon: Icon(Icons.add)),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Expanded(
                flex: 10,
                child:  paymentMethods.isEmpty ?
                Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/nodata.webp',height: 150,width: 150,color: AppColors.primary,),
                    AppText( text: 'Please add card details',textColor: Colors.white,),
                  ],
                ))
                    :ListView.builder(
                  itemCount:
                  paymentMethods.length, // Use payment methods list length
                  itemBuilder: (context, index) {
                    // Access each payment method details
                    Map<String, dynamic> method = paymentMethods[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Payment Method'),
                            content: Text(
                                'Are you sure you want to delete this payment method?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String? paymentMethodId = method['id'];
                                  if (paymentMethodId != null) {
                                    _deletePaymentMethod(paymentMethodId);
                                  } else {
                                    print('Payment method ID is null');
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText(
                                text: 'Visa',
                                fontWeight: FontWeight.w600,
                                fontSize: 20,

                              ),
                              const SizedBox(width: 10),
                              AppText(
                                text:
                                '**** **** **** ${method['cardNumber'].substring(method['cardNumber'].length - 4)}',
                                fontWeight: FontWeight.w500,
                              ),
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
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              CustomButton(
                onTap: () {
                  if (_selectedRadio != null ) {
                    Map<String, dynamic> selectedPaymentMethod = paymentMethods[_selectedRadio!];
                    Get.back(result: selectedPaymentMethod);
                  } else {
                    // Show a message to select a payment method
                    print('Please select a payment method.');
                  }
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

  void _deletePaymentMethod(String paymentMethodId) {
    FirebaseFirestore.instance
        .collection('carddetails')
        .doc(paymentMethodId)
        .delete()
        .then((_) {
      print('Payment method deleted successfully');
      _fetchPaymentMethods(); // Refresh payment methods list after deletion
    }).catchError((error) {
      print('Failed to delete payment method: $error');
    });
  }
}
