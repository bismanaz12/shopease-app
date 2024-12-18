import 'package:flutter/material.dart';

import '../AppColors/appcolors.dart';

class LegalAndPolicyScreen extends StatefulWidget {
  const LegalAndPolicyScreen({super.key});

  @override
  State<LegalAndPolicyScreen> createState() => _LegalAndPolicyScreenState();
}

class _LegalAndPolicyScreenState extends State<LegalAndPolicyScreen> {
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
          'Legal and policy',
          style: TextStyle(color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
