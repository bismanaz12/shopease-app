import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../AppColors/appcolors.dart';
import '../controllers/product_screen_controller.dart';
import 'ProductScreenItems/cupboard_screen.dart';
import 'ProductScreenItems/chairs_screen.dart'; // Corrected import path
import 'filter_screen.dart';
import 'ProductScreenItems/sofa_screen.dart';
import 'ProductScreenItems/table_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final ProductScreenController controller = Get.put(ProductScreenController());
  List<String> productsType = ["Cupboard", "Chairs", "Sofa", "Table"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Obx(() => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black),
                    ),
                    child:GestureDetector(
                        onTap: (){
                          showMaterialModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            isDismissible: true,
                            useRootNavigator: true,
                            expand: true,
                            builder: (BuildContext context) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: 0.8, // 80% of the screen height
                                  child: FilterScreen(),
                                ),
                              );//e YourBottomSheetWidget with your actual bottom sheet widget
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.asset('assets/icons/filter.png',width: 10,height: 10,),
                        )),
                  ),



                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 40,
                        child: TabBar(
                          tabAlignment: TabAlignment.start,
                          isScrollable: true,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                          ),
                          onTap: (index) {
                            controller.changeTabIndex(index);
                          },
                          tabs: productsType.map<Widget>((type) {
                            return Tab(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    controller.changeTabIndex(productsType.indexOf(type));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    width:  90,
                                    decoration: BoxDecoration(
                                      color: controller.selectedIndex == productsType.indexOf(type)
                                          ? AppColors.primary
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: controller.selectedIndex == productsType.indexOf(type)
                                            ? Colors.transparent
                                            : AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        type,
                                        style: Theme.of(context).textTheme.titleLarge!.merge(
                                          TextStyle(
                                            color: controller.selectedIndex == productsType.indexOf(type)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize:  12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            Expanded(
              child: Obx(() {
                switch (controller.selectedIndex) {
                  case 0:
                    return const CupboardScreen();
                  case 1:
                    return const ChairScreen();
                  case 2:
                    return const SofaScreen();
                  case 3:
                    return const TableScreen();
                  default:
                    return const SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

}

