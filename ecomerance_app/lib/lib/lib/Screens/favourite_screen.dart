import 'package:ecomerance_app/CustomWidgets/CustomButton.dart';
import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppColors/appcolors.dart';
import '../routes/route_name.dart';

class FavouriteScreen extends StatefulWidget {
  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  int _oneCounter = 0;
  int _secondCounter = 0;
  int _thirdCounter = 0;

  void _incrementCounter1() {
    setState(() {
      _oneCounter++;
    });
  }

  void _incrementCounter2() {
    setState(() {
      _secondCounter++;
    });
  }

  void _incrementCounter3() {
    setState(() {
      _thirdCounter++;
    });
  }

  void _decrementCounter1() {
    setState(() {
      if (_oneCounter > 0) {
        _oneCounter--;
      }
    });
  }

  void _decrementCounter2() {
    setState(() {
      if (_secondCounter > 0) {
        _secondCounter--;
      }
    });
  }

  void _decrementCounter3() {
    setState(() {
      if (_thirdCounter > 0) {
        _thirdCounter--;
      }
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
          'Favourite Screen',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCartItem(
                counter: _oneCounter,
                increment: _incrementCounter1,
                decrement: _decrementCounter1,
              ),
              _buildCartItem(
                counter: _secondCounter,
                increment: _incrementCounter2,
                decrement: _decrementCounter2,
              ),
              _buildCartItem(
                counter: _thirdCounter,
                increment: _incrementCounter3,
                decrement: _decrementCounter3,
              ),
              const SizedBox(
                height: 5,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Sub-total',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textColor: Colors.grey,
                  ),
                  AppText(
                    text: '\$ 5,870',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Vat(%)',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textColor: Colors.grey,
                  ),
                  AppText(
                    text: '\$ 0.00',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Shipping fee',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textColor: Colors.grey,
                  ),
                  AppText(
                    text: '\$ 80',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
                child: Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Total',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    textColor: Colors.grey,
                  ),
                  AppText(
                    text: '\$ 5,950',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              CustomButton(
                onTap: () {
                  Get.toNamed(RouteName.checkoutScreen);
                },
                label: 'Go to checkout',
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

  Widget _buildCartItem(
      {required int counter,
      required Function increment,
      required Function decrement}) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/person.png')),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'Regular fit Salgon',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              AppText(
                text: 'Size L',
                textColor: Colors.grey,
              ),
              Spacer(),
              AppText(
                text: '\$ 1,119',
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.delete,
                color: Colors.red,
                size: 22,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => decrement(),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.remove,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    '$counter',
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () => increment(),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
