import 'package:flutter/material.dart';

class ClothesItem extends StatefulWidget {
  const ClothesItem({super.key});

  @override
  State<ClothesItem> createState() => _ClothesItemState();
}

class _ClothesItemState extends State<ClothesItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Clothes Items here'),
      ),
    );;
  }
}
