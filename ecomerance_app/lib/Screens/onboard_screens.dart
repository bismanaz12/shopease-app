import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../routes/route_name.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome",
            body: "Welcome to our app. Enjoy your experience!",
            image: Image.asset('assets/images/splashicon.png',height: 250,width: 250,)
          ),
          PageViewModel(
            title: "Discover",
            body: "Discover amazing features at your fingertips.",
              image: Image.asset('assets/images/splashicon.png',height: 250,width: 250,)
          ),
          PageViewModel(
            title: "Get Started",
            body: "Get started now and explore everything.",
              image: Image.asset('assets/images/splashicon.png',height: 250,width: 250,)
          ),
        ],
        onDone: () {
          Get.toNamed(RouteName.welcomeScreen);
        },
        onSkip: () {
          Get.toNamed(RouteName.welcomeScreen);
        },
        showSkipButton: true,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done'),
      ),
    );
  }
}
