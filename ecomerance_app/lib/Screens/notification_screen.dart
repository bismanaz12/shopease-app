import 'package:ecomerance_app/CustomWidgets/appText.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<bool> switchValue = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<String> title = [
    'GeneralNotifications',
    'Sound',
    'Vibrate',
    'SpecialOffer',
    'Promo & Discounts',
    'Payments',
    'Cashback',
    'App Updates',
    'New service available',
    'New Tips available'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
            itemCount: title.length,
            itemBuilder: (context, index) {
              return Row(
                  children: [
                  AppText(text:title[index],fontSize: 16,),
                    Spacer(),
                    Transform.scale(
                      scale: 0.7, // Adjust the scale factor as needed
                      child: Switch(
                        value: switchValue[index],
                        onChanged: (bool value) {
                          setState(() {
                            switchValue[index] = !switchValue[index];
                          });
                        },
                      ),
                    ),

                  ],
                );

            }),
      ),
    );
  }
}
