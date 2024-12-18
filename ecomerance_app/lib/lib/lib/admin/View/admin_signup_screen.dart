import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../CustomWidgets/CustomButton.dart';
import '../../CustomWidgets/appText.dart';
import '../Auth/admin_firestore.dart';
import 'admin_login_screen.dart';



class AdminSignUpScreen extends StatefulWidget {
  const AdminSignUpScreen({Key? key}) : super(key: key);

  @override
  State<AdminSignUpScreen> createState() => _AdminSignUpScreenState();
}

class _AdminSignUpScreenState extends State<AdminSignUpScreen> {
  final GlobalKey<FormState> _adminRegisterFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> registerAdmin(String email, String password) async {
    try {
      // Validate the form
      if (_adminRegisterFormKey.currentState!.validate()) {
        // Register the admin user in Firebase Authentication (not shown here)

        // Store data in Firestore under "admin" collection
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        await AdminFirestoreService().addAdminToFirestore(
          emailController.text,
          passwordController.text,
          userNameController.text,
          '',

        );
        Get.snackbar(
          'Success',
          'Admin registered successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.to(() => AdminLoginScreen());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to register admin: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: SingleChildScrollView(
              child: Form(
                key: _adminRegisterFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(text: 'Email', fontSize: 16),
                    TextFormField(
                      controller: userNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        // You can add more complex email validation if needed
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // Email field with validation
                    AppText(text: 'Email', fontSize: 16),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        // You can add more complex email validation if needed
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Password field with validation
                    AppText(text: 'Password', fontSize: 16),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        // You can add more complex password validation if needed
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    CustomButton(
                      onTap: () {
                        if (_adminRegisterFormKey.currentState!.validate()) {
                          registerAdmin(emailController.text, passwordController.text);
                        }
                      },
                      label: 'Register',
                      bgColor: Colors.green,
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: "Already have an account?",
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.to(() => AdminLoginScreen());
                                },
                              text: ' Login',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
