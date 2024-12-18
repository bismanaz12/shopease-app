import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/appText.dart';
import 'new_address_screen.dart';


class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  int? _selectedRadio = 0;
  late String userId;
  List<Map<String, dynamic>> addresses = [];


  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _fetchAddresses();
  }

  void _fetchAddresses() {
    CollectionReference addressDetails =
    FirebaseFirestore.instance.collection('addressdetails');
    addressDetails.where('uid', isEqualTo: userId).get().then((querySnapshot) {
      setState(() {
        addresses.clear();
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          addresses.add(data);
        });
      });
    }).catchError((error) {
      print("Failed to fetch addresses: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Address',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              onPressed: () async {
                Get.to(() => NewAddressScreen())!.then((value) => setState(() {
                  _fetchAddresses();
                }), // Refresh the screen after adding a new address
                );
              },
              icon: Icon(Icons.add),
            ),
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
                child: addresses.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/nodata.webp',color: AppColors.primary,height: 150,width: 150,),
                      AppText(
                        text: 'Please add address details',
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> address = addresses[index];
                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Address'),
                            content: Text(
                                'Are you sure you want to delete this address?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  String? addressId = address['id'];
                                  if (addressId != null) {
                                    _deleteAddress(addressId);
                                  } else {
                                    print('Address ID is null');
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
                          title: AppText(
                            text: address['address'],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,

                          ),
                          subtitle: AppText(
                            text: address['city'],
                            fontWeight: FontWeight.w500,

                          ),
                          trailing: Radio(
                            value: index,
                            groupValue: _selectedRadio,
                            onChanged: (value) {
                              setState(() {
                                _selectedRadio = value as int?;
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
                  if (_selectedRadio != null) {
                    Map<String, dynamic> selectedAddress =
                    addresses[_selectedRadio!];
                    Get.back(result: selectedAddress);
                  } else {
                    // Show a message to select an address
                    print('Please select an address.');
                  }
                },
                label: 'Apply',
                bgColor:AppColors.primary,
                labelColor: Colors.white,
                fontSize: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteAddress(String addressId) {
    FirebaseFirestore.instance
        .collection('addressdetails')
        .doc(addressId)
        .delete()
        .then((_) {
      print('Address deleted successfully');
      _fetchAddresses();
    }).catchError((error) {
      print('Failed to delete address: $error');
    });
  }
}
