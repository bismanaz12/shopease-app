import 'package:flutter/material.dart';

import '../CustomWidgets/customListTile.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool payment = false;
  bool tracking = false;
  bool completeOrder = false;
  bool notification = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:const Text('Notifications') ,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300,width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                CustomListTile(
                title: 'Payment',
                trailingWidget: Switch(
                  value: payment,
                  onChanged: (value) {
                    payment = value;
                    setState(() {

                    });
                  },
                ),
              ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 4),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                  CustomListTile(
                    title: 'Tracking',
                    trailingWidget: Switch(
                      value: tracking,
                      onChanged: (value) {
                        tracking = value;
                        setState(() {

                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 5),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                  CustomListTile(
                    title: 'Complete Order',
                    trailingWidget: Switch(
                      value: completeOrder,
                      onChanged: (value) {
                        completeOrder = value;
                        setState(() {

                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18,vertical: 5),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                  CustomListTile(
                    title: 'Notification',
                    trailingWidget: Switch(
                      value: notification,
                      onChanged: (value) {
                        notification = value;
                        setState(() {

                        });
                      },
                    ),
                  ),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
