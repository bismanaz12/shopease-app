

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ProductDetailScreenController extends GetxController{

  RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  final RxList<String> sizeList = ['S', 'M', 'L'].obs;
  RxInt selectedIndex = 0.obs;
}