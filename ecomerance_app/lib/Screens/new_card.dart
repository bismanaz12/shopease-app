import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerance_app/AppColors/appcolors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../CustomWidgets/CustomButton.dart';
import '../CustomWidgets/CustomTextformField.dart';
import '../CustomWidgets/appText.dart';
import 'card_screen.dart';


class NewCard extends StatefulWidget {
  const NewCard({Key? key}) : super(key: key);

  @override
  State<NewCard> createState() => _NewCardState();
}

class _NewCardState extends State<NewCard> {
  // Define variables to store card information
  late String cardNumber;
  late String expiryDate;
  late String securityCode;
  void _showSuccessDialog(BuildContext context) {
    // Validate card number
    if (cardNumber.length != 19) {
      _showErrorDialog(context, 'Invalid Card Number', 'Card number must be 16 digits.');
      return;
    }

    // Validate expiry date format
    RegExp expiryDateRegex = RegExp(r'^\d{2}/\d{2}$');
    if (!expiryDateRegex.hasMatch(expiryDate)) {
      _showErrorDialog(context, 'Invalid Expiry Date', 'Expiry date must be in MM/YY format.');
      return;
    }

    // Validate security code (CVC)
    if (securityCode.length != 3) {
      _showErrorDialog(context, 'Invalid Security Code', 'Security code must be 3 digits.');
      return;
    }

    // Get current user ID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Create a reference to Firestore collection
    CollectionReference cardDetails = FirebaseFirestore.instance.collection('carddetails');

    // Add a new document with a generated ID
    cardDetails.add({
      'userId': uid,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'securityCode': securityCode,
      'createdAt': FieldValue.serverTimestamp(), // Optional: Timestamp of creation
    }).then((value) {
      // Successfully added to Firestore
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
                AppText(
                  text: 'Your new card has been added',
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
                  Navigator.of(context).pop(); // Close NewCard screen
                  Get.to(() => CardScreen()); // Navigate to PaymentMethod screen
                },
                label: 'Thanks',
                labelColor: Colors.white,
                bgColor:AppColors.primary,
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      // Handle errors
      print("Failed to add card: $error");
      // Optionally show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey.shade800,
            title: SvgPicture.asset('assets/icons/error.svg'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: 'Error!',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  textColor: Colors.white,
                ),
                AppText(
                  text: 'Failed to add card. Please try again.',
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
                },
                label: 'Close',
                labelColor: Colors.white,
                bgColor: Colors.red,
              ),
            ],
          );
        },
      );
    });
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade800,
          title: SvgPicture.asset('assets/icons/error.svg'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: title,
                fontWeight: FontWeight.w500,
                fontSize: 20,
                textColor: Colors.white,
              ),
              AppText(
                text: message,
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
              },
              label: 'Close',
              labelColor: Colors.white,
              bgColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          'New Card',
          style: TextStyle(color: Colors.white),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            AppText(
              text: 'Add Debit or Credit Card',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            const SizedBox(height: 10),
            const AppText(
              text: 'Card Number',
              fontWeight: FontWeight.w500,
              fontSize: 16,

            ),
            const SizedBox(height: 5),
            CustomTextFormField(
              inputFormatters: [
                CardNumberTextInputFormatter(),
              ],
              keyboardType: TextInputType.number,
              hintText: 'Enter your Card Number',
              borderColor: Colors.grey.shade300,
              bgColor: Colors.white,
              onChanged: (value) {
                cardNumber = value; // Update card number
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Expiry Date',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      inputFormatters: [
                        DateTextInputFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      width: MediaQuery.of(context).size.width * .43,
                      hintText: 'MM/YY',
                      borderColor: Colors.grey.shade300,
                      bgColor: Colors.white,
                      onChanged: (value) {
                        expiryDate = value; // Update expiry date
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      text: 'Security Code',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 10),
                    CustomTextFormField(
                      inputFormatters: [
                        CvcTextInputFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      width: MediaQuery.of(context).size.width * .43,
                      hintText: 'CVC',
                      borderColor: Colors.grey.shade300,
                      bgColor: Colors.white,
                      onChanged: (value) {
                        securityCode = value; // Update security code
                      },
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              onTap: () {
                _showSuccessDialog(context);
              },
              label: 'Add',
              bgColor: AppColors.primary,
              labelColor: Colors.white,
              fontSize: 18,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class CardNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Remove any non-numeric characters

    // Insert '-' after every 4 characters except at the 17th character and beyond
    List<String> segments = [];
    for (int i = 0; i < newText.length; i += 4) {
      if (i != 16) {
        segments.add(newText.substring(i, i + 4));
      } else {
        segments.add(newText.substring(i));
        break; // Stop further segmentation for characters beyond the 16th position
      }
    }
    newText = segments.join('-');

    // Check if the length of the formatted text exceeds 19 characters
    if (newText.length > 19) {
      // Truncate the text to 19 characters
      newText = newText.substring(0, 19);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
class DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Remove any non-numeric characters

    // Insert '/' after the 2nd character if the length is greater than 2
    if (newText.length > 2) {
      newText = newText.substring(0, 2) + '/' + newText.substring(2);
    }

    // Check if the length of the formatted text exceeds 5 characters
    if (newText.length > 5) {
      // Truncate the text to 5 characters
      newText = newText.substring(0, 5);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class CvcTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), ''); // Remove any non-numeric characters

    // Check if the length of newText exceeds 3 characters
    if (newText.length > 3) {
      // Truncate the text to 3 characters
      newText = newText.substring(0, 3);
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

