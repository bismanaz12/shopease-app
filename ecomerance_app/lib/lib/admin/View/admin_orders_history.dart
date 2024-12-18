import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model/order_model.dart';


class AdminOrderHistory extends StatefulWidget {
  const AdminOrderHistory({Key? key}) : super(key: key);

  @override
  State<AdminOrderHistory> createState() => _AdminOrderHistoryState();
}

class _AdminOrderHistoryState extends State<AdminOrderHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Admin Order History',
          style: TextStyle(color: Colors.white),
        ),
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

          // Filter orders to show only delivered or cancelled orders
          List<UserOrder> deliveredOrCancelledOrders = orders
              .where((order) =>
          order.status.toLowerCase() == 'delivered' ||
              order.status.toLowerCase() == 'cancelled')
              .toList();

          // Sort the filtered orders by date
          deliveredOrCancelledOrders.sort(
                  (a, b) => b.currentTime.compareTo(a.currentTime)); // Sort by descending date

          return ListView.builder(
            itemCount: deliveredOrCancelledOrders.length,
            itemBuilder: (context, index) {
              UserOrder order = deliveredOrCancelledOrders[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                        Text(
                          'Order No: ',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        Text(
                          '${order.orderNo}',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: _getStatusColor(order.status),
                          ),
                          child: Text(
                            '${order.status}',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Delivery Address:     ${order.address}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Payment Method: ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        Spacer(),
                        // Add payment method icon as needed
                        Text(
                          order.paymentMethod,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
