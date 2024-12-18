import 'package:ecomerance_app/lib/lib/Screens/chat_screen.dart';
import 'package:ecomerance_app/routes/route_name.dart';
import 'package:get/get.dart';
import 'package:ecomerance_app/Screens/splash_screen.dart';
import 'package:ecomerance_app/Screens/welcome_screen.dart';
import 'package:ecomerance_app/Screens/home_screen.dart';
import 'package:ecomerance_app/Screens/profile_screen.dart';
import 'package:ecomerance_app/Screens/cart_screen.dart';
import 'package:ecomerance_app/Screens/notification_screen.dart';
import 'package:ecomerance_app/Screens/product_screen.dart';
import 'package:ecomerance_app/Screens/sale_screen.dart';
import 'package:ecomerance_app/Screens/rating_screen.dart';
import 'package:ecomerance_app/Screens/retailer_screen.dart';
import 'package:ecomerance_app/Screens/filter_screen.dart';
import 'package:ecomerance_app/Screens/address_screen.dart';
import 'package:ecomerance_app/Screens/new_address_screen.dart';
import 'package:ecomerance_app/Screens/payment_method_screen.dart';
import 'package:ecomerance_app/Screens/language_screen.dart';
import 'package:ecomerance_app/Screens/legal_and_policy_screen.dart';
import 'package:ecomerance_app/Screens/help_and_support_screen.dart';
import 'package:ecomerance_app/Screens/setting_screen.dart';
import 'package:ecomerance_app/Screens/security_screen.dart';
import 'package:ecomerance_app/Screens/faqs_screen.dart';

import '../Screens/bottom_navigationbar_screen.dart';
import '../Screens/brandscreen.dart';
import '../Screens/categoryscreen.dart';
import '../Screens/new_card.dart';
import '../Screens/onboard_screens.dart';
import '../Screens/search.dart';
import '../Screens/signin_screen.dart';
import '../Screens/signup_screen.dart';

class AppRoutes {
  static List<GetPage> appRoutes() => [
        GetPage(
          name: RouteName.splashScreen,
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: RouteName.onboardScreens,
          page: () => const OnboardingScreen(),
        ),
        GetPage(
          name: RouteName.welcomeScreen,
          page: () => const WelcomeScreen(),
        ),
        GetPage(
          name: RouteName.signUpScreen,
          page: () => const SignUpScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.signInScreen,
          page: () => const SignInScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.homeScreen,
          page: () => HomeScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.bottomNavigationBar,
          page: () => BottomNevigationBar(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.profileScreen,
          page: () => ProfileScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.searchScreen,
          page: () => SearchScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.cartScreen,
          page: () => CartScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.notificationScreen,
          page: () => NotificationScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.productScreen,
          page: () => ProductScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.categoryScreen,
          page: () => CategoryScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.brandScreen,
          page: () => BrandScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.saleScreen,
          page: () => SaleScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.ratingScreen,
          page: () => RatingScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.retailerScreen,
          page: () => RetailerScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.filterScreen,
          page: () => FilterScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.addressScreen,
          page: () => AddressScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.newAddressScreen,
          page: () => NewAddressScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.paymentMethodScreen,
          page: () => PaymentMethod(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.newCardScreen,
          page: () => NewCard(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.languageScreen,
          page: () => LanguageScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.legalAndPolicyScreen,
          page: () => LegalAndPolicyScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.helpAndSupportScreen,
          page: () => HelpAndSupportScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.settingScreen,
          page: () => SettingScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.securityScreen,
          page: () => SecurityScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.faqsScreen,
          page: () => FAQsScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.notifications,
          page: () => NotificationScreen(),
          transition: Transition.leftToRight,
          transitionDuration: const Duration(milliseconds: 500),
        ),
        GetPage(
          name: RouteName.chatScreen,
          page: () => ChatScreen(),
          transition: Transition.leftToRightWithFade,
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ];
}
