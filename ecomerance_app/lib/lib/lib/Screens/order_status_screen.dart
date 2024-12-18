import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../AppColors/appcolors.dart';
import '../CustomWidgets/appText.dart';
import '../Model/order_model.dart';

class OrderStatusScreen extends StatefulWidget {
  @override
  _OrderStatusScreenState createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  Future<String> getCurrentUserId() async {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Order Status',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: getCurrentUserId(),
        builder: (BuildContext context, AsyncSnapshot<String> userIdSnapshot) {
          if (userIdSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (userIdSnapshot.hasError) {
            return Center(child: Text('Error: ${userIdSnapshot.error}'));
          } else if (!userIdSnapshot.hasData) {
            return Center(child: Text('Unable to retrieve user information.'));
          }

          String userId = userIdSnapshot.data!;

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('uid', isEqualTo: userId) // Filter orders by current user ID
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Colors.teal,));
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/nodata.webp', height: 150, width: 150,),
                    SizedBox(height: 10,),
                    Text('No orders found',style: TextStyle(color: Colors.white),),
                  ],
                ));
              }

              List<UserOrder> orders = snapshot.data!.docs
                  .map((doc) => UserOrder.fromMap(doc.data() as Map<String, dynamic>))
                  .toList();

              // Group orders by date
              Map<String, List<UserOrder>> groupedOrders = {};
              for (var order in orders) {
                String dateKey = _formatDate(order.currentTime);
                if (groupedOrders.containsKey(dateKey)) {
                  groupedOrders[dateKey]!.add(order);
                } else {
                  groupedOrders[dateKey] = [order];
                }
              }

              // Sort the groups by date
              List<String> sortedDates = groupedOrders.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  String currentDate = sortedDates[index];
                  List<UserOrder> ordersOnDate = groupedOrders[currentDate]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Orders placed on $currentDate',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      ...ordersOnDate.map((order) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade700),
                          color: Colors.grey.shade900,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AppText(
                                  text: 'Order No: ',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  textColor: Colors.white,
                                ),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.cyanAccent.shade700,
                                  ),
                                  child: AppText(
                                    text: '${order.orderNo}',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    textColor: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: _getStatusColor(order.status),
                                  ),
                                  child: AppText(
                                    text: '${order.status}',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                    textColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppText(
                              text: 'Delivery Address:         ${order.address}',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                            ),

                            const SizedBox(height: 10),
                            Row(
                              children: [
                                AppText(
                                  text: 'Payment Method: ',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                ),
                                Spacer(),
                                SvgPicture.asset(
                                  _getPaymentMethodIcon(order.paymentMethod),
                                  width: 20,
                                  height: 20,
                                  color: Colors.teal,
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  text: order.paymentMethod,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),


                            const SizedBox(height: 10),
                            AppText(
                              text: 'Ordered Items:',
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                            ),
                            const SizedBox(height: 5),
                            ...order.products.map((product) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  if (product.productImage.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        product.productImage,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText(
                                              text: '${product.productName} x ${product.productQuantity}',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.white,
                                            ),
                                            AppText(
                                              text: '\$${(product.productPrice * product.productQuantity).toStringAsFixed(2)}',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              textColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: 'Shipping Amount:',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                ),
                                AppText(
                                  text: '\$${order.shipping.toStringAsFixed(2)}',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Divider(color: Colors.white,),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  text: 'Total Amount:',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                ),
                                AppText(
                                  text: '\$${order.totalAmount.toStringAsFixed(2)}',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.green;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return 'assets/icons/card.svg';
      case 'cash':
        return 'assets/icons/cash.svg';
      case 'pay':
        return 'assets/icons/apple.svg';
      default:
        return '';
    }
  }
}
