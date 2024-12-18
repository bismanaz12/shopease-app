import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Screens/bottom_navigationbar_screen.dart';



class LoginController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  var isLoading = false.obs; // Add this line

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      isLoading.value = true; // Set loading to true
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Get.off(BottomNevigationBar());
        emailController.clear();
        passwordController.clear();
      } catch (e) {
        // Handle login error
        print('Login Error: $e');
        Get.snackbar(
          'Error',
          'Login failed. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false; // Set loading to false
      }
    }
  }
}
