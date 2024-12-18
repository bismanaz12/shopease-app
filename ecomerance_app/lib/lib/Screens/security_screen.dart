import 'package:flutter/material.dart';

import '../AppColors/appcolors.dart';
import '../CustomWidgets/customListTile.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool faceID = false;
  bool rememberPassword = false;
  bool touchID = false;
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
          'Security',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CustomListTile(
                    title: 'Face ID',
                    trailingWidget: Switch(
                      value: faceID,
                      onChanged: (value) {
                        faceID = value;
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                  CustomListTile(
                    title: 'Remember Password',
                    trailingWidget: Switch(
                      value: rememberPassword,
                      onChanged: (value) {
                        rememberPassword = value;
                        setState(() {});
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    child: Divider(
                      color: Colors.grey.shade200,
                      height: 1,
                      thickness: 2,
                    ),
                  ),
                  CustomListTile(
                    title: 'Touch ID',
                    trailingWidget: Switch(
                      value: touchID,
                      onChanged: (value) {
                        touchID = value;
                        setState(() {});
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
