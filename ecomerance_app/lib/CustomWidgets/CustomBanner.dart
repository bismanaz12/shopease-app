import 'package:flutter/material.dart';

class CustomBanner extends StatelessWidget {
  final String title;
  const CustomBanner({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 310,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(title),
      ),
    );
  }
}
