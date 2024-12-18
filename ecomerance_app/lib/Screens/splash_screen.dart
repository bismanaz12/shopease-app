import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/route_name.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
  Future.delayed(const Duration(seconds: 4),(){
    Get.toNamed(RouteName.onboardScreens);
  });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/splashicon.png',
          height: 150,
          width: 150,
        ),
      ),
    );
  }
}
