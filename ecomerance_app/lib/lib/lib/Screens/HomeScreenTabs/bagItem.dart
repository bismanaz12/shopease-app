import 'package:flutter/material.dart';

class BagItem extends StatefulWidget {
  const BagItem({super.key});

  @override
  State<BagItem> createState() => _BagItemState();
}

class _BagItemState extends State<BagItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Bages Item here'),
      ),
    );
  }
}
