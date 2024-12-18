import 'package:ecomerance_app/CustomWidgets/CustomIconButton.dart';
import 'package:ecomerance_app/CustomWidgets/CustomTextformField.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:ecomerance_app/Screens/signin_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AppColors/appcolors.dart';
import '../CustomWidgets/CustomButton.dart';
import '../controllers/register_controller.dart';
import '../routes/route_name.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool checkValue = false;

  RegisterController controller = Get.put(RegisterController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Form(
              key: controller.registerFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AppText(
                    text: 'Create your Account',
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  CustomTextFormField(
                    controller: controller.usernameController,
                    hintText: 'Name',
                      prefixIcon: Icons.person,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    controller: controller.emailController,
                    hintText:'Email' ,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  CustomTextFormField(
                    controller: controller.passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
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
                          }),
                      const AppText(
                        text: 'Remember me',
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() {
                    return CustomButton(
                      onTap: controller.isLoading.value ? null : controller.register,
                      label: controller.isLoading.value ? 'Loading...' : 'Register',
                      bgColor: controller.isLoading.value ? Colors.grey : AppColors.primary,
                      labelColor: Colors.white,
                      borderRadius: 50,
                      height: 50,
                    );
                  }),

                  const SizedBox(
                    height: 40,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: AppText(text: "Or Continue with", fontSize: 12),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomIconButton(
                        imgPath: 'assets/icons/facebook.svg',
                      ),
                      CustomIconButton(
                        imgPath: 'assets/icons/google.svg',
                      ),
                      CustomIconButton(
                        imgPath: 'assets/icons/apple.svg',
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  RichText(
                    text: TextSpan(
                      text: "Already have an account ?  ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.to(()=>SignInScreen());
                            },
                          text: 'Sign In',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
