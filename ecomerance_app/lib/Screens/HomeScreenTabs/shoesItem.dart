import 'package:flutter/material.dart';


class ShoesItem extends StatefulWidget {
  const ShoesItem({super.key});

  @override
  State<ShoesItem> createState() => _ShoesItemState();
}

class _ShoesItemState extends State<ShoesItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Shoes Items here'),
      ),
    );
  }
}
