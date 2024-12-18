import 'package:flutter/material.dart';

class CashPayment extends StatefulWidget {
  const CashPayment({super.key});

  @override
  State<CashPayment> createState() => _CashPaymentState();
}

class _CashPaymentState extends State<CashPayment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('Cash Payment'),
      ),
    );
  }
}
