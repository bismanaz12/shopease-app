import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../CustomWidgets/appText.dart';
import '../../model/order_model.dart';
import 'admin_orders_history.dart';

class AdminAllOrders extends StatefulWidget {
  const AdminAllOrders({Key? key}) : super(key: key);

  @override
  _AdminAllOrdersState createState() => _AdminAllOrdersState();
}

class _AdminAllOrdersState extends State<AdminAllOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Admin All Orders',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => AdminOrderHistory());
            },
            icon: Icon(Icons.history),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No orders found.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          List<UserOrder> orders = snapshot.data!.docs
              .map((doc) => UserOrder.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          // Filter out delivered and cancelled orders
          orders.removeWhere((order) => order.status.toLowerCase() == 'delivered' || order.status.toLowerCase() == 'cancelled');

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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ...ordersOnDate.map((order) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            GestureDetector(
                              onTap: () {
                                _showStatusUpdateDialog(order);
                              },
                              child: Container(
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
                                          text:
                                          '\$${(product.productPrice * product.productQuantity).toStringAsFixed(2)}',
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
                        Divider(
                          color: Colors.white,
                        ),
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

  void _showStatusUpdateDialog(UserOrder order) {
    String? newStatus = order.status; // Initialize with current status

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Current Status: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text('${order.status}'),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Select New Status:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusButton('Pending', newStatus, () {
                    setState(() {
                      newStatus = 'Pending';
                    });
                  }),
                  SizedBox(width: 5),
                  _buildStatusButton('Processing', newStatus, () {
                    setState(() {
                      newStatus = 'Processing';
                    });
                  }),
                  SizedBox(width: 5),
                  _buildStatusButton('Shipped', newStatus, () {
                    setState(() {
                      newStatus = 'Shipped';
                    });
                  }),
                  SizedBox(width: 5),
                  _buildStatusButton('Delivered', newStatus, () {
                    setState(() {
                      newStatus = 'Delivered';
                    });
                  }),
                  SizedBox(width: 5),
                  _buildStatusButton('Cancelled', newStatus, () {
                    setState(() {
                      newStatus = 'Cancelled';
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update status in Firestore and close dialog
              setState(() {
                order.status = newStatus!;
                _updateOrder(order);
              });
              // Pass the document ID here
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
      String status, String? currentStatus, VoidCallback onPressed) {
    return TextButton(
      onPressed: () {
        onPressed();
        setState(() {});
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          currentStatus == status ? Colors.teal : Colors.grey,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateOrder(UserOrder order) async {
    try {
      // Find the document by orderNo
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('orderNo', isEqualTo: order.orderNo)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference documentReference = querySnapshot.docs.first.reference;

        // Update the document
        await documentReference.update({
          'status': order.status,
          // Add other fields to update here as needed
        });

        // Successfully updated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order not found')),
        );
      }
    } catch (error) {
      // Error updating
      print('Failed to update order: $error'); // Log the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $error')),
      );
    }
  }
}

